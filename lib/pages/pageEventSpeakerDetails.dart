import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'package:mend_doctor/pages/pageEventProgramDetails.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:sqflite/sqflite.dart';

class EventSpeakerDetailsPage extends StatefulWidget {
  static const routeName = '/eventSpeakerDetailsPage';
  final Event event;
  final EventSpeaker speaker;
  EventSpeakerDetailsPage({Key key, @required this.event, @required this.speaker})
      : super(key: key);
  @override
  EventSpeakerDetailsPageState createState() {
    return EventSpeakerDetailsPageState(event, speaker);
  }
}

class EventSpeakerDetailsPageState extends State<EventSpeakerDetailsPage> with SingleTickerProviderStateMixin {
  Event event;
  EventSpeaker speaker;
  EventSpeakerDetailsPageState(this.event, this.speaker);

  Map<int, String> rooms = Map();
  Map<EventProgramItem, String> programRole = Map<EventProgramItem, String>();
  bool isLoaded = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    getDatas();
    super.initState();
  }

  _afterLayout(_) {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
//            "${speaker.name}",
              "Илтгэгч",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            backgroundColor: Color(0xff021863),
          ),
          body: ListView(
            children: <Widget>[
              Container(
                child: Image.asset(
                  'assets/header_top.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              drawSpeakerProfile(),
              isLoaded ? drawSpeakerPrograms() : Container(),
            ],
          )),
    );
  }

  Container drawSpeakerProfile() {
    return Container(
//      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Container(
//         padding: EdgeInsets.only(bottom: 30),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 0),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(50)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(50)),
                      child: speaker.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${speaker.picUrl}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
//                                            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.colorBurn)
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                  width: 50,
                                  height: 50,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                                    ),
                                  )),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Image.asset('assets/default_speaker.png'),
                    )),
                Container(
                  width: 10,
                ),
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          speaker.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xEE000000),
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                        Text(
                          speaker.position,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0x80000000),
                          ),
                        )
                      ],
                    ))
              ],
            ),
            Container(
                child: Text(
              speaker.desc,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0x80000000),
              ),
            )),
            Container(
              height: 15,
            ),
            Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Оролцох хөтөлбөрүүд:".toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: sData.StaticData.blueLogo,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Container drawSpeakerPrograms() {
    List<Widget> lst = List<Widget>();
    programRole.forEach((item, role) {
      lst.add(GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => EventProgramDetailsPage(
                          event: event,
                          program: item,
                        )));
            // Navigator.pushNamed(
            //   context,
            //   '/eventProgramDetailsPage',
            //   arguments: {'event': event, 'program': item}
            // );
          },
          child: Container(
              height: 94,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(borderRadius: sData.StaticData.r10, color: Color(0x16000000)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      width: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text(
                              '${item.getOpenDate()} өдөр',
                              style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xb8000000),
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Center(
                              child: Text(
                            '${item.getOpenTime()}',
                            style: TextStyle(fontSize: 12, color: Color(0xb8000000), fontWeight: FontWeight.w900),
                          )),
                        ],
                      )),
                  Container(
                    width: 0.7,
                    color: Color(0xAA000000),
                    margin: EdgeInsets.only(left: 4),
                  ),
                  Flexible(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    role == 'moderator'
                                        ? 'Модератор'.toUpperCase()
                                        : role == 'speaker' ? 'Илтгэгч'.toUpperCase() : '',
                                    maxLines: 1,
                                    style:
                                        TextStyle(fontSize: 14, color: Color(0xEE000000), fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${item.title}',
                                    maxLines: 2,
                                    overflow: TextOverflow.fade,
                                    style:
                                        TextStyle(fontSize: 12, color: Color(0xb8000000), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  '${rooms[item.room].toUpperCase()}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 12, color: Color(0xff021863), fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          )))
                ],
              ))));
    });

//    lst.add(Container(
//      height: 180,
//    ));

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: lst,
      ),
    );
  }

  Future<void> getDatas() async {
    Database db = await SQLiteHelper.instance.getDb();

    /// get programs with role of the Speaker
    List<Map<String, dynamic>> recordProgramsOfSpeaker = await db.rawQuery(
      'select sp.role, p.*, r.name roomname '
      'from speakers s '
      'left join speaker_program sp on sp.speaker_id = s.speaker_id '
      'left join programs p on p.program_id = sp.program_id '
      'left join rooms r on r.room_id = p.room_id '
      'where s.event_id = ${event.id} and s.speaker_id = ${speaker.id} '
      'order by p.open_time',
    );
    recordProgramsOfSpeaker.forEach((record) {
      EventProgramItem epi = EventProgramItem.fromMap(record);
      rooms[epi.room] = record['roomname'];
      programRole[epi] = record['role'];
    });
    if (!mounted) return;
    setState(() {
      isLoaded = true;
    });
  }
}
