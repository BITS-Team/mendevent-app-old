import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mend_doctor/models/modDoctor.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/pages/pageLogin.dart';
import 'package:mend_doctor/pages/pageNotification.dart';
import 'package:mend_doctor/pages/pageProfile.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:mend_doctor/widgets/event_list_item.dart';
import 'package:mend_doctor/widgets/profile_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mend_doctor/singletons/singletonEvent.dart';
import 'package:mend_doctor/utils/notificationFirebase.dart';

class EventListPage extends StatefulWidget {
  static const routeName = '/eventListPage';
  @override
  EventListPageState createState() {
    return EventListPageState();
  }
}

class EventListPageState extends State<EventListPage> with SingleTickerProviderStateMixin {
  final storage = new FlutterSecureStorage();

  /// unnecessary, widget tree context ashiglaj boloh yum bna lee.
  BuildContext mContext;

  double contextWidth;
  DateTime currentBackPressTime;

  ScrollController _controller;
  ScrollController _myController;
  List<EventUserWithInvoices> lEventUserInvoices = List();

  User user;

  TabController _tabController;

  Map<int, Event> mEvents;
  Map<int, Event> myEvents;
  Database db;
  Doctor mDoctor; //TODO: remove model

  /// states
  bool isProfileLoaded;
  String lastName = '';
  String firstName = '';
  String description = '';
  String avatarUrl = '';

  bool loadMore = false;
  bool loadPayment = false;
  bool checkEventsCalled = false;

  /// from DB paging
  int totalCount = 0;
  int page = 1;
  int max = 10;

