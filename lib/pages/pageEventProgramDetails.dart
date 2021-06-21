import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modEventProgramQuestion.dart';
import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/pages/pageEventAttendance.dart';
import 'package:mend_doctor/pages/pageEventFileList.dart';
import 'package:mend_doctor/pages/pageEventProgramPoll.dart';
import 'package:mend_doctor/pages/pageEventProgramQuestions.dart';
import 'package:mend_doctor/pages/pageEventSpeakerDetails.dart';
import 'package:mend_doctor/pages/pagePdfFile.dart';
import 'package:mend_doctor/pages/pageQRscan.dart';
import 'package:mend_doctor/singletons/singletonEvent.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class EventProgramDetailsPage extends StatefulWidget {
  static const routeName = '/eventProgramDetailsPage';
  final Event event;
  final EventProgramItem program;


  EventProgramDetailsPage({Key key, @required this.event, @required this.program}) : super(key: key);

  @override
  EventProgramDetailsPageState createState() {
    return EventProgramDetailsPageState(event, program);
  }
}
///with SingleTickerProviderStateMixin
class EventProgramDetailsPageState extends State<EventProgramDetailsPage>  {
  Event event;
  User user;
  EventProgramItem mProgram;
  BuildContext scafContext;
  bool isExpanded = false;
  EventProgramDetailsPageState(this.event, this.mProgram);
  final storage = new FlutterSecureStorage();
  TextEditingController _txtNameController;
  TextEditingController _txtRegisterController;

  List<EventSpeaker> mPanelist = List<EventSpeaker>();
  List<EventSpeaker> mSpeakers = List<EventSpeaker>();
  List<EventSpeaker> mModerators = List<EventSpeaker>();

  List<EventSpeaker> allSpeakers = List();

  bool isLoadedData = false;
  bool isPanelOrSpeach;

  String _mQuestion = "";
  Map<String, EventSpeaker> mPeople = Map<String, EventSpeaker>();

  bool _isSentQuestion = false;
  List<EventProgramQuestion> _mQuestions;
  Map<int, QuestionVote> _mVotes;
  bool isRefreshingQuestion = false;

  bool _isAddedToSchedule = false;
  List<EventFile> mFiles;
  bool isShowFile = false;
  bool _loading = true;
  bool isOperator = false;


  @override
  void initState() {
    _txtNameController = TextEditingController();
    _txtRegisterController = TextEditingController();
    _mQuestions = List<EventProgramQuestion>();
    _mVotes = Map<int, QuestionVote>();
    mFiles = List();
    isPanelOrSpeach = mProgram.programType == 'Илтгэл' || mProgram.programType == 'Хэлэлцүүлэг';
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    super.initState();
    init();
    getSpeakers();
    getFileList();
  }

  _afterLayout(_) {
    setState(() {
      isRefreshingQuestion = true;
    });
    apiQuestions();
    apiSelfVotes();
    checkAddedMyProgram();
  }

  init() async {
    String mendUser = await storage.read(key: 'mendUser') ?? '';
    user = User.fromJson(jsonDecode(mendUser));
    setState(() {
      isOperator = user.roleId == 8;
    });
  }

  checkAddedMyProgram() async {
    Database db = await SQLiteHelper.instance.getDb();
    List row = await db.rawQuery('SELECT * FROM my_program WHERE program_id = ?', [mProgram.id]);
    bool b = false;
    if (row.length > 0) {
      b = true;
    }
    setState(() {
      _isAddedToSchedule = b;
    });
  }

