import "dart:collection";

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'package:mend_doctor/pages/pageEventSpeakerDetails.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:sqflite/sqflite.dart';

class EventSpeakerListPage extends StatefulWidget {
  static const routeName = '/eventSpeakerListPage';
  final Event event;
  EventSpeakerListPage({Key key, @required this.event}) : super(key: key);
  @override
  EventSpeakerListPageState createState() {
    return EventSpeakerListPageState(event);
  }
}

class EventSpeakerListPageState extends State<EventSpeakerListPage> with SingleTickerProviderStateMixin {
  Event event;

  EventSpeakerListPageState(this.event);

  List<EventSpeaker> speakers;
  Database db;

  @override
  void initState() {
    speakers = List();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
    init();
  }

  Future<void> init() async {
    db = await SQLiteHelper.instance.getDb();
    List<EventSpeaker> list = List();
    List<Map<String, dynamic>> recordSpeakers = await db.rawQuery(
      'select r.event_id, r.speaker_id, r.name, r.description, r.is_featured, r.career, r.position, i.img_path picture '
      'from speakers r '
      'left join (SELECT * FROM images where related_type = "speaker") i on i.related_id = r.speaker_id '
      'where r.event_id = ${event.id} ',
    );
    print('recordSpeakers.length = ${recordSpeakers.length}');
    recordSpeakers.forEach((record) {
      list.add(EventSpeaker.fromMap(record));
    });

    setState(() {
      speakers.addAll(list);
    });
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
            "Илтгэгчид",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color(0xff021863),
        ),
        body: drawBody(),
      ),
    );
  }

  ListView drawBody() {
    return ListView(
      children: <Widget>[
        Container(
          child: Image.asset(
            'assets/header_top.png',
            fit: BoxFit.fitWidth,
          ),
        ),
        Container(
          height: 15,
        ),
        drawSpeakers(),
      ],
    );
  }

  Container drawSpeakers() {
    Map<String, List<Widget>> byTypes = Map<String, List<Widget>>();
    var careers = SplayTreeMap<int, String>();
    int idx = 1;
    speakers.forEach((speaker) {
      List<String> career = speaker.career.split('#');
      //TODO: BackEnd deer bazah
      if (career.length < 2) {
        career.insert(0, '1000');
        if (career[1] == '') {
          career[1] = 'Бусад';
        }
      }
      print('$idx career $career');
      if (!byTypes.containsKey(career[1])) {
        byTypes[career[1]] = List();
      }
      careers[int.parse(career[0])] = career[1];
      byTypes[career[1]].add(conSpeaker(speaker));
      idx++;
    });

    List<Widget> column = List<Widget>();
    careers.forEach((number, type) {
      column.add(
        Text(
          '$type: '.toUpperCase(),
          style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 2, 24, 99), fontWeight: FontWeight.w900),
        ),
      );
      column.add(
        Container(
          height: 10,
        ),
      );
      column.add(
        Container(
            width: MediaQuery.of(context).size.width - 70,
            child: Column(
              children: <Widget>[
                SizedBox(
                    width: MediaQuery.of(context).size.width - 70,
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: byTypes[type],
                    )),
              ],
            )),
      );
    });

    return Container(
      child: Container(
          padding: EdgeInsets.only(left: 20, right: 10),
          alignment: Alignment.topCenter,
          child: Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.stretch, children: column)),
    );
  }

  GestureDetector conSpeaker(EventSpeaker es) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventSpeakerDetailsPage(
                        event: event,
                        speaker: es,
                      )));
        },
        child: Container(
            width: (MediaQuery.of(context).size.width - 70) / 3 - 20,
            child: Column(children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 0),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.7,
                      color: Color(0x33000000),
                    ),
                    borderRadius: BorderRadius.all(const Radius.circular(29)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(const Radius.circular(29)),
                    child: es.hasPic()
                        ? CachedNetworkImage(
                            imageUrl: '${StaticUrl.getDomainPort()}${es.picUrl}',
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
                            errorWidget: (context, url, error) => Center(
                                child: Text(es.name.substring(0, 1),
                                    style: TextStyle(color: sData.StaticData.blueLogo, fontWeight: FontWeight.w700, fontSize: 40))),
                          )
                        : Image.asset('assets/default_speaker.png'),
                  )),
              Container(
                  child: Text(
                '${es.name}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w700),
              )),
              Container(
                  height: 40,
                  child: Text(
                    '${es.position}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0x80000000),
                    ),
                  ))
            ])));
  }
}
