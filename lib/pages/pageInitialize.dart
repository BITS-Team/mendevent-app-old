import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventParticipant.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modEventRoom.dart';
import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'package:mend_doctor/pages/pageEventList.dart';
import 'package:mend_doctor/pages/pageLogin.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:mend_doctor/widgets/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class InitializePage extends StatefulWidget {
  @override
  InitializePageState createState() {
    return InitializePageState();
  }
}

/// Get Init data from REST and save to SQLite: last 10 events
/// Start LoginPage after loaded data
/// TODO: Tuhain event data shinechleh uildel nemeh(in event details page)
/// TODO: Het ert zarlagdsan EVENT missing boloh bolomjtoi. Solution: Event publish hiisen date-tei API gargah. "lastEventId"-g solih => "lastPublishDate"
/// parameter ashiglah
class InitializePageState extends State<InitializePage> {
  BuildContext mContext;
  final storage = new FlutterSecureStorage();

  List<Event> lEvents = List();
  List<EventSpeaker> lSpeakers = List();
  List<EventProgramItem> lProgramItems = List();
  List<EventParticipant> lParticipants = List();
  List<EventRoom> lRooms = List();
  List<SpeakerProgram> lSpeakerProgram = List();

  int apiStatusCode = 0; // API duudahad aldaa garwal, TODO: saijruulah
  double indicatorValue = 0.0; // dummy progress metric
  int lastEventId;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  _afterLayout(_) {
//    apiEvents(0);
    loadInitData();
    // testDB();
    // clearDB();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    double height = MediaQuery.of(context).size.height;
    return Container(
        color: Color(0xff021863),
        child: Column(
          children: <Widget>[
            Container(
              height: height * 0.2,
            ),
            Center(
              child: AppLoader(),
            ),
            Container(margin: EdgeInsets.only(left: 60, right: 60), padding: EdgeInsets.all(30), child: Image.asset('assets/mend_event_text.png')),
            Container(
              height: 180,
            ),
            apiStatusCode == 0
                ? Container(
                    child: Center(
                        child: new Container(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
//              color: Colors.white,
                      child: new LinearProgressIndicator(
                        value: indicatorValue,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                        backgroundColor: Color(0xFFfdb92e),
                      ),
                    )),
                  )
                : Center(
                    child: Column(
                    children: <Widget>[
                      Container(
                        width: 300,
                        child: Text(
                          "Уучлаарай, серверээс хариу өгсөнгүй.\n"
                          "Та интернетээ шалгаад хэвийн бол манай харилцагчийн албанд хандана уу...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                      Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FlatButton(
                            child: Text(
                              "Гарах",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            onPressed: () {
                              exit(1);
                            },
                          ),
                          FlatButton(
                            child: Text(
                              "Дахин ачаалах",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                apiStatusCode = 0;
                              });
                              loadInitData();
                            },
                          )
                        ],
                      )),
                    ],
                  )),
          ],
        ));
  }

  loadInitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastEventId = prefs.getInt('lastEventId') ?? 0;
    dynamic cnt = await getNewEventCount();
    if( cnt == null){
      //TODO: offline ajilluulah eseh
    } else if (cnt == 0) {
      //TODO: missing events baigaa eseh, baiwal last 10 awchrah :)
      afterLoaded();
    } else {
      lEvents = await getEvents();
      List<String> eventIds = lEvents.map((ev) => ev.id.toString()).toList();
      // eventIds = [eventIds[0]];
      lSpeakers = await getSpeakers(eventIds);
      lProgramItems = await getPrograms(eventIds);
      lSpeakerProgram = await getSpeakerProgram(eventIds);
      lParticipants = await getParticipants(eventIds);
      lRooms = await getRooms(eventIds);
      if (!hasError) {
        save2db(cnt);
      }
    }
  }

  Future<int> getNewEventCount() async {
    Map<String, dynamic> params = {'id_gt': lastEventId, 'is_draft': false};
    dynamic json = await api.get('${StaticUrl.getEventUrlwithDomain()}count', params: params, auth: false);
    int cnt = 0;
    if (json['code'] == 1000) {
      cnt = json['data'];
      return cnt;
    } else {
      if (json['code'] != 1002) {
        setState(() {
          apiStatusCode = 1;
        });
      }
      toast.show(json['message']);
      return null;
    }

  }

  Future<List<Event>> getEvents() async {
    Map<String, dynamic> params = {'id_gt': lastEventId, '_limit': 10, '_sort': 'id:desc', 'is_draft': false};
    dynamic json = await api.get('${StaticUrl.getEventUrlwithDomain()}', params: params, auth: false);
    if (json['code'] == 1000) {
      List<dynamic> list = json['data']['list'];
      setState(() {
        indicatorValue = 0.13;
      });
      return list.map((event) => Event.fromJson(event)).toList();
    } else {
      toast.show(json['message']);
      hasError = true;
      return List();
    }
  }

  Future<List<EventSpeaker>> getSpeakers(List<String> eventIds) async {
    List<EventSpeaker> speakers = List();
    String url = '${StaticUrl.getEventSpeakerUrlwithDomain()}/list';
    for (String id in eventIds) {
      dynamic json = await api.get(url, params: {'events': id}, auth: false);
      if (json['code'] == 1000) {
        if (json['data'].length > 0) {
          json['data'].forEach((sp) => {speakers.add(EventSpeaker.fromJson(sp))});
        }
      } else {
        toast.show(json['message']);
        hasError = true;
        break;
      }
    }
    setState(() {
      indicatorValue = 0.4;
    });
    return speakers;
  }

  Future<List<EventProgramItem>> getPrograms(List<String> eventIds) async {
    List<EventProgramItem> programs = List();
    String url = '${StaticUrl.getEventSchedulesUrlwithDomain()}/list';
    for (String id in eventIds) {
      dynamic json = await api.get(url, params: {'events': id}, auth: false);
      if (json['code'] == 1000) {
        if (json['data'].length > 0) {
          json['data'].forEach((sp) => {programs.add(EventProgramItem.fromJson(sp))});
        }
      } else {
        toast.show(json['message']);
        hasError = true;
        break;
      }
    }
    setState(() {
      indicatorValue = 0.58;
    });
    return programs;
  }

  Future<List<SpeakerProgram>> getSpeakerProgram(List<String> eventIds) async {
    List<SpeakerProgram> programs = List();
    String url = '${StaticUrl.getEventSpeakerProgramUrlwithDomain()}/list';
    for (String id in eventIds) {
      dynamic json = await api.get(url, params: {'events': id}, auth: false);
      if (json['code'] == 1000 && json['data']['result']) {
        if (json['data']['data'].length > 0) {
          json['data']['data'].forEach((sp) => {programs.add(SpeakerProgram.fromJson(sp))});
        }
      } else {
        toast.show(json['message'] ?? json['data']['message']);
        hasError = true;
        break;
      }
    }
    setState(() {
      indicatorValue = 0.81;
    });
    return programs;
  }

  Future<List<EventParticipant>> getParticipants(List<String> eventIds) async {
    List<EventParticipant> programs = List();
    String url = '${StaticUrl.getEventParticipantsUrlwithDomain()}/list';
    for (String id in eventIds) {
      dynamic json = await api.get(url, params: {'events': id}, auth: false);
      if (json['code'] == 1000) {
        if (json['data'].length > 0) {
          json['data'].forEach((sp) => {programs.add(EventParticipant.fromJson(sp))});
        }
      } else {
        toast.show(json['message']);
        hasError = true;
        break;
      }
    }
    setState(() {
      indicatorValue = 0.9;
    });
    return programs;
  }

  Future<List<EventRoom>> getRooms(List<String> eventIds) async {
    List<EventRoom> programs = List();
    String url = '${StaticUrl.getEventRoomsUrlwithDomain()}/list';
    for (String id in eventIds) {
      dynamic json = await api.get(url, params: {'events': id}, auth: false);
      if (json['code'] == 1000) {
        if (json['data'].length > 0) {
          json['data'].forEach((sp) => {programs.add(EventRoom.fromJson(sp))});
        }
      } else {
        toast.show(json['message']);
        hasError = true;
        break;
      }
    }
    setState(() {
      indicatorValue = 0.96;
    });
    return programs;
  }

  void save2db(int cnt) async {

    Database db = await SQLiteHelper.instance.getDb();
    int v = await db.getVersion();
    List<dynamic> result = List();
    await db.transaction((txn) async {
      var batch = txn.batch();
      lEvents.forEach((event) async {
        String bannerUrl = event.bannerUrls.length > 0 ? event.bannerUrls[0] : '';
        // await txn.insert('events', event.toMap());
        batch.insert('events', event.toMap());
        batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', event.id, 'bannerUrl', bannerUrl]);
        batch.rawInsert(
            'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', event.id, 'locationUrl', event.locationUrl]);
      });
      lParticipants.forEach((participant) async {
        batch.insert('participants', participant.toMap());
        batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)',
            ['participant', participant.id, 'bannerUrl', participant.bannerUrl]);
      });
      lSpeakers.forEach((speaker) async {
        batch.insert('speakers', speaker.toMap());
        batch.rawInsert(
            'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['speaker', speaker.id, 'picUrl', speaker.picUrl]);
      });
      lProgramItems.forEach((programItem) async {
        batch.insert('programs', programItem.toMap());
      });
      lSpeakerProgram.forEach((sp) async {
        batch.insert('speaker_program', sp.toMap());
      });
      lRooms.forEach((room) async {
        batch.insert('rooms', room.toMap());
        batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['room', room.id, 'locationImg', room.locationImg]);
      });

      if((cnt - lEvents.length) > 0){
        /// lEvents.last.id = minimum ID of fetched events
        batch.insert('missing', {'first_id' : lEvents.last.id, 'missing_count': cnt - lEvents.length, 'last_event_id': lastEventId});
      }
      result = await batch.commit();

    }).catchError((e) {
      toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
      Future.delayed(const Duration(milliseconds: 2000), () {
        exit(0);
      });
    });

    if (result.length > 0) {
      setState(() {
        indicatorValue = 0.999;
      });

      if(lEvents.length > 0){
        lastEventId = lEvents[0].id;
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt('lastEventId', lastEventId);
      }

      afterLoaded();
    } else {
      //Nothing do
    }
  }