  @override
  void dispose() {
    _txtNameController.dispose();
    _txtRegisterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final dynamic args = ModalRoute.of(context).settings.arguments;
    // mProgram = args['program'];
    // isPanelOrSpeach = mProgram.programType == 'Илтгэл' || mProgram.programType == 'Хэлэлцүүлэг';
    return WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            mProgram.title,
            overflow: TextOverflow.fade,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color(0xff021863),
        ),
        body: Builder(
          builder: (BuildContext context) {
            scafContext = context;
            return drawBody();
          },
        ),
      ),
    );
  }

  Container drawBody() {
    return Container(
        color: Color(0xFFFFFFFF),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image.asset('assets/header_top.png'),
            drawHeader(),

            isLoadedData ? drawSpeakers() : Container(),
//        Center(child: Text(program.title)),
            drawTopic(),
            isOperator ? drawQrScanButton() : Container(),
            isPanelOrSpeach ? drawAsking() : Container(),
            isPanelOrSpeach ? drawQuestions(_mQuestions) : Container(),
            isPanelOrSpeach ? drawAttendance() : Container(),
            isPanelOrSpeach ? drawPollDivision() : Container(),
            drawAddScheduleButton(),

            _loading ? Container() : drawFiles(mFiles),
            Container(
              height: 80,
            ),
          ],
        ));
  }

  Container drawHeader() {
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          children: <Widget>[
            Text(
              mProgram.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xff021863), fontWeight: FontWeight.w700),
            ),
            (mProgram.programType == "Илтгэл" || mProgram.programType == "Хэлэлцүүлэг")
                ? Text(
                    '(${mProgram.programType})',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xff021863), fontWeight: FontWeight.w500),
                  )
                : Container(),
          ],
        ));
  }

  GestureDetector drawSpeakerRow(EventSpeaker speaker) {
    return GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EventSpeakerDetailsPage(
                        event: event,
                        speaker: speaker,
                      )));
        },
        child: Container(
            padding: EdgeInsets.only(bottom: 20, left: 10, right: 10, top: 20),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Color(0xff021863),
                borderRadius: BorderRadius.all(Radius.circular(16)),
                boxShadow: [BoxShadow(color: Color(0x80000000), offset: Offset.fromDirection(0.5, 2), spreadRadius: 2, blurRadius: 10)]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    height: 60,
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      child: (speaker.picUrl != null && speaker.picUrl != "")
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(speaker.picUrl)}',
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
                Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            child: Text(
                          '${speaker.name}',
                          style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
                        )),
                        Container(
                          height: 10,
                        ),
                        Container(
                            child: Text(
                          '${speaker.position}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w400),
                        )),
                      ],
                    ))
              ],
            )));
  }

  Container drawSpeakers() {
    List<Widget> lst = List<Widget>();
    if (mModerators.length > 0) {
      lst.add(Container(
        margin: EdgeInsets.only(bottom: 20),
        alignment: Alignment.centerLeft,
        child: Text(
          'Модератор'.toUpperCase(),
          style: TextStyle(fontSize: 14, color: Color(0x80000000), fontWeight: FontWeight.w700),
        ),
      ));
      mModerators.forEach((speaker) {
        lst.add(drawSpeakerRow(speaker));
      });
    }
    if (mPanelist.length > 0) {
      lst.add(Container(
        margin: EdgeInsets.only(bottom: 20),
        alignment: Alignment.centerLeft,
        child: Text(
          'Панелист'.toUpperCase(),
          style: TextStyle(fontSize: 14, color: Color(0x80000000), fontWeight: FontWeight.w700),
        ),
      ));
      mPanelist.forEach((speaker) {
        lst.add(drawSpeakerRow(speaker));
      });
    }
    if (mSpeakers.length > 0) {
      lst.add(Container(
        margin: EdgeInsets.only(bottom: 10, top: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          'Илтгэгч'.toUpperCase(),
          style: TextStyle(fontSize: 14, color: Color(0x80000000), fontWeight: FontWeight.w700),
        ),
      ));
      mSpeakers.forEach((speaker) {
        lst.add(drawSpeakerRow(speaker));
      });
    }
//    Map<int, String> speaker = eventData.lstSpeakerProgram[event.id].programSpeakers[
//        mProgram.id]; //.forEach((k,v)=>print('#####$k : $v : ${eventData.lstSpeakersByEvent[event.id][k].name}'));
//
////    List<EventSpeaker> panelist = List<EventSpeaker>();
////    List<EventSpeaker> speakers = List<EventSpeaker>();
////    List<EventSpeaker> moderators = List<EventSpeaker>();
//    if (speaker.length > 0) {
//      speaker.forEach((id, role) {
//        switch (role) {
//          case 'speaker':
//            mSpeakers.add(eventData.lstSpeakersByEvent[event.id][id]);
//            break;
//          case 'panelist':
//            mPanelist.add(eventData.lstSpeakersByEvent[event.id][id]);
//            break;
//          case 'moderator':
//            mModerators.add(eventData.lstSpeakersByEvent[event.id][id]);
//            break;
//          default:
//            break;
//        }
//      });

//    }

    return Container(margin: EdgeInsets.only(left: 20, right: 20, top: 20), child: Column(children: lst));
  }

  Container drawTopic() {
    return Container(
        margin: EdgeInsets.only(bottom: 20, left: 20, top: 20, right: 20),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Агуулга'.toUpperCase(),
              style: TextStyle(fontSize: 14, color: Color(0x80000000), fontWeight: FontWeight.w700),
            ),
            Container(
              height: 15,
            ),
//            Text(
//              program.topic,
//              textAlign: TextAlign.start,
//              maxLines: 8,
//              style: TextStyle(fontSize: 14, color: Color(0x80000000), fontWeight: FontWeight.w400),
//            ),
            CustomAnimatedSize(topic: mProgram.topic),
//            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//              AnimatedSize(
//                  vsync: this,
//                  duration: const Duration(milliseconds: 500),
//                  child: new ConstrainedBox(
//                      constraints: isExpanded ? new BoxConstraints() : new BoxConstraints(maxHeight: 80.0),
//                      child: new Text(
//                        mProgram.topic,
//                        softWrap: true,
//                        overflow: TextOverflow.fade,
//                      ))),
//              mProgram.topic.length > 120
//                  ? (isExpanded
////                  ? new ConstrainedBox(constraints: new BoxConstraints())
//                      ? FlatButton(
//                          child: const Text(
//                            'хураангуй',
//                            style: TextStyle(fontSize: 12, color: Color(0xff021863), fontWeight: FontWeight.w500),
//                          ),
//                          onPressed: () => setState(() => isExpanded = false))
//                      : new FlatButton(
//                          child: const Text(
//                            'дэлгэрэнгүй',
//                            style: TextStyle(fontSize: 12, color: Color(0xff021863), fontWeight: FontWeight.w500),
//                          ),
//                          onPressed: () => setState(() => isExpanded = true)))
//                  : Container(),
//            ])
          ],
        ));
  }

  Column drawAsking() {
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 160,
            child: Stack(
              children: <Widget>[
                Container(
                    height: 160,
                    margin: EdgeInsets.only(left: 20, right: 20, top: 6),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                    child: TextField(
//                    onChanged: (text) {
////                      tempUser = text;
//                    },
//                    focusNode: _nameFocus,
//                    keyboardType: TextInputType.text,
//                    textInputAction: TextInputAction.next,
//                    onEditingComplete: () {
//                      _fieldFocusChange(
//                          context, _nameFocus, _passFocus);
//                    },
                      controller: _txtNameController,
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.left,
                      maxLength: 180,
//                    keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Асуултаа бичнэ үү...',
                        hintStyle: TextStyle(
                          color: Color(0x30000000),
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                        ),
                      ),
                    )),
                Container(
                  color: Color(0xFFFFFFFF),
                  margin: EdgeInsets.only(left: 40),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    'Асуулт илгээх'.toUpperCase(),
                    style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )),
        Container(
            child: Center(
                child: FlatButton(
                    onPressed: () {

                      if (_txtNameController.text.length > 0) {
                        _mQuestion = '${_txtNameController.text[0].toUpperCase()}${_txtNameController.text.substring(1).toLowerCase()}';
                        eventData.askingSpeakerId = 0;
                        askingQuestion();
                        // showSubmitDialog(_mQuestion);
                      }
                    },
                    child: Container(
                        padding: EdgeInsets.only(left: 50, right: 50, top: 16, bottom: 16),
                        decoration: BoxDecoration(color: sData.StaticData.blueLogo, borderRadius: BorderRadius.all(Radius.circular(12))),
                        child: Text(
                          'Илгээх'.toUpperCase(),
                          style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
                        ))))),
        Container(
          height: 30,
        ),
      ],
    );
  }

  Container questionItem(EventProgramQuestion item, int index) {
    String fromSpeaker = "";
    String sign = item.question.trim().lastIndexOf('?') != item.question.trim().length - 1 ? "?" : "";
    if(item.speakerId > 0) {
      // List<EventSpeaker> list = [...mPanelist, ...mSpeakers, ...mModerators]; // from Dart 2.3
      fromSpeaker = allSpeakers.firstWhere((el) => el.id == item.speakerId).name;
    }
    bool like = _mVotes.containsKey(item.id) && _mVotes[item.id].vote == 'up';
    bool dislike = _mVotes.containsKey(item.id) && _mVotes[item.id].vote == 'down';

    return Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                width: 0.7,
                color: Color(0x20000000),
              )),
        ),
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 2, top: 2),
        padding: EdgeInsets.only(bottom: 5, top: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
//              mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(width: 20, child: Text('$index)')),
            Flexible(
                fit: FlexFit.tight,
                child: Container(
                  child: Text('${item.question}$sign ${fromSpeaker != '' ? '\n($fromSpeaker)' : ''}'),
                )),
            Container(
              width: 10,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventProgramQuestionsPage(
                              event: event,
                              program: mProgram,
                              votes: _mVotes,
                              speakers: allSpeakers,
                            )));
                  },
                  child: Container(width: 30, height: 30, child: like ? Image.asset('assets/like.png') : Image.asset('assets/like_grey'
                      '.png')),
                ),
                Container(
                  // color: Colors.green,
                  padding: EdgeInsets.only(top: 8, left: 4),
                  child: Text(item.voteUp.toString(), style: TextStyle(color: like ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.w700),),
                ),
              ],
            ),

            Container(
              width: 10,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventProgramQuestionsPage(
                              event: event,
                              program: mProgram,
                              votes: _mVotes,
                              speakers: allSpeakers,
                            )));
                  },
                  child: Container(width: 30, height: 30,margin: EdgeInsets.only(top: 8), child: dislike ? Image.asset('assets/dislike.png') : Image.asset('assets/dislike_grey'
                      '.png')),
                ),
                Container(
                  // color: Colors.green,
                  padding: EdgeInsets.only(right: 4),
                  child: Text(item.voteDown.toString(), style: TextStyle(color: dislike ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.w700),),
                ),
              ],
            ),

          ],
        )
    );
  }

  Container drawQuestions(List<EventProgramQuestion> q) {
    List<Widget> lst = List<Widget>();
    int index = 1;
    q.forEach((el) {lst.add(questionItem(el, index)); index++;});

    return Container(
        child: Column(
//      physics: const NeverScrollableScrollPhysics(),
//      shrinkWrap: true,
      children: <Widget>[
        Container(
//          color: Colors.red,
//          padding: EdgeInsets.only(top:10, bottom: 10),
          height: 45,
          margin: EdgeInsets.only(left: 20, bottom: 10, right: 20),
          child: Row(
            children: <Widget>[
              Container(
                child: Text(
                  'Асуултууд'.toUpperCase(),
                  style: TextStyle(fontSize: 14, color: Color(0x80000000), fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(flex: 1, child: Container()),
              InkWell(
                  onTap: () {
                    setState(() {
                      isRefreshingQuestion = true;
                    });
                    apiQuestions();
                  },
                  child: Container(child: Icon(Icons.refresh, size: 35, color: sData.StaticData.blueLogo))),
              Container(
                width: 50,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EventProgramQuestionsPage(
                                event: event,
                                program: mProgram,
                                votes: _mVotes,
                            speakers: allSpeakers,
                              )));
                },
                child: Container(
                    height: 45,
//                  color: Colors.green,
                    padding: EdgeInsets.only(left: 30),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Жагсаалт'.toUpperCase(),
                          style: TextStyle(fontSize: 14, color: Color(0x80000000), fontWeight: FontWeight.w700),
                        ),
                        Container(
                            child: Icon(
                          Icons.navigate_next,
                          color: Color(0x80000000),
                        ))
                      ],
                    )),
              ),
            ],
          ),
        ),
        Container(
          height: 15,
        ),
        !isRefreshingQuestion
            ? (lst.length != 0
                ? Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                    child: Column(
                      children: lst,
                    ))
                : Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Одоогоор зөвшөөрөгдсөн асуулт байхгүй байна...',
                      style: TextStyle(fontSize: 14, color: Color(0x60000000), fontWeight: FontWeight.w400),
                    ),
                  ))
            : Container(
                child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                ),
              )),
      ],
    ));
  }

  Container drawAttendance() {
    return Container(
        margin: EdgeInsets.only(top: 40, bottom: 40),
        child: FlatButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventAttendancePage(
                            event: event,
                            program: mProgram,
                          )));
            },
            child: Container(
                width: MediaQuery.of(context).size.width - 120,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 50, right: 50, top: 16, bottom: 16),
                decoration: BoxDecoration(color: sData.StaticData.yellowLogo, borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Text(
                  'Ирц бүртгүүлэх'.toUpperCase(),
                  style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
                ))));
  }

  Container drawPollDivision() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: FlatButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventProgramPollPage(
                            event: event,
                            program: mProgram,
                          )));
            },
            child: Container(
                width: MediaQuery.of(context).size.width - 120,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 50, right: 50, top: 16, bottom: 16),
                decoration: BoxDecoration(color: sData.StaticData.blueLogo, borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Text(
                  'Санал асуулга'.toUpperCase(),
                  style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
                ))));
  }

  Container drawAddScheduleButton() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: FlatButton(
            onPressed: () {
//              Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (context) => EventProgramPollPage(
//                            event: event,
//                            user: user,
//                            program: mProgram,
//                          )));
              addToSchedule();
            },
            child: Container(
                width: MediaQuery.of(context).size.width - 120,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 50, right: 50, top: 16, bottom: 16),
                decoration: BoxDecoration(color: sData.StaticData.blueLogo, borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Row(
                  children: <Widget>[
                    Icon(_isAddedToSchedule ? Icons.remove_circle_outline : Icons.add_circle_outline, color: Colors.white),
                    Container(
                      width: 10,
                    ),
                    Text(
                      'Миний хөтөлбөр'.toUpperCase(),
                      style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
                    )
                  ],
                ))));
  }

  Container drawFiles(List<EventFile> files) {
    if(files.length == 0){
      return Container();
    }
    List<Widget> lst = List<Widget>();
    lst.add(Container(child: Text('Холбоотой файлууд:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: sData.StaticData.blueLogo))));
    int index = 1;
    for (EventFile ff in files) {
      lst.add(GestureDetector(
        onTap: () {
          setState(() {
            isShowFile = true;
          });
          createFileOfPdfUrl(ff).then((f) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (rContext) => PdfFilePageState(
                          event,
                          user,
                          ff.fileName,
                          f.path,
                        )));
            isShowFile = false;
          });
        },
        child: Container(
            margin: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
            padding: EdgeInsets.only(left: 10, top: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: Color(0x20000000),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child:
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 20, bottom: 0),
                        width: 40,
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: sData.StaticData.blueLogo,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(right: 20, bottom: 0),
                          alignment: Alignment.centerLeft,
                          // width: 40,
                          child: Text(
                            '${ff.fileName}',
                            style: TextStyle(
                              color: sData.StaticData.blueLogo,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ],
                ),
              // ],
            )),
      // )
    );

      index++;
    }
    if (lst.length == 1) {
      lst.add(Container(
          child: Text(
        'Хоосон байна.',
        style: TextStyle(
          color: sData.StaticData.blueLogo,
          fontSize: 15,
        ),
      )));
    }
//    return !isShowFile
    return Container(child: Column(children: lst));
  }

  Container drawQrScanButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: FlatButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => QRViewScan(event: event, program: mProgram)));
          },
          child: Container(
              width: MediaQuery.of(context).size.width - 120,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 50, right: 50, top: 16, bottom: 16),
              decoration: BoxDecoration(color: sData.StaticData.yellowLogo, borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Text(
                'Ирц бүртгэх'.toUpperCase(),
                style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
              )))
    );

  }

  Future<void> apiQuestions() async {
    ///Top 5 rated questions
    List<EventProgramQuestion> questions = List();

    Map<String, dynamic> params = {"eventId": event.id, "programId": mProgram.id, "hideAnswered" : true, "status" : "confirmed",
      "max": 5, "page": 1, "_sort": "rate:desc"};
    /// зөвшөөрөгдсөн болон хариулагдаагүй асуултууд
    dynamic json = await api.get('${StaticUrl.getEventQuestionsUrlwithDomain()}/vote', params: params);
    if(json['code'] == 1000){
      json['data']['list'].forEach((el){
        questions.add(EventProgramQuestion.fromJson(el));
      });
    } else {
      toast.show(json['message']);
    }

    setState(() {
      _mQuestions = questions;
      isRefreshingQuestion = false;
    });
  }

  Future<void> getFileList() async {
    mFiles.clear();
    Map<String, dynamic> params = {"event": event.id, "program_id": mProgram.id};
    String url = '${StaticUrl.getEventFilesUrlwithDomain()}/list';
    dynamic res = await api.get(url, params: params);
    if(res['code'] == 1000){
      List<EventFile> files = List();
      res['data'].forEach((f){
        files.add(EventFile.fromJson(f));
      });
      mFiles.addAll(files);
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> askingQuestion() async {
    showSubmitDialog(_mQuestion);
  }

  void showSubmitDialog(String question) {
    String title = 'Асуулт:'.toUpperCase();
    String msg = '';

    EventSpeaker nullSpeaker = EventSpeaker(name: 'Бүгдээс асуух', id: -1);
    Map<String, EventSpeaker> people = Map<String, EventSpeaker>();
    people['Бүгдээс асуух'] = nullSpeaker;
    people.addAll(mSpeakers.asMap().map((id, speaker) => MapEntry(speaker.name, speaker)));
    people.addAll(mModerators.asMap().map((id, speaker) => MapEntry(speaker.name, speaker)));
    people.addAll(mPanelist.asMap().map((id, speaker) => MapEntry(speaker.name, speaker)));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          backgroundColor: Color(0xFFb4b4b4),
          title: new Text(title, style: TextStyle(color: Color(0x80000000), fontSize: 15)),
//          content: content,
          content: SingleChildScrollView(
              child: Material(
                  child: MyDialogContent(
            people: people,
            question: question,
          ))),
//          new Text(msg,
//              style: TextStyle(color: Color(0xFF021863), fontSize: 13)),
          actions: <Widget>[
            FlatButton(
              child: Container(
                padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFF021863),
                ),
                child: Text("Илгээх".toUpperCase(), style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14)),
              ),
              onPressed: () {
                //Navigator.of(context).pop();
//                print('#########${eventData.lstSpeakersByEvent[event.id][eventData.askingSpeakerId].name}');
                sendQuestion(question);
              },
            ),
            FlatButton(
              child: new Text("Болих", style: TextStyle(color: Color(0xFF021863), fontSize: 13)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      barrierDismissible: true,
    );
  }

  Future<void> sendQuestion(String question) async {

    Map<String, dynamic> jsonMap = {'event': event.id, 'question': question, 'event_program': mProgram.id};
    if (eventData.askingSpeakerId > 0) jsonMap['eventspeaker'] = eventData.askingSpeakerId;
    String url = '${StaticUrl.getEventQuestionsUrlwithDomain()}';
    dynamic json = await api.post(url, params: jsonMap);
    setState(() {
      _txtNameController.text = "";
    });
    Navigator.of(context).pop();
    apiQuestions();
    if(json['code'] == 1000){
      if(json['data'].containsKey('result')){
        // always false if response data belongs 'result' field
        //that means is not registered for attendance on program
        toast.show('Хөтөлбөрт бүртгүүлээгүй байна.');
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventProgramQuestionsPage(
                  event: event,
                  program: mProgram,
                  votes: _mVotes,
                  speakers: allSpeakers,
                )));
      }
    } else {
      toast.show(json['message']);
    }
  }

  Future<void> apiSelfVotes() async {
    ///Program-iin huwid buh self votes awchrah
    List<QuestionVote> votes = List();
    Map<String, dynamic> params = {"programId": mProgram.id};
    dynamic json = await api.get('${StaticUrl.getEventQuestionVotesUrlwithDomain()}', params: params);
    if(json['code'] == 1000 && json['data']['success']){
      json['data']['data'].forEach((el){
        votes.add(QuestionVote.fromJson(el));
      });
    } else {
      toast.show(json['message']);
    }

    setState(() {
      _mVotes = Map.fromIterable(votes, key: (vote) => vote.questionId, value: (vote) => vote);
    });
  }

  Future<void> getSpeakers() async {
    mPanelist.clear();
    mSpeakers.clear();
    mModerators.clear();
    Database db = await SQLiteHelper.instance.getDb();

    /// get speakers of the EventProgram
    List<Map<String, dynamic>> recordSpeakers = await db.rawQuery(
      'select sp.role, s.*, i.img_path picture '
      'from speaker_program sp '
      'left join speakers s on sp.speaker_id = s.speaker_id '
      'left join (SELECT * FROM images where related_type = "speaker") i on i.related_id = s.speaker_id '
      'where sp.program_id = ${mProgram.id}',
    );
//    print('##### speakers count: ${recordSpeakers.length}');
    recordSpeakers.forEach((record) {
      switch (record['role']) {
        case 'speaker':
          mSpeakers.add(EventSpeaker.fromMap(record));
          break;
        case 'panelist':
          mPanelist.add(EventSpeaker.fromMap(record));
          break;
        case 'moderator':
          mModerators.add(EventSpeaker.fromMap(record));
          break;
        default:
          break;
      }
    });
    if (!mounted) return;
    allSpeakers.addAll(mPanelist);
    allSpeakers.addAll(mSpeakers);
    allSpeakers.addAll(mModerators);
    setState(() {
      isLoadedData = true;
    });
  }

  addToSchedule() async {
    /// TODO: change query => INSERT ON DUPLICATE KEY UPDATE
    Database db = await SQLiteHelper.instance.getDb();
    String txtSnack = 'Миний хөтөлбөр';
    if (_isAddedToSchedule) {
      txtSnack += 'өөс хасагдлаа';
      await db.rawDelete('DELETE FROM my_program WHERE event_id = ? and program_id = ?', [mProgram.eventId, mProgram.id]);
    } else {
      List rows = await db.rawQuery('SELECT * FROM my_program WHERE event_id =? and program_id = ?', [mProgram.eventId, mProgram.id]);
      if (rows.length > 0) {
        // print('program already added. name: ${mProgram.title}');
      } else {
        await db.rawInsert("INSERT INTO my_program(event_id, program_id) VALUES (?,?)", [mProgram.eventId, mProgram.id]);
      }
      txtSnack += 'т нэмэгдлээ';
    }
    setState(() {
      _isAddedToSchedule = !_isAddedToSchedule;
    });
    Scaffold.of(scafContext).showSnackBar(SnackBar(
      content: Text(
        txtSnack,
        style: TextStyle(color: Colors.white, fontSize: 15),
        textAlign: TextAlign.center,
      ),
      backgroundColor: sData.StaticData.blueLogo,
      duration: Duration(seconds: 1),
    ));
  }

  Future<File> createFileOfPdfUrl(EventFile ff) async {
    final url = StaticUrl.getDomainPort() + ff.filePath;
    final filename = ff.fileName;
    String dir = (await getApplicationDocumentsDirectory()).path;

    if (FileSystemEntity.typeSync('$dir/$filename.pdf') == FileSystemEntityType.notFound) {
      File file = new File('$dir/$filename.pdf');
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
//    File file = new File('$dir/$filename.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      File file = File('$dir/$filename.pdf');
      return file;
    }
  }
}