  @override
  void initState() {
    isProfileLoaded = false;
    mEvents = Map<int, Event>();
    myEvents = Map<int, Event>();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _myController = ScrollController();

    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(_tabListener);
    super.initState();

    init();
    eventData.firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        dynamic notification = message['notification'];
        NotificationFirebase(context, notification['title'] ?? '', notification['body'] ?? '').showNotification();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  _tabListener() async {
    if (_tabController.index == 1) {
      setState(() {
        loadPayment = true;
      });
      getMyEvents();
    }
  }

  _scrollListener() async {
    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
      ///first from DB
      if (totalCount > mEvents.length) {
        page += 1;
        eventList(page);
      } else {
        /// next has row in [missing] table?
        List<Map> maps = await db.query('missing', columns: ['first_id', 'missing_count', 'last_event_id'], orderBy: 'id desc');
        if (maps.length > 0) {
          ///if row found, fetch from REST
          setState(() {
            loadMore = true;
          });
          Map<String, dynamic> missing = maps[0];
          int toScroll = mEvents.length;
          loadMoreEvents(missing, toScroll);
        } else {
          ///Nothing do
        }
      }
    }
    if (_controller.offset <= _controller.position.minScrollExtent && !_controller.position.outOfRange) {
      ///TODO: fetch new Events
      // checkEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    contextWidth = MediaQuery.of(context).size.width;
    mContext = context;
    return WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            toast.show("Буцах товчийг дахин дарж гарна уу");
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Container(margin: EdgeInsets.only(left: 40), child: Text("Эвэнтүүд", style: TextStyle(color: Colors.white, fontSize: 16))),
              backgroundColor: Color.fromARGB(255, 2, 24, 99),
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                PopupMenuButton<Choice>(
                  color: Color(0xff021863),
                  onSelected: _select,
//                  icon: Icons.,
                  elevation: 10,
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Container(
//                          color: Colors.green,
                            child: Row(children: <Widget>[
                          Icon(choice.icon, color: Colors.white),
                          Container(width: 10),
                          Text(
                            choice.title,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ])),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            bottomNavigationBar: PreferredSize(
              preferredSize: Size(80, 62),
              child: Container(
                  // decoration: BoxDecoration(border: Border(top: BorderSide(color: StaticData.blueLogo, width: 1))),
                  height: 58,
                  child: TabBar(
                    tabs: [
                      Container(
                        height: 45,
                        child: Tab(
                          text: 'Бүх эвэнтүүд',
                          icon: new Icon(
                            Icons.view_list,
                            size: 15,
                          ),
                        ),
                      ),
                      Container(
                        height: 45,
                        child: Tab(
                          text: 'Миний эвэнтүүд',
                          icon: Icon(
                            Icons.app_registration,
                            size: 15,
                          ),
                        ),
                      )
                    ],
                    controller: _tabController,
                    labelColor: Color.fromARGB(255, 2, 24, 99),
                    unselectedLabelColor: Color.fromARGB(255, 253, 185, 46),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.all(5.0),
                    indicatorColor: Color.fromARGB(255, 2, 24, 99),
                  )),
            ),
            body: Column(
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Container(
                //   child: Image.asset('assets/header_top.png'),
                // ),
                // isProfileLoaded ? Profile(lastName: lastName, firstName: firstName, description: description, avatarUrl: avatarUrl) : Container(),
                Expanded(
                    child: TabBarView(controller: _tabController, children: [
                  drawEvents(mEvents, _controller),
                  drawEvents(myEvents, _myController),

                  // Container(
                  //     child: Text('My Events')
                  // )
                ]))
              ],
            )));
  }

  Container drawEvents(Map<int, Event> events, ScrollController controller) {
    bool hasEvents = events.length > 0;
    List<Widget> lst = List();
    lst.add(Container(
      child: Image.asset('assets/header_top.png'),
    ));
    lst.add(isProfileLoaded ? Profile(lastName: lastName, firstName: firstName, description: description, avatarUrl: avatarUrl) : Container());
    lst.addAll(events.values.toList().map((ev) => EventItem(event: ev)).toList());

    return hasEvents
        ? Container(
            child: Column(
            children: [
              loadPayment
                  ? Container(
                      margin: EdgeInsets.only(top: 100),
                      alignment: Alignment.center,
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                      ))
                  : Container(),
              Expanded(
                  child: RefreshIndicator(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  controller: controller,
                  // itemCount: events.length,
                  // itemBuilder: (BuildContext context, int index) {
                  //   // return drawEventItem(events.values.toList()[index], listType);
                  //   return EventItem(event: events.values.toList()[index]);
                  // },
                  children: lst,
                ),
                //     child: ListView.builder(
                //   scrollDirection: Axis.vertical,
                //   controller: controller,
                //   itemCount: events.length,
                //   itemBuilder: (BuildContext context, int index) {
                //     // return drawEventItem(events.values.toList()[index], listType);
                //     return EventItem(event: events.values.toList()[index]);
                //   },
                // ),
                onRefresh: checkEvents,
              )),
              loadMore
                  ? Container(
                      alignment: Alignment.center,
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                      ))
                  : Container(),
            ],
          ))
        : Container(
            child: Column(children: [
            Container(
              child: Image.asset('assets/header_top.png'),
            ),
            isProfileLoaded ? Profile(lastName: lastName, firstName: firstName, description: description, avatarUrl: avatarUrl) : Container(),
            Expanded(
                flex: 1,
                child: Center(
                    child: Text(
                  'Эвэнт алга байна.',
                  style: TextStyle(color: StaticData.blueLogo, fontSize: 18),
                )))
          ]));
  }

  Future<void> init() async {
    getUser();
    db = await SQLiteHelper.instance.getDb();
    initEvent();
    // eventList();
    delayedCheck();
  }

  void _select(Choice choice) {
    switch (choice.id) {
      case 1:
        if (user.roleId == 6) {
          Navigator.push(mContext, MaterialPageRoute(builder: (context) => ProfilePage()));
        } else {
          toast.show('Одоогоор ажиллахгүй.');
        }
        break;
      case 2:
        Navigator.push(mContext, MaterialPageRoute(builder: (context) => NotificationPage()));
        break;
      case 10:
        logout();
        break;
      default:
        break;
    }
  }

  void logout() async {
    storage.delete(key: 'mendJwt');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('profileData');
    Navigator.of(mContext).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
  }

  Future<void> getUser() async {
    String jsonString = await storage.read(key: 'mendUser') ?? '';
    if (jsonString == '') {
      toast.show('Та дахин нэвтэрнэ үү.');
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
      // Navigator.pop(mContext);
    }
    try {
      ///decode hiih ued zarimdaa aldaad bna. TODO: sain shalgaj aldaag oloh
      user = User.fromJson(jsonDecode(jsonString));
    } catch (e) {
      toast.show('Та дахин нэвтэрнэ үү.');
      // Navigator.pop(mContext);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
    }

    if (user.roleId == 6) {
      /// HARDCODED: role= doctor
      SharedPreferences prefs = await SharedPreferences.getInstance();

      /// Profile data
      var json;
      if (prefs.containsKey('profileData')) {
        json = jsonDecode(prefs.getString('profileData'));
        mDoctor = Doctor.fromJson(json);
        setState(() {
          lastName = mDoctor.lastName.toUpperCase();
          firstName = mDoctor.firstName != '' ? mDoctor.firstName : user.name;
          description = mDoctor.description;
          avatarUrl = mDoctor.avatarUrl != '' ? '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(mDoctor.avatarUrl)}' : '';
          isProfileLoaded = true;
        });
      } else {
        dynamic res = await api.get('${StaticUrl.getProfileUrlwithDomain()}${user.relatedId}');
        if (res['code'] == 1000) {
          json = res['data'];
          await prefs.setString('profileData', jsonEncode(json));
          mDoctor = Doctor.fromJson(json);
          setState(() {
            lastName = mDoctor.lastName.toUpperCase();
            firstName = mDoctor.firstName != '' ? mDoctor.firstName : user.name;
            description = mDoctor.description;
            avatarUrl = mDoctor.avatarUrl != '' ? '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(mDoctor.avatarUrl)}' : '';
            isProfileLoaded = true;
          });
        } else {
          toast.show(res['message']);
        }
      }
    } else if (user.roleId == 8) {
      /// HARDCODED: role= operator
      setState(() {
        isProfileLoaded = true;
        lastName = 'Operator';
        firstName = user.name.toUpperCase();
        description = 'Эвэнт зохион байгуулагч';
        avatarUrl = '';
      });
    }
  }

  Future<void> initEvent() async {
    List<dynamic> res = await db.rawQuery('select count(id) cnt from events');
    if (res.length > 0) {
      totalCount = res[0]['cnt'] ?? 0;
      if (totalCount > 0) {
        eventList(page);
      }
    } else {
      toast.show('Events not found');
    }
  }

  Future<void> eventList(int page) async {
    Map<int, Event> eventMap = Map();
    List<Event> events = await Event().getEventList(page, max);
    // List<ImageMorph> imgBanners = await Event().getEventBanners();
    // List<ImageMorph> imgUrls = await Event().getEventLocationImgs(page);
    // Map<int, ImageMorph> mapImgUrls = Map.fromIterable(imgUrls, key: (item) => item.relatedId, value: (item) => item);
    if (events.length > 0) {
      events.forEach((event) {
        // event.bannerUrls = List();
        // imgBanners.where((im) => im.relatedId == event.id).forEach((im) => event.bannerUrls.add(im.imgPath));
        // event.locationUrl = mapImgUrls[event.id].imgPath;
        eventMap[event.id] = event;
      });
    }
    setState(() {
      mEvents.addAll(eventMap);
    });
  }

  Future<void> loadMoreEvents(Map<String, dynamic> missing, int toScroll) async {
    int lowerId = missing['last_event_id'];
    int greaterId = missing['first_id'];
    Map<String, dynamic> params = {'id_gte': lowerId, 'id_lt': greaterId, '_limit': 10, '_sort': 'id:desc'};
    dynamic json = await api.get('${StaticUrl.getEventUrlwithDomain()}', params: params, auth: false);
    if (json['code'] == 1000) {
      List<dynamic> list = json['data']['list'];
      list = list.map((event) => Event.fromJson(event)).toList();
      if ((missing['missing_count'] - list.length) == 0) {
        /// dutuu event uldeegui (tuhain row -iin huwid) => () delete row
        db.delete('missing',
            where: 'first_id = ? and missing_count = ? and last_event_id = ?',
            whereArgs: [missing['first_id'], missing['missing_count'], missing['last_event_id']]);
      } else {
        /// tuhain row-iin huwid dutuu event uldsen => () update row
        db.update('missing', {'first_id': list.last.id, 'missing_count': missing['missing_count'] - list.length},
            where: 'first_id = ? and missing_count = ? and last_event_id = ?',
            whereArgs: [missing['first_id'], missing['missing_count'], missing['last_event_id']]);
      }

      /// myEvents page deer DB-d hadgalagdsan event-uudiig exclude hiih
      List<Map<String, dynamic>> myEvents = await db.rawQuery('SELECT ev.event_id FROM events ev WHERE ev.event_id > $lowerId and ev.event_id < $greaterId');
      myEvents.forEach((element) {
        list.removeWhere((event) => event.id == element['event_id']);
      });

      Map<int, Event> eventMap = Map();
      List<dynamic> result = List();
      await db.transaction((txn) async {
        var batch = txn.batch();
        list.forEach((event) async {
          String bannerUrl = event.bannerUrls.length > 0 ? event.bannerUrls[0] : '';
          // await txn.insert('events', event.toMap());
          batch.insert('events', event.toMap());
          batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', event.id, 'bannerUrl', bannerUrl]);
          batch.rawInsert(
              'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', event.id, 'locationUrl', event.locationUrl]);

          eventMap[event.id] = event;
        });

        result = await batch.commit();
      }).catchError((e) {
        toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
        Future.delayed(const Duration(milliseconds: 2000), () {
          exit(0);
        });
      });

      setState(() {
        mEvents.addAll(eventMap);
        loadMore = false;
      });
      _controller.animateTo(toScroll * 300.0, duration: Duration(seconds: 2), curve: Curves.ease);
    } else {
      toast.show(json['message']);
    }
  }

  Future<void> loadAddedEvents(List<int> added) async {
    String queryString = '?';
    added.forEach((element) {
      queryString += 'id_in=' + element.toString() + '&';
    });
    dynamic json = await api.get('${StaticUrl.getEventUrlwithDomain()}$queryString', auth: false);
    if (json['code'] == 1000) {
      List<dynamic> list = json['data']['list'];
      list = list.map((event) => Event.fromJson(event)).toList();
      String whereIn = added.toString().replaceFirst("[", "(").replaceFirst("]", ")");

      /// myEvents page deer DB-d hadgalagdsan event-uudiig exclude hiih
      List<Map<String, dynamic>> myEvents = await db.rawQuery('SELECT ev.event_id FROM events ev WHERE ev.event_id IN $whereIn');
      myEvents.forEach((element) {
        list.removeWhere((event) => event.id == element['event_id']);
      });
      Map<int, Event> eventMap = Map();
      List<dynamic> result = List();
      await db.transaction((txn) async {
        var batch = txn.batch();
        list.forEach((event) async {
          String bannerUrl = event.bannerUrls.length > 0 ? event.bannerUrls[0] : '';
          // await txn.insert('events', event.toMap());
          batch.insert('events', event.toMap());
          batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', event.id, 'bannerUrl', bannerUrl]);
          batch.rawInsert(
              'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', event.id, 'locationUrl', event.locationUrl]);

          eventMap[event.id] = event;
        });

        result = await batch.commit();
      }).catchError((e) {
        toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
        Future.delayed(const Duration(milliseconds: 2000), () {
          exit(0);
        });
      });

      setState(() {
        mEvents.clear();
        page = 1;
        initEvent();
      });
      // _controller.animateTo(toScroll * 300.0, duration: Duration(seconds: 2), curve: Curves.ease);
    } else {
      toast.show(json['message']);
    }
  }

  Future<void> getMyEvents() async {
    Map<String, dynamic> params = {'user_id': user.id, 'status': 'A', '_sort': 'updated_at:desc'};
    dynamic json = await api.get('${StaticUrl.getEventPaymentUrlwithDomain()}', params: params);
    if (json['code'] == 1000) {
      List<dynamic> payments = json['data'];

      /// paid event ids
      List<int> paidEventIds = payments.map((p) => cast<int>(p['event_id'])).toList();
      paidEventIds = paidEventIds.toSet().toList();
      if (paidEventIds.length == 0) {
        setState(() {
          loadPayment = false;
        });
        return;
      }
      String ars = paidEventIds.toString();
      ars = ars.replaceAll('[', '(');
      ars = ars.replaceAll(']', ')');
      List<Map<String, dynamic>> res = await db.rawQuery(''
          'select ev.*, banner.img_path banner_url, location.img_path location_url '
          'FROM events as ev '
          'LEFT JOIN images as banner ON banner.related_type = \'event\' and banner.related_id = ev.event_id and banner.field = \'bannerUrl\' '
          'LEFT JOIN images as location ON location.related_type = \'event\' and location.related_id = ev.event_id and banner.field = \'locationUrl\' '
          'where ev.event_id in $ars ORDER BY ev.open_time DESC ;');

      /// events list from DB

      List<int> savedEventIds = List();
      Map<int, Event> eventMap = Map();
      res.forEach((item) {
        Event event = Event.fromMap(item);
        eventMap[event.id] = event;
        savedEventIds.add(event.id);
      });
      setState(() {
        myEvents.addAll(eventMap);
      });

      /// db -d baihgui, tolbor hiigdsen event ids
      paidEventIds.removeWhere((element) => savedEventIds.contains(element));
      if (paidEventIds.length == 0) {
        setState(() {
          loadPayment = false;
        });
        return;
      }
      getPaidEvents(paidEventIds);
      setState(() {
        loadMore = true;
      });
    } else {
      toast.show(json['message']);
    }
    setState(() {
      loadPayment = false;
    });
  }

  Future<void> getPaidEvents(List<int> eventIds) async {
    /// limit tawiagui, (eventuudee uzelgui 100, 200n eventiin tolbor tolchihgui bailgui dee :P)

    String queryString = '?';
    eventIds.forEach((element) {
      queryString += 'id_in=' + element.toString() + '&';
    });
    dynamic json = await api.get('${StaticUrl.getEventUrlwithDomain()}' + queryString, auth: false);
    if (json['code'] == 1000) {
      List<dynamic> list = json['data']['list'];
      list = list.map((event) => Event.fromJson(event)).toList();

      Map<int, Event> eventMap = Map();
      List<dynamic> result = List();
      await db.transaction((txn) async {
        ///TODO: if event has already inserted ignore it
        var batch = txn.batch();
        list.forEach((event) async {
          String bannerUrl = event.bannerUrls.length > 0 ? event.bannerUrls[0] : '';
          // await txn.insert('events', event.toMap());
          batch.insert('events', event.toMap());
          batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', event.id, 'bannerUrl', bannerUrl]);
          batch.rawInsert(
              'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', event.id, 'locationUrl', event.locationUrl]);

          eventMap[event.id] = event;
        });
        result = await batch.commit();
        setState(() {
          myEvents.addAll(eventMap);
          mEvents.addAll(eventMap);
          loadMore = false;
        });
      }).catchError((e) {
        toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
        Future.delayed(const Duration(milliseconds: 2000), () {
          exit(0);
        });
      });
    } else {
      toast.show(json['message']);
    }
  }

  ///
  Future<void> checkEvents() async {
    print('checkEvents called');
    if (checkEventsCalled) {
      return;
    }
    checkEventsCalled = true;
    List<Event> events = await Event().getEventList(1, 100);
    List<Map<String, int>> eventIds = List();
    events.forEach((ev) {
      eventIds.add({"id": ev.id});
    });
    Map<String, dynamic> params = {"list": eventIds};
    if(user.roleId == 8){
      params['operator'] = true;
    }
    String url = '${StaticUrl.getEventUrlwithDomain()}checklist';
    dynamic json = await api.post(url, params: params);
    if (json['code'] == 1000) {
      if (json['data']['success']) {
        List<dynamic> removed = json['data']['remove'];
        List<dynamic> added = json['data']['add'];

        /// DELETE all data FOR removed events
        if (removed.length > 0) {
          var distinct = removed.toSet().toList();
          String whereIn = distinct.toString().replaceFirst("[", "(").replaceFirst("]", ")");

          await db.transaction((txn) async {
            var batch = txn.batch();
            batch.rawQuery("DELETE FROM events WHERE event_id IN $whereIn;");

            batch.rawQuery("DELETE FROM images WHERE related_type = \'event\' and related_id IN $whereIn;");

            batch.rawQuery("DELETE FROM images WHERE related_type = \'speaker\' and related_id in "
                "(SELECT speaker_id FROM speakers WHERE event_id IN $whereIn);");
            batch.rawQuery("DELETE FROM images WHERE related_type = \'room\' and related_id in "
                "(SELECT room_id FROM rooms WHERE event_id IN $whereIn);");
            batch.rawQuery("DELETE FROM images WHERE related_type = \'participants\' and related_id in "
                "(SELECT participant_id FROM participants WHERE event_id IN $whereIn);");

            batch.rawQuery("DELETE FROM speaker_program WHERE speaker_id in "
                "(SELECT participant_id FROM participants WHERE event_id IN "
                "(SELECT speaker_id FROM speakers WHERE event_id IN $whereIn));");

            batch.rawQuery("DELETE FROM speakers WHERE event_id IN $whereIn;");
            batch.rawQuery("DELETE FROM rooms WHERE event_id IN $whereIn;");
            batch.rawQuery("DELETE FROM participants WHERE event_id IN $whereIn;");
            batch.rawQuery("DELETE FROM programs WHERE event_id IN $whereIn;");


            await batch.commit();
          }).catchError((e) {
            toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
            Future.delayed(const Duration(milliseconds: 2000), () {
              exit(0);
            });
          });
        }
        if (added.length > 0) {
          List<int> _added = added.cast<int>();
          var distinct = _added.toSet().toList();
          distinct.sort((a, b) => b.compareTo(a));
          if (distinct.length > 10) distinct = distinct.sublist(0, 10);
          loadAddedEvents(distinct);
        }
        if (removed.length > 0 || added.length > 0) {
          mEvents.clear();
          page = 1;
          initEvent();
        }
      } else {
        toast.show(json['data']['message']);
      }
    } else {
      toast.show('Шинэчлэл дуудахад алдаа гарлаа.');
    }
    checkEventsCalled = false;
  }

  delayedCheck() async {
    await Future.delayed(Duration(seconds: 20), checkEvents);
  }
}