//    Future.delayed(const Duration(milliseconds: 1000), (){
//      setState((){
//        Navigator.push(mContext, MaterialPageRoute(builder: (context) => IntroScreen()));
//      });
//    });

  afterLoaded() async {
    try{
      String jwt = await storage.read(key: 'mendJwt') ?? '';
      if (jwt != '') {
        Navigator.pushReplacement(mContext, MaterialPageRoute(builder: (context) => EventListPage()));
      } else {
        Navigator.pushReplacement(mContext, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } catch(e){
      // await storage.delete(key: 'mendJwt');
      Navigator.pushReplacement(mContext, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}

class SpeakerProgram {
  final int speakerId;
  final int programId;
  final String role;
  final int eventId;
  SpeakerProgram({this.speakerId, this.programId, this.role, this.eventId});
  factory SpeakerProgram.fromJson(Map<String, dynamic> json) {
    return SpeakerProgram(
      speakerId: json.containsKey('event_speaker') && json['event_speaker'] != null ? json['event_speaker'] : 0,
      programId: json.containsKey('event_program') && json['event_program'] != null ? json['event_program'] : 0,
      role: json.containsKey('role') && json['role'] != null ? json['role'] : '',
      eventId: json.containsKey('event') && json['event'] != null ? json['event'] : 0,
    );
  }

  ///SQLite

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'speaker_id': this.speakerId, 'program_id': this.programId, 'event_id': this.eventId, 'role': this.role};
    return map;
  }

  factory SpeakerProgram.fromMap(Map<String, dynamic> map) {
    return SpeakerProgram(
      speakerId: map['speaker_id'],
      programId: map['program_id'],
      role: map['role'],
      eventId: map['event_id'],
    );
  }
}

/// For Testing
void testDB() async {
  print('testDB##############');

  Database db = await SQLiteHelper.instance.getDb();

  try {
    // await db.rawInsert('INSERT INTO invoices (event_id, invoice_id, amount, invoice_number) VALUES(?,?, ?, ?)', [215, 12, 50000, 'INVOICE_NUMBER']);
    // int insert = await db.rawInsert('INSERT INTO dummy (tect) VALUES(?)', ['INVOICE_NUMBER']);
    // await db.rawDelete('DELETE FROM my_program WHERE event_id = ?', [215]);

    List<Map> list = await db.rawQuery('Select count(s.id) cnt from speakers s where s.event_id = 223 and s.is_featured = 1;');
    print('missing: ' + list.toString());
  } catch (e) {
    print('testDB: ' + e.toString());
  }

}
void clearDB() async {
  print('clearDB##############');
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setInt('lastEventId', 0);
  Database db = await SQLiteHelper.instance.getDb();
  try {
    db.rawDelete('DELETE FROM events;');
    db.rawDelete('DELETE FROM speakers;');
    db.rawDelete('DELETE FROM participants;');
    db.rawDelete('DELETE FROM programs;');
    db.rawDelete('DELETE FROM rooms;');
    db.rawDelete('DELETE FROM invoices;');
    db.rawDelete('DELETE FROM images;');
    db.rawDelete('DELETE FROM notifications;');
    db.rawDelete('DELETE FROM speaker_program;');
    db.rawDelete('DELETE FROM missing;');
    print('successfully reset');
  } catch( e) {
    print('DB clearing error: ' + e.toString());
  }
}