class QuestionVote {
  final int voteId;
  final int questionId;
  String vote;

  QuestionVote({this.voteId, this.questionId, this.vote});
  factory QuestionVote.fromJson(Map<String, dynamic> json) {
    return QuestionVote(
      voteId: json.containsKey('vote_id') && json['vote_id'] != null ? json['vote_id'] : 0,
      questionId: json.containsKey('question_id') && json['question_id'] != null ? json['question_id'] : 0,
      vote: json.containsKey('action_type') && json['action_type'] != null ? json['action_type'] : '',
    );
  }
}

//Stateful popup window
class MyDialogContent extends StatefulWidget {
  MyDialogContent({
    Key key,
    this.question,
    this.people,
  }) : super(key: key);

  final String question;
  final Map<String, EventSpeaker> people;

  @override
  _MyDialogContentState createState() => new _MyDialogContentState(people);
}

class _MyDialogContentState extends State<MyDialogContent> {
  final Map<String, EventSpeaker> people;
  EventSpeaker _speaker;
  _MyDialogContentState(this.people);
  @override
  void initState() {
    super.initState();
    _speaker = people['Сонгох..'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFFb4b4b4),
//        width: MediaQuery.of(context).size.width - 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 40),
                child: Text(
                  widget.question,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Color(0xFF021863), fontSize: 15, fontWeight: FontWeight.w500),
                )),
            Container(child: Text('Хэнээс:'.toUpperCase(), style: TextStyle(color: Color(0x80000000), fontSize: 15))),
            Container(
                height: 40,
                child: DropdownButton<EventSpeaker>(
                  isDense: true,
                  elevation: 2,
                  value: _speaker,
                  items: widget.people.values.map((EventSpeaker speaker) {
                    return DropdownMenuItem<EventSpeaker>(
                      value: speaker,
                      child: Container(
                          child: Text(
                        speaker.name,
                        style: TextStyle(color: Color(0xFF021863), fontSize: 15, fontWeight: FontWeight.w500),
                      )),
                    );
                  }).toList(),
                  onChanged: (EventSpeaker speaker) {
                    setState(() {
                      _speaker = speaker;
                      eventData.askingSpeakerId = _speaker.id;
                    });
                  },
                  isExpanded: true,
                )),
          ],
        ));
  }
}

