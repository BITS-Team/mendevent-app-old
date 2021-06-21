import 'package:flutter/material.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modEventProgramQuestion.dart';
import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/pages/pageEventProgramDetails.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';

class EventProgramQuestionsPage extends StatefulWidget {
  static const routeName = '/eventProgramQuestionsPage';
  final Event event;
  final EventProgramItem program;
  final List<EventSpeaker> speakers;
  final Map<int, QuestionVote> votes;
//  bool isExpanded = false;

  EventProgramQuestionsPage({Key key, @required this.event, @required this.program, this.votes, this.speakers}) : super(key: key);
  @override
  EventProgramQuestionsPageState createState() {
    return EventProgramQuestionsPageState(event, program, votes, speakers);
  }
}

class EventProgramQuestionsPageState extends State<EventProgramQuestionsPage> with SingleTickerProviderStateMixin {
  Event mEvent;
  EventProgramItem mProgram;
  Map<int, QuestionVote> _mVotes;
  final List<EventSpeaker> speakers;

  User mUser;
  List<EventProgramQuestion> _mQuestions;
  List<EventProgramQuestion> confirmedQuestions;
  ScrollController _controller;

  EventProgramQuestionsPageState(this.mEvent, this.mProgram, this._mVotes, this.speakers);

  bool isRefreshingQuestion = true;
  int totalCreatedQuestions = 0;
  int page = 1;
  bool voting = false;
  Map<int, bool> votings = Map();

