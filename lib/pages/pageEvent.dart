import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventParticipant.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modEventRoom.dart';
import 'package:mend_doctor/pages/pageEventFileList.dart';
import 'package:mend_doctor/pages/pageEventInfo.dart';
import 'package:mend_doctor/pages/pageEventSchedule.dart';
import 'package:mend_doctor/pages/pageInitialize.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:sqflite/sqflite.dart';

class EventPage extends StatefulWidget {
  static const routeName = '/eventPage';
  final Event event;
  EventPage({Key key, @required this.event}) : super(key: key);
  @override
  EventPageState createState() {
    // TODO: implement createState
    return EventPageState(event);
  }
}

class EventPageState extends State<EventPage> with SingleTickerProviderStateMixin {
  static final myTabbedPageKey = new GlobalKey<EventPageState>();
  Event event;
  EventPageState(this.event);

  TabController _tabController;

  List<EventRoom> eventRooms;
  List<EventParticipant> participants;
  List<EventProgramItem> programs;

  String mainOrganizer;
  bool isLoadedData = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    eventRooms = List();
    participants = List();
    programs = List();
    mainOrganizer = '';

    _tabController = new TabController(vsync: this, length: 3);

    super.initState();
    getData();
  }

  _afterLayout(_) {}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return Future(() => false);
        }
        return Future(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${event.name}",
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color.fromARGB(255, 2, 24, 99),
        ),
        bottomNavigationBar: PreferredSize(
          preferredSize: Size(80, 67),
          child: Container(
//            color: Color.fromARGB(255, 2, 24, 99),
              height: 67,
              child:
//            Container(),
                  TabBar(
                tabs: [
                  Container(
                    height: 40,
                    child: Tab(
                      icon: new Icon(Icons.widgets),
                    ),
                  ),
                  Container(
                    height: 40,
                    child: Tab(
                      icon: Icon(Icons.schedule),
                    ),
                  ),
                  Container(
                    height: 40,
                    child: Tab(
                      icon: Icon(Icons.attach_file),
                    ),
                  ),
                ],
                controller: _tabController,
                labelColor: Color.fromARGB(255, 2, 24, 99),
                unselectedLabelColor: Color.fromARGB(255, 253, 185, 46),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.all(5.0),
                indicatorColor: Color.fromARGB(255, 2, 24, 99),
              )),
        ),
        body: Center(child: drawBody(context, event)),
      ),
    );
  }

  Container drawBody(BuildContext context, Event event) {
    return new Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(top: 0),
      child: TabBarView(
        controller: _tabController,
        children: [
          isLoadedData
              ? EventInfo(
                  event: event,
                  participants: participants,
                  mainOrganizer: mainOrganizer,
                  rooms: eventRooms,
                  tabController: _tabController,
                )
              : Container(),
          isLoadedData
              ? EventSchedule(
                  event: event,
                  programs: programs,
                  eventRooms: eventRooms,
                  tabController: _tabController,
                )
              : Container(),
//          EventPeople(event: event, user: user),
          isLoadedData ? EventFilePage(event: event, programs: programs) : Container(),
        ],
      ),
    );
  }

  Future<void> getData() async {
    Database db = await SQLiteHelper.instance.getDb();

    /// get participants of the Event
    List<Map<String, dynamic>> participantCount = await db.rawQuery('Select count(id) cnt from participants where event_id = ${event.id}');
    if (participantCount.length > 0 && participantCount[0]['cnt'] > 0) {
      List<Map<String, dynamic>> recordParticipants = await db.rawQuery(
        'select p.participant_id id, p.name, "" role, p.description, p.meta, p.participant_type, "" type, i.img_path banner '
        'from participants p '
        'left join (SELECT * FROM images where related_type = "participant") i on i.related_id = p.participant_id '
        'where p.event_id = ${event.id}',
      );
      ///TODO: check id list from API
      recordParticipants.forEach((record) {
        if (record['participant_type'] == "Ерөнхий зохион байгуулагч") {
          mainOrganizer = record['name'];
        }
        participants.add(EventParticipant.fromJson(record));
      });
    } else {
      Map<String, dynamic> params = {'event': event.id};
      dynamic json = await api.get('${StaticUrl.getEventParticipantsUrlwithDomain()}/list', params: params, auth: false);
      if (json['code'] == 1000) {
        if (json['data'].length > 0) {
          json['data'].forEach((sp) => {participants.add(EventParticipant.fromJson(sp))});
          await db.transaction((txn) async {
            var batch = txn.batch();
            participants.forEach((participant) async {
              batch.insert('participants', participant.toMap());
              batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)',
                  ['participant', participant.id, 'bannerUrl', participant.bannerUrl]);
            });
            await batch.commit();
          }).catchError((e) {
            toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
            Future.delayed(const Duration(milliseconds: 2000), () {
              exit(0);
            });
          });
        }
      } else {
        toast.show('Ивээн тэтгэгчдийн мэдээлэл олдсонгүй');
      }
    }

    /// get rooms of the Event
    List<Map<String, dynamic>> roomCount = await db.rawQuery('Select count(id) cnt from rooms where event_id = ${event.id}');
    if (roomCount.length > 0 && roomCount[0]['cnt'] > 0) {
      List<Map<String, dynamic>> recordRooms = await db.rawQuery(
        'select r.room_id id, r.name roomname, r.event_id event, r.number room_number, r.location room_location, i.img_path room_location_img '
        'from rooms r '
        'left join (SELECT * FROM images where related_type = "room") i on i.related_id = r.room_id '
        'where r.event_id = ${event.id}',
      );
      recordRooms.forEach((record) {
        eventRooms.add(EventRoom.fromJson(record));
      });
    } else {
      Map<String, dynamic> params = {'event': event.id};
      dynamic json = await api.get('${StaticUrl.getEventRoomsUrlwithDomain()}/list', params: params, auth: false);
      if (json['code'] == 1000) {
        if (json['data'].length > 0) {
          json['data'].forEach((sp) => {eventRooms.add(EventRoom.fromJson(sp))});
          await db.transaction((txn) async {
            var batch = txn.batch();
            eventRooms.forEach((room) async {
              batch.insert('rooms', room.toMap());
              batch.rawInsert(
                  'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['room', room.id, 'locationImg', room.locationImg]);
            });
            await batch.commit();
          }).catchError((e) {
            toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
            Future.delayed(const Duration(milliseconds: 2000), () {
              exit(0);
            });
          });
        }
      } else {
        toast.show('Хурлын танхимуудын мэдээлэл олдсонгүй');
      }
    }

    /// get speakers of the Event
    /// DEPRECATED
    // List<Map<String, dynamic>> recordSpeakers = await db.rawQuery(
    //   'select r.event_id, r.speaker_id, r.name, r.description, r.is_featured, r.career, r.position, i.img_path picture '
    //   'from speakers r '
    //   'left join (SELECT * FROM images where related_type = "speaker") i on i.related_id = r.speaker_id '
    //   'where r.event_id = ${event.id}',
    // );
    // recordSpeakers.forEach((record) {
    //   speakers.add(EventSpeaker.fromMap(record));
    // });

    /// get programs of the Event-
    List<Map<String, dynamic>> programCount = await db.rawQuery('Select count(id) cnt from programs where event_id = ${event.id}');
    if (programCount.length > 0 && programCount[0]['cnt'] > 0) {
      List<Map<String, dynamic>> recordPrograms = await db.rawQuery(
        'select r.event_id, r.program_id, r.title, r.topic, r.open_time, r.close_time, r.description, r.program_type, r.room_id '
        'from programs r '
        'where r.event_id = ${event.id} '
        'order by r.open_time asc',
      );
      recordPrograms.forEach((record) {
        programs.add(EventProgramItem.fromMap(record));
      });
    } else {
      Map<String, dynamic> params = {'event': event.id};
      dynamic json = await api.get('${StaticUrl.getEventSchedulesUrlwithDomain()}/list', params: params, auth: false);
      if (json['code'] == 1000) {
        if (json['data'].length > 0) {
          json['data'].forEach((sp) => {programs.add(EventProgramItem.fromJson(sp))});
          await db.transaction((txn) async {
            var batch = txn.batch();
            programs.forEach((programItem) async {
              batch.insert('programs', programItem.toMap());
            });
            await batch.commit();
          }).catchError((e) {
            toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
            Future.delayed(const Duration(milliseconds: 2000), () {
              exit(0);
            });
          });
        }
      } else {
        toast.show(json['message']);
      }
    }

    List<Map<String, dynamic>> speakerProgramCount = await db.rawQuery('SELECT COUNT(id) cnt FROM speaker_program WHERE event_id = ${event.id}');
    if (!(speakerProgramCount.length > 0 && speakerProgramCount[0]['cnt'] > 0)) {
      List<SpeakerProgram> programs = List();
      dynamic json = await api.get('${StaticUrl.getEventSpeakerProgramUrlwithDomain()}/list', params: {'event': event.id}, auth: false);
      if (json['code'] == 1000 && json['data']['result']) {
        if (json['data']['data'].length > 0) {
          json['data']['data'].forEach((sp) => {programs.add(SpeakerProgram.fromJson(sp))});
          await db.transaction((txn) async {
            var batch = txn.batch();
            programs.forEach((sp) async {
              batch.insert('speaker_program', sp.toMap());
            });
            await batch.commit();
          }).catchError((e) {
            toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
            Future.delayed(const Duration(milliseconds: 2000), () {
              exit(0);
            });
          });
        }
      } else {
        toast.show(json['message'] ?? json['data']['message']);
      }
    }


    if (!mounted) return;
    setState(() {
      isLoadedData = true;
    });
  }
}
