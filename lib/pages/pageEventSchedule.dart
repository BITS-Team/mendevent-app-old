import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mend_doctor/pages/pageEventProgramDetails.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/models/modEventRoom.dart';

import 'package:mend_doctor/utils/staticData.dart' as sData;

class EventSchedule extends StatefulWidget {
  static const routeName = '/eventSchedulePage';
  final Event event;
  final User user;
  final List<EventProgramItem> programs;
  final List<EventRoom> eventRooms;
  final TabController tabController;
  EventSchedule({Key key, @required this.event, @required this.user, this.programs, this.eventRooms, this.tabController})
      : super(key: key);
  @override
  _EventScheduleState createState() => _EventScheduleState(event, user, programs, eventRooms, tabController);
}

class _EventScheduleState extends State<EventSchedule> with TickerProviderStateMixin {
  static const String TAG = 'EventSchedule';
  Event event;
  User user;
  List<EventProgramItem> programs;
  List<EventRoom> eventRooms;

  _EventScheduleState(this.event, this.user, this.programs,this.eventRooms, this.tabController);

  TabController tabController;
  TabController _nestedTabController;

  List<String> eventDays;

  @override
  void initState() {
    eventDays = getEventDays();
    _nestedTabController = new TabController(length: eventDays.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    super.initState();
  }

  _afterLayout(_) {
    eventDays.map((String day) {
      return drawTimeTable(day);
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
    if (_nestedTabController != null) _nestedTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: ListView(
      children: <Widget>[
        Container(
          child: Image.asset(
            'assets/header_top.png',
            fit: BoxFit.fitWidth,
          ),
        ),
        Container(
          child: drawTab(),
        )
      ],
    )));
  }

  Column drawTab() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          height: 40,
          child: TabBar(
              controller: _nestedTabController,
              indicatorColor: sData.StaticData.blueLogo,
              labelColor: sData.StaticData.blueLogo,
              unselectedLabelColor: Colors.black54,
              isScrollable: true,
              tabs: getEventDays().map((String day) {
                return Tab(
                  text: formatDateOfEvent(day),
                );
              }).toList()),
        ),
        Container(
            decoration: BoxDecoration(
              borderRadius: sData.StaticData.r16,
              color: Color(0x20000000),
            ),
            height: screenHeight - 191,
            margin: EdgeInsets.only(
              top: 10,
              left: 16.0,
              right: 16.0,
            ),
            padding: EdgeInsets.all(10),
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: TabBarView(
                  controller: _nestedTabController,
                  children: getEventDays().map((String day) {
                    return drawTimeTable(day);
                  }).toList()),
            ))
      ],
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
        child: Container(
          decoration: BoxDecoration(
            color: programType == 3 || programType == 4
                ? Color(0xFF8BC34A)
                : programType == 5 ? Color(0xFFFDB92E) : Color(0xFFFFFFFF),
            borderRadius: sData.StaticData.r10,
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
                    style: TextStyle(fontSize: 15, color: sData.StaticData.blueLogo, fontWeight: FontWeight.w600),
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
        ));
  }

  Container drawVerticalLineWithCircle(int type, double height) {
    return Container(
        width: 10,
//        color: Colors.red,
        child: Stack(
          children: <Widget>[
            Container(
              color: sData.StaticData.blueLogo,
              width: 2,
              margin: EdgeInsets.only(
                  left: 4, right: 4, bottom: type == 0 ? height / 2 : 0, top: type == 1 ? height / 2 : 0),
            ),
            Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(width: 2, color: sData.StaticData.blueLogo)),
              ),
            )
          ],
        ));
  }

  ScrollConfiguration drawTimeTable(String day) {
    List<Widget> lst = List<Widget>();
    lst.add(Container(height: 20));
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
              Container(width: 10, child: drawVerticalLineWithCircle(type, (90 * programs1.length).toDouble())),
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
                      ))
            ],
          ));
      lst.add(con);
    });

    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView(
        children: lst,
      ),
    );
  }

  String formatDateOfEvent(String day) {
    List<String> sp = day.split('.');
    return '${sp[0]}-р сарын ${sp[1]}';
  }

  List<String> getEventDays() {
    List<String> days = List<String>();
    programs.forEach((program) => days.add(program.getOpenDate()));
    List<String> d = days.toSet().toList();
    return d;
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
