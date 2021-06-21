import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/models/modEventRoom.dart';
import 'package:mend_doctor/pages/pageEventProgramDetails.dart';

import 'package:mend_doctor/utils/staticData.dart';

class MyPrograms extends StatefulWidget {
  static const routeName = '/myProgramsPage';
  final int eventId;
  MyPrograms({this.eventId}): super();
  @override
  MyProgramsState createState() =>
      MyProgramsState(this.eventId);
}

class MyProgramsState extends State<MyPrograms> {
  List<EventProgramItem> programs;
  List<EventRoom> eventRooms;
  int eventId;
  MyProgramsState(this.eventId);
  bool loaded = false;
  Event event;
  User user;
  final storage = new FlutterSecureStorage();
  @override
  void initState() {
    programs = List();
    eventRooms = List();

//    eventDays = getEventDays();
//    _nestedTabController = new TabController(length: eventDays.length, vsync: this);
//    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    setInit();
    super.initState();
  }

  void setInit() async {
    ///TODO: error uuswel LoginPage ruu usergeh
    String jsonString = await storage.read(key: 'mendUser');
    user = User.fromJson(jsonDecode(jsonString));
    getPrograms();
  }

  getPrograms() async {
    Database db = await SQLiteHelper.instance.getDb();
    List rows = await db.rawQuery("SELECT r.event_id, r.program_id, r.title, r.topic, r.open_time, r.close_time, r.description, r.program_type, r.room_id "
        "FROM my_program mp "
        "LEFT JOIN programs r ON r.program_id = mp.program_id "
        "WHERE mp.event_id = ? "
        "order by r.open_time asc", [eventId]);
    rows.forEach((record) {
      programs.add(EventProgramItem.fromMap(record));
    });
    /// get rooms of the Event
    List<Map<String, dynamic>> recordRooms = await db.rawQuery(
      'select r.room_id id, r.name roomname, r.event_id event, r.number room_number, r.location room_location, i.img_path room_location_img '
          'from rooms r '
          'left join (SELECT * FROM images where related_type = "room") i on i.related_id = r.room_id '
          'where r.event_id = ${eventId}',
    );
    recordRooms.forEach((record) {
      eventRooms.add(EventRoom.fromJson(record));
    });
    var eventRow = await db.rawQuery('SELECT * FROM events WHERE event_id = ?', [eventId]);
    if(eventRow.length > 0) {
      event = Event.fromMap(eventRow[0]);
    } else {
      ///nothing :)
    }
    if(!mounted) return;
    setState((){
      loaded =true;
    });
  }

  removeProgram(EventProgramItem program) async {
    programs.remove(program);
    Database db = await SQLiteHelper.instance.getDb();
    await db.rawDelete("DELETE FROM my_program WHERE program_id = ?", [program.id]);
    setState((){
      loaded = true;
    });
  }

  List<String> getEventDays() {
    List<String> days = List<String>();
    programs.forEach((program) => days.add(program.getOpenDate()));
    List<String> d = days.toSet().toList();
    return d;
  }
  String formatDateOfEvent(String day) {
    List<String> sp = day.split('.');
    return '${sp[0]}-р сарын ${sp[1]}';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Миний хөтөлбөр',
            overflow: TextOverflow.fade,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color(0xff021863),
        ),
        body: Builder(
          builder: (BuildContext context){
            return loaded ? drawPrograms() : Container();
          },
        ),
      ),
    );
  }


  Container drawPrograms(){
    List<Widget> lst = List<Widget>();
    lst.add(Container(height: 20));
    getEventDays().forEach((String day) {
      lst.add(Padding(padding: EdgeInsets.all(8.0), child: Text(formatDateOfEvent(day), textAlign: TextAlign.center, style: TextStyle(
        color: StaticData.blueLogo, fontSize: 18, fontWeight: FontWeight.w800
      ),)));
      List<DateTime> times = programs
          .where((program) => program.getOpenDate() == day)
          .map((program) => program.startTime)
          .toList()
          .toSet()
          .toList();
      times.forEach((time) {
        List<EventProgramItem> programs1 = List<EventProgramItem>();
        programs.where((program) => program.getOpenDate() == day).forEach((program) {
          if (time == program.startTime) {
            programs1.add(program);
          }
        });

        int type = times.first == time ? 1 : time == times.last ? 0 : 2;
        Container con = Container(
            height: programs1.length == 1 ? 94 : (90 * programs1.length).toDouble() + 9,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 50,
                    child: Center(
                      child: Text(
                        '${DateFormat.Hm().format(time)}',
                        style: TextStyle(fontSize: 15, color: Color(0xb8000000), fontWeight: FontWeight.w900),
                      ),
                    )),
//                Container(width: 10, child: drawVerticalLineWithCircle(type, (90 * programs1.length).toDouble())),
                Flexible(
                    flex: 1,
                    child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: programs1.map((program) {
  //                            print('${program.title}');
                              return drawProgramRow(program);
                            }).toList())
                    )),

              ],
            ));
        lst.add(con);
      });
    });


    return Container(
      padding: EdgeInsets.only(left: 10, right: 20),
      child: ListView(
          children: lst
      )
    );

  }
  GestureDetector drawProgramRow(EventProgramItem program) {
    // 1 - speach, 2 - panel, 3 - special program, 4 - breaktime, 5 - entertainment,  0 - none,empty or others,
    int programType = program.programType == 'Илтгэл'
        ? 1
        : program.programType == 'Хэлэлцүүлэг'
        ? 2
        : program.programType == 'Тусгай хөтөлбөр'
        ? 3
        : program.programType == 'Цайны цаг' ? 4 : program.programType == 'Энтэртайнмэнт' ? 5 : 0;
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventProgramDetailsPage(
                    event: event,
                    program: program,
                  )));
        },
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: programType == 3 || programType == 4
                      ? Color(0xFF8BC34A)
                      : programType == 5 ? Color(0xFFFDB92E) : Color(0xFFFFFFFF),
                  borderRadius: StaticData.r10,
                ),
                margin: EdgeInsets.only(top: 1, bottom: 1),
                padding: EdgeInsets.only(left: 20, top: 6, bottom: 6, right: 10),
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
//              height: 9,
                      ),
                    ),
                    Container(
                        height: 48,
                        child: Text(
                          '${program.title}',
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                          style: TextStyle(fontSize: 15, color: StaticData.blueLogo, fontWeight: FontWeight.w600),
                        )),
                    Flexible(
                      flex: 1,
                      child: Container(
//              height: 9,
                      ),
                    ),
                    Text(
                      '${eventRooms.firstWhere((room) => room.id == program.room, orElse: () => EventRoom(id: 0, roomNumber: "")).roomNumber.toUpperCase()}',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w600),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
//              height: 9,
                      ),
                    ),
                  ],
                ),
              ),
            )
            ,
            Container(
                width: 30,
                child: IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: (){
                    removeProgram(program);
                  },
                  color: StaticData.yellowLogo,
                )
            )
          ]
        )
        );
  }
}