  @override
  void initState() {
    _mQuestions = List();
    confirmedQuestions = List();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  _afterLayout(_) async {
    await getConfirmedQuestions();
    // await apiQuestions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _scrollListener() async {
    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
      if (totalCreatedQuestions > (_mQuestions.length - confirmedQuestions.length)) {
        ++page;
        apiQuestions(page);
      }
    }
    if (_controller.offset <= _controller.position.minScrollExtent && !_controller.position.outOfRange) {
      ///TODO: fetch new Questions
    }
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
              'Хөтөлбөрийн асуултууд'.toUpperCase(),
              overflow: TextOverflow.fade,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            backgroundColor: Color(0xff021863),
          ),
          body: Column(
            children: <Widget>[
              drawTop(),
              drawTitleRefresh(),
              isRefreshingQuestion
                  ? Container(
                      child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                      ),
                    ))
                  : Container(),
              Expanded(
                child: drawBody(),
              )
            ],
          )),
    );
  }

  Container drawTop() {
    return Container(
      child: Image.asset('assets/header_top.png'),
    );
  }

  Container drawTitleRefresh() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Container(
                child: Text(
              mProgram.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xff021863), fontWeight: FontWeight.w500),
            )),
          ),
          Container(
              // alignment: Alignment.centerRight,
              width: 55,
              height: 55,
              // margin: EdgeInsets.only(right: 10),
              child: Center(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isRefreshingQuestion = true;
                      page = 1;
                    });
                    getConfirmedQuestions();
                  },
                  iconSize: 40,
                  icon: Icon(Icons.refresh, color: StaticData.blueLogo),
                ),
              ))
        ],
      ),
    );
  }

  Container questionItem(EventProgramQuestion item, int index) {
    String fromSpeaker = "";
    String sign = item.question.trim().lastIndexOf('?') != item.question.trim().length - 1 ? "?" : "";
    if (item.speakerId > 0) {
      // List<EventSpeaker> list = [...mPanelist, ...mSpeakers, ...mModerators]; // from Dart 2.3
      fromSpeaker = speakers.firstWhere((el) => el.id == item.speakerId).name;
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
                  child: Text('${item.question}$sign ${fromSpeaker != '' ? '\n($fromSpeaker)' : ''}',
                      style: item.isConfirmed() ? TextStyle(fontWeight: FontWeight.w600, color: StaticData.blueLogo) : TextStyle(fontWeight: FontWeight.w500)),
                )),
            Container(
              width: 10,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    tapVote(item, 'up');
                    setState(() {
                      votings[item.id] = true;
                    });
                  },
                  child: votings[item.id]
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                        )
                      : Container(
                          width: 30,
                          height: 30,
                          child: like
                              ? Image.asset('assets/like.png')
                              : Image.asset('assets/like_grey'
                                  '.png')),
                ),
                Container(
                  // color: Colors.green,
                  padding: EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    item.voteUp.toString(),
                    style: TextStyle(color: like ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
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
                    tapVote(item, 'down');
                    setState(() {
                      votings[item.id] = true;
                    });
                  },
                  child: votings[item.id]
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                        )
                      : Container(
                          width: 30,
                          height: 30,
                          margin: EdgeInsets.only(top: 8),
                          child: dislike
                              ? Image.asset('assets/dislike.png')
                              : Image.asset('assets/dislike_grey'
                                  '.png')),
                ),
                Container(
                  // color: Colors.green,
                  padding: EdgeInsets.only(right: 4),
                  child: Text(
                    item.voteDown.toString(),
                    style: TextStyle(color: dislike ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Container drawBody() {
    List<Widget> lst = List<Widget>();
    int index = 1;
    _mQuestions.forEach((el) {
      lst.add(questionItem(el, index));
      index++;
    });
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: ListView(controller: _controller, shrinkWrap: true, children: lst),
    );
  }

  void tapVote(EventProgramQuestion question, String vote) async {
    String url = '${StaticUrl.getEventVoteQuestionUrlwithDomain()}';
    Map<String, dynamic> params = {"eventId": mEvent.id, "programId": mProgram.id, "questionId": question.id, "vote": vote};
    dynamic json = await api.post(url, params: params);
    if (json['code'] == 1000) {
      if (json['data'].containsKey('result')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Уучлаарай!!"),
              content: new Text("Та хөтөлбөрт бүртгүүлсний дараа саналаа өгнө үү.."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Хаах"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
      if (_mVotes.containsKey(question.id)) {}
      QuestionVote qv = QuestionVote.fromJson(json['data']);
      String oldVote = _mVotes[question.id]?.vote ?? '';
      if (oldVote != '') {
        if (oldVote == 'down') {
          _mQuestions.firstWhere((element) => element.id == question.id).decVoteDown();
        } else if (oldVote == 'up') {
          _mQuestions.firstWhere((element) => element.id == question.id).decVoteUp();
        }
      }
      if (qv.vote == 'down') {
        _mQuestions.firstWhere((element) => element.id == question.id).incVoteDown();
      } else if (qv.vote == 'up') {
        _mQuestions.firstWhere((element) => element.id == question.id).incVoteUp();
      }

      setState(() {
        votings[question.id] = false;
        _mVotes[question.id] = QuestionVote.fromJson(json['data']);
      });
      // apiVotes();
    }
  }

  Future<void> getConfirmedQuestions() async {
    confirmedQuestions.clear();
    Map<String, dynamic> params = {
      "eventId": mEvent.id,
      "programId": mProgram.id,
      "hideAnswered": true,
      "status": "confirmed",
      "max": 20,
      "page": 1,
      "_sort": "rate:desc"
    };

    ///ehnii 20, TODO: response deer "total" irj baigaa, pagination hiih eseh
    String url = '${StaticUrl.getEventQuestionsUrlwithDomain()}/vote';
    dynamic json = await api.get(url, params: params);
    if (json['code'] == 1000) {
      json['data']['list'].forEach((el) {
        confirmedQuestions.add(EventProgramQuestion.fromJson(el));
      });
    } else {
      toast.show(json['message']);
    }
    apiQuestions(page);
  }

  Future<void> apiQuestions(page) async {
    if (page == 1) {
      _mQuestions.clear();
    }

    List<EventProgramQuestion> createdQuestions = List();
    Map<String, dynamic> params = {"eventId": mEvent.id, "programId": mProgram.id, "hideAnswered": true, "status": "created", "page": page};
    String url = '${StaticUrl.getEventQuestionsUrlwithDomain()}/vote';
    dynamic json = await api.get(url, params: params);
    if (json['code'] == 1000) {
      json['data']['list'].forEach((el) {
        createdQuestions.add(EventProgramQuestion.fromJson(el));
      });
      totalCreatedQuestions = json['data']['total'] ?? 0;
    } else {
      toast.show(json['message']);
    }
    List<EventProgramQuestion> allQuestions = List();
    if (page == 1) {
      allQuestions.addAll(confirmedQuestions);
      allQuestions.addAll(createdQuestions);
    } else {
      allQuestions.addAll(createdQuestions);
    }

    allQuestions.forEach((element) {
      votings[element.id] = false;
    });
    setState(() {
      _mQuestions.addAll(allQuestions);
      isRefreshingQuestion = false;
    });
  }
}