T cast<T>(x) => x is T ? x : 0;

class Choice {
  const Choice({this.id, this.title, this.icon});
  final int id;
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(id: 1, title: 'Хувийн мэдээлэл', icon: Icons.account_circle),
  const Choice(id: 2, title: 'Мэдэгдлүүд', icon: Icons.notifications_rounded),
//  const Choice(title: 'Төлбөр', icon: Icons.payment),
  const Choice(id: 10, title: 'Гарах', icon: Icons.exit_to_app),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class EventUserWithInvoices {
  final int eventUserId;
  final int eventId;
  final String invoiceId;
  final int isPaid;
  final int amount;
  EventUserWithInvoices({this.eventId, this.eventUserId, this.invoiceId, this.isPaid, this.amount});
  factory EventUserWithInvoices.fromJson(Map<String, dynamic> json) {
    return EventUserWithInvoices(
      eventId: json.containsKey('event') && json['event'] != null ? json['event'] : 0,
      eventUserId: json.containsKey('event_user') && json['event_user'] != null ? json['event_user'] : 0,
      invoiceId: json.containsKey('invoice_number') && json['invoice_number'] != null ? json['invoice_number'] : '',
      isPaid: json.containsKey('paid') && json['paid'] != null
          ? json['paid'] == true
              ? 1
              : 0
          : 0,
      amount: json.containsKey('amount') && json['amount'] != null ? json['amount'] : 0,
    );
  }
  factory EventUserWithInvoices.fromMap(Map<String, dynamic> map) {
    return EventUserWithInvoices(
      eventId: map['event_id'],
      eventUserId: 0,
      invoiceId: map['invoice_id'],
      isPaid: map['is_paid'],
      amount: map['amount'],
    );
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    ('data: $data');
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print('notification: $notification');
  }

  // Or do other work.
  return Future<void>.value();
}
