import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mend_doctor/models/lstExhibitionsList.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventExhibition.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';

class ExhibitionPage extends StatefulWidget {
  static const routeName = '/eventPage';
  final Event event;
  final User user;
  final int numberExhib;
  final bool paid;
  ExhibitionPage({Key key, @required this.event,
    @required this.user, this.numberExhib, this.paid}) : super(key: key);

  @override
  ExhibitionPageState createState() {
    // TODO: need improvement
    return ExhibitionPageState(event, user, numberExhib, paid);
  }
}

class ExhibitionPageState extends State<ExhibitionPage> {
  Event event;
  User user;
  int numberExhib;
  bool paid;
  ExhibitionPageState(this.event, this.user, this.numberExhib, this.paid);

  ExhibitionList exhibList;
  Map<int, VoteOfExhib> exhibVotes;
  bool isLoadedExhib = false;
  bool isLoadedVotes = false;

  ///
  Map<int, VoteByUser> _mVotes = Map();

  /// exhibition_id, up|down, isTapped
  Map<int, Map<String, bool>> _isClicked;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    //    _mVotes = Map<int, Vote>();
    exhibVotes = Map();
    _isClicked = Map<int, Map<String, bool>>();
    super.initState();
  }

  _afterLayout(_) {
    apiExhibitions();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Үзэсгэлэн",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color.fromARGB(255, 2, 24, 99),
        ),
        body: Container(
//          padding: EdgeInsets.only(left: 10, right: 10),
          child:
//          _mVotes != null ?
          RefreshIndicator(onRefresh: _refreshVotes, child: drawBody())
//              : Container(
////                  width: 50,
////                  height: 50,
//                  child: Center(
//                  child: CircularProgressIndicator(
//                    strokeWidth: 1,
//                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
//                  ),
//                )),
        ));
  }

  /// Listview scroll down refresh
  Future<void> _refreshVotes() async {
    apiExhibitions();
  }

  ListView drawBody() {
    List<Widget> lst = [];
    lst.add(Container(
      child: Image.asset('assets/header_top.png'),
    ));

    if (numberExhib > 0) {
      String titleProgram = 'Үзэсгэлэн';
      Container conTitle = Container(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Center(
              child: Text(titleProgram.toUpperCase(),
                  style: TextStyle(
                    color: sData.StaticData.blueLogo,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ))));

      lst.add(conTitle);
//      eventData.lstExhibitions[event.id].forEach((programId, mapExhibition) {
      for (int i = 0; i < numberExhib; i++) {
        lst.add(drawExhibitionWidget(i));
//        Container conTopic = Container(
//            padding: EdgeInsets.only(left: 30, bottom: 10, right: 30),
//            child: Center(
//              child: Text(programId != 0 ? eventData.lstProgramsByEvent[event.id][programId].topic : '',
//                  textAlign: TextAlign.center,
//                  style: TextStyle(
//                    color: sData.StaticData.blueLogo,
//                    fontSize: 14,
//                    fontWeight: FontWeight.w700,
//                  )),
//            ));
//        lst.add(conTopic);
//        eventData.lstExhibitions[event.id][programId].values
//            .forEach((exhibition) => lst.add(drawExhibitionWidget(exhibition)));
      }
    }
    lst.add(Container(
      height: 60,
    ));
    return ListView(
      children: lst,
    );
  }

  Container drawExhibitionWidget(int i) {
    return Container(
        child: Column(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width - 20,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    child: Text(isLoadedExhib ? exhibList.list[i].title : 'Зураг${i + 1}',
                        style: TextStyle(
                          color: sData.StaticData.blueLogo,
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                        ))),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
              ],
            )),
        Container(
          height: 250,
          decoration:
              BoxDecoration(border: Border.all(width: 0.7, style: BorderStyle.solid, color: sData.StaticData.blueLogo)),
          child: isLoadedExhib
              ? CachedNetworkImage(
                  imageUrl: '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(exhibList.list[i].imgUrl)}',
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
              : Container(color: Colors.white70),
        ),
        drawVote(i),
      ],
    ));
  }

  Container drawVote(int i) {
    return Container(
        padding: EdgeInsets.only(top: 5, bottom: 20),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            isLoadedExhib
                ? Container(
                    padding: EdgeInsets.only(
                      left: 30,
                    ),
                    child: Text(
                        exhibList.list[i].doctor != null
                            ? 'Оруулсан: ${exhibList.list[i].doctor.firstName} ${exhibList.list[i].doctor.lastName}'
                            : '',
                        style: TextStyle(
                          color: sData.StaticData.blueLogo,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        )))
                : Container(),
            Flexible(flex: 1, child: Container()),
            GestureDetector(
                onTap: () {
                  if (isLoadedVotes) {
                    _isClicked[exhibList.list[i].id]['up'] = true;
                    tapVote(exhibList.list[i], "up");
                  }
                },
                child: Container(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: <Widget>[
//                        _isClicked[exhibList.list[i]]['up']
                        isLoadedVotes
                            ? _mVotes.containsKey(exhibList.list[i].id) && _mVotes[exhibList.list[i].id].vote == 'up'
                                ? Image.asset(
                                    'assets/like.png',
                                    height: 20,
                                  )
                                : Image.asset(
                                    'assets/like_grey.png',
                                    height: 20,
                                  )
                            : Image.asset(
                                'assets/like_grey.png',
                                height: 20,
                              ),
                      ],
                    ))),
            Container(
                padding: EdgeInsets.only(left: 4, right: 20),
                child: isLoadedVotes && !_isClicked[exhibList.list[i].id]['up']
                    ? Text(
                        '${exhibVotes[exhibList.list[i].id].upCount}',
                        style: TextStyle(
                          color: sData.StaticData.blueLogo,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : Container(
                        width: 15,
                        height: 15,
                        child: Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFfdb92e)),
                        )),
                      )),
            GestureDetector(
                onTap: () {
                  if (isLoadedVotes) {
                    _isClicked[exhibList.list[i].id]['down'] = true;
                    tapVote(exhibList.list[i], "down");
                  }
                },
                child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: <Widget>[
                        isLoadedVotes
                            ? _mVotes.containsKey(exhibList.list[i].id) && _mVotes[exhibList.list[i].id].vote == 'down'
                                ? Image.asset(
                                    'assets/dislike.png',
                                    height: 20,
                                  )
                                : Image.asset(
                                    'assets/dislike_grey.png',
                                    height: 20,
                                  )
                            : Image.asset(
                                'assets/dislike_grey.png',
                                height: 20,
                              ),
                      ],
                    ))),
            Container(
                padding: EdgeInsets.only(left: 4, right: 20),
                child: isLoadedVotes && !_isClicked[exhibList.list[i].id]['down']
                    ? Text(
                        '${exhibVotes[exhibList.list[i].id].downCount}',
                        style: TextStyle(
                          color: sData.StaticData.blueLogo,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : Container(
                        width: 15,
                        height: 15,
                        child: Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFfdb92e)),
                        )),
                      )),
          ],
        ));
  }

  tapVote(Exhibition ex, String vote) {
//    if (!eventData.mRegisteredEventUserIds.containsKey(event.id)) {
    if (!paid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Уучлаарай!!"),
            content: new Text("Та эвэнтэд бүртгүүлсний дараа саналаа өгнө үү.."),
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
    sendVote(ex, vote);
  }

  Future<void> sendVote(Exhibition ex, String vote) async {
    Map<String, dynamic> jsonMap = {
      'vote': vote,
      'role_id': user.roleId,
      'related_id': user.relatedId,
      'event_exhibition': ex.id
    };
    String jsonString = json.encode(jsonMap);
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      // 'Authorization': 'Bearer ' + user.jwt,
    };

    List<dynamic> exhibVotes;
    try {
      final response = await dio.post(
              '${StaticUrl.getEventExhibitionVotesUrlwithDomain()}',
              data: jsonString,
            );
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.data);
        exhibVotes = json.containsKey('success') && json['success'] ? json['data'] : null;
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
    }
    if (!mounted) return;
    if (exhibVotes != null) {

      setState(() {
//        _mVotes[ev['event_exhibition']['id']] =
//            Vote(vote: ev['vote'], voteId: ev['id'], exhibitionId: ev['event_exhibition']['id']);
        apiExhibitionVotes();
      });
    }
  }

  Future<void> apiExhibitions() async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      // 'Authorization': 'Bearer ' + user.jwt,
    };

    ExhibitionList exhiList;

    try {
      final response = await dio.get(
        '${StaticUrl.getEventExhibitionsUrlwithDomain()}?event=${event.id}',
      );
      if (response.statusCode == 200) {
        exhiList = ExhibitionList.fromJson(jsonDecode(response.data));
      } else {
        throw Exception('Server may has been shut down..');
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
    }
    if (!mounted) return;
    if (exhiList != null && exhiList.list.length > 0) {
//      Map<int, Map<int, Exhibition>> exhibitionByPrograms = Map<int, Map<int, Exhibition>>();
//
//      exhiList.programIds.forEach((id) {
//        Map<int, Exhibition> exhibitions = Map<int, Exhibition>();
//        exhiList.list.forEach((item) {
//          if (item.programId == id) exhibitions[item.id] = item;
//        });
//        exhibitionByPrograms[id] = exhibitions;
//      });
//      eventData.lstExhibitions[event.id] = exhibitionByPrograms;
      exhibList = ExhibitionList(list: exhiList.list);
      setState(() {
        isLoadedExhib = true;
      });
      apiExhibitionVotes();
    }
  }

  Future<void> apiExhibitionVotes() async {
    Map<String, dynamic> jsonMap = {
      "eventId": event.id,
    };
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      // 'Authorization': 'Bearer ' + user.jwt,
    };
    Map<int, Map<String, bool>> isClicked = Map<int, Map<String, bool>>();
    List<VoteOfExhib> lst;
    try {
      final response = await dio.post(
        '${StaticUrl.getEventExhibitionsUrlwithDomain()}/vote',
        data: jsonMap,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.data);
        lst = List();
        List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(res['data']);
        list.forEach((vote) {
//          int programId = vote['programId'] != null ? vote['programId'] : 0;
          lst.add(VoteOfExhib(exhibId: vote['id'], upCount: vote['up'], downCount: vote['down']));

          /// init user votes
          Map<String, bool> buttons = Map<String, bool>();
          buttons['up'] = false;
          buttons['down'] = false;
          isClicked[vote['id']] = buttons;
        });
      } else {
        throw Exception('Server may has been shut down..');
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
    }

    if (!mounted) return;
    _isClicked = isClicked;
    if (lst != null) {
      exhibVotes = Map.fromIterable(lst, key: (item)=>item.exhibId, value: (item)=> item);
      apiOwnVotes();
//      setState((){
//        isLoadedVotes = true;
//      });
    }
  }

  Future<void> apiOwnVotes() async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      // 'Authorization': 'Bearer ' + user.jwt,
    };
    List<Map<String, dynamic>> list;
    try {
      final response = await dio.get(
        '${StaticUrl.getEventExhibitionVotesUrlwithDomain()}'
        '?eventuser.role=${user.roleId}'
        '&eventuser.related_id=${user.relatedId}'
        '&eventuser.event=${event.id}',
      );
      if (response.statusCode == 200) {
        list = List<Map<String, dynamic>>.from(jsonDecode(response.data));
//        print('########');
//        list = List<Map<String, dynamic>>();
//        lst.forEach((item) {
//          var a = Map<String, dynamic>();
//          a['id'] = item['id']
//        });
//        list = ExhibitionVotesList.fromJson(jsonDecode(response.data));
//        print('@@@@@@@@@@@@@');
      } else {
        throw Exception('Server may has been shut down..');
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
    }

    if (!mounted) return;
    if (list != null) {
      list.forEach((vote) {
        _mVotes[vote['event_exhibition']] =
            VoteByUser(voteId: vote['id'], exhibitionId: vote['event_exhibition'], vote: vote['vote']);
      });
      setState(() {
        isLoadedVotes = true;
      });
    }
  }
}

class VoteOfExhib {
  final int exhibId;
  final int upCount;
  final int downCount;
  VoteOfExhib({this.exhibId, this.upCount, this.downCount});
}

class VoteByUser {
  /// exhibition vote id
  final int voteId;
  final int exhibitionId;

  /// up, down, none
  String vote;

  VoteByUser({this.voteId, this.exhibitionId, this.vote});
  factory VoteByUser.fromJson(Map<String, dynamic> json) {
    return VoteByUser(
      voteId: json.containsKey('id') && json['id'] != null ? json['id'] : 0,
      exhibitionId:
          json.containsKey('event_exhibition') && json['event_exhibition'] != null ? json['event_exhibition']['id'] : 0,
      vote: json.containsKey('vote') && json['vote'] != null ? json['vote'] : 'none',
    );
  }
}