class CustomAnimatedSize extends StatefulWidget {
  final String topic;
  CustomAnimatedSize({Key key, this.topic}) : super(key: key);
  @override
  _CustomAnimatedSizeState createState() => _CustomAnimatedSizeState(this.topic);
}
class _CustomAnimatedSizeState extends State<CustomAnimatedSize> with SingleTickerProviderStateMixin {
  String topic;
  bool isExpanded = false;
  _CustomAnimatedSizeState(this.topic);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        AnimatedSize(
            vsync: this,
            duration: const Duration(milliseconds: 500),
            child: new ConstrainedBox(
                constraints: isExpanded ? new BoxConstraints() : new BoxConstraints(maxHeight: 80.0),
                child: new Text(
                  topic,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ))),
        topic.length > 120
            ? (isExpanded
//                  ? new ConstrainedBox(constraints: new BoxConstraints())
            ? FlatButton(
            child: const Text(
              'хураангуй',
              style: TextStyle(fontSize: 12, color: Color(0xff021863), fontWeight: FontWeight.w500),
            ),
            onPressed: () => setState(() => isExpanded = false))
            : new FlatButton(
            child: const Text(
              'дэлгэрэнгүй',
              style: TextStyle(fontSize: 12, color: Color(0xff021863), fontWeight: FontWeight.w500),
            ),
            onPressed: () => setState(() => isExpanded = true)))
            : Container(),
      ])
    );
  }

}