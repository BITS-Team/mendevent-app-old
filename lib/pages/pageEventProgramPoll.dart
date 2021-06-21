import 'package:flutter/material.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';

class EventProgramPollPage extends StatefulWidget {
  static const routeName = '/eventSpeakerDetailsPage';
  final Event event;
  final EventProgramItem program;

  EventProgramPollPage({Key key, @required this.event, @required this.program}) : super(key: key);
  @override
  EventProgramPollPageState createState() {
    return EventProgramPollPageState(event, program);
  }
}

class EventProgramPollPageState extends State<EventProgramPollPage> with SingleTickerProviderStateMixin {
  Event event;
  EventProgramItem mProgram;
  EventProgramPollPageState(this.event, this.mProgram);
  double contextWidth;

  ///states
  String pollQuestion = '';
  int pollId = 0;
  int submit = 0;
  List<PollOption> options;

  String statusMessage = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
    options = List();
  }

  _afterLayout(_) {
    // checkEnableRegister();
    getActivePoll();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    contextWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Санал асуулга',
            overflow: TextOverflow.fade,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color(0xff021863),
        ),
        body: drawBody(),
      ),
    );
  }

  Container drawBody() {
    return Container(
        color: Color(0xFFFFFFFF),
        child: ListView(
          children: <Widget>[
            Image.asset('assets/header_top.png'),
            drawHeader(),
            pollQuestion == '' ? drawEmpty() : drawPoll(),
            Container(
              height: 80,
            ),
            statusMessage != '' ? Center(child: Text(statusMessage)) : Container(),
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

  Container drawEmpty() {
    return Container(padding: EdgeInsets.only(top: 80, left: 60, right: 60), child: Center(child: Text('Идэвхитэй санал асуулга олдсонгүй...')));
  }

  Container drawOptions() {
    List<Widget> lst = List();
    options.forEach((el) {
      lst.add(GestureDetector(
          onTap: () {
            if (submit == 0) {
              showSubmitDialog(el);
            }
          },
          child: Container(
              color: submit != el.optionId ? Colors.blue[800] : Colors.red,
              padding: EdgeInsets.all(8),
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Text(el.optionName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  Container(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        el.optionDescription,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ))
                ],
              ))));
    });
    return Container(child: GridView.count(shrinkWrap: true, crossAxisSpacing: 10, mainAxisSpacing: 10, crossAxisCount: 2, children: lst));
  }

  Container drawPoll() {
    return Container(
        margin: EdgeInsets.only(top: 30, left: 20, right: 20),
        child: Column(
          children: [
            Text(
              pollQuestion,
              style: TextStyle(color: sData.StaticData.blueLogo, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text('(Доорх хариултуудаас сонгоно уу)'),
            SizedBox(
              height: 20,
            ),
            options.length > 0
                ? drawOptions()
                : CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                  ),
          ],
        ));
  }

  Future<void> getActivePoll() async {
    Map<String, dynamic> params = {"event": event.id, "eventprogram": mProgram.id};
    String url = '${StaticUrl.getEventPollUrlwithDomain()}/active';
    dynamic res = await api.get(url, params: params);
    if (res['code'] == 1000) {
      if (res['data']['success'] && res['data'].containsKey('start')) {
        setState(() {
          pollQuestion = res['data']['poll_question'];
          submit = res['data']['already'];
          pollId = res['data']['id'];
        });
        getOptions();
      }
    } else {
      toast.show(res['message']);
    }
  }

  Future<void> getOptions() async {
    options.clear();
    Map<String, dynamic> params = {"event_poll": pollId, "_sort": "option_name:asc"};
    String url = '${StaticUrl.getPollOptionUrlwithDomain()}';
    dynamic res = await api.get(url, params: params);
    if (res['code'] == 1000) {
      List<PollOption> ops = List();
      res['data'].forEach((op) {
        ops.add(PollOption.fromJson(op));
      });
      setState(() {
        options = ops;
      });
    } else {
      toast.show(res['message']);
    }
  }

  Future<void> sendPollOption(PollOption option) async {
    Map<String, dynamic> params = {"eventId": event.id, "programId": mProgram.id, "poll": pollId, "pollOption": option.optionId};
    String url = '${StaticUrl.getEventPollUrlwithDomain()}/submit';
    dynamic res = await api.post(url, params: params);
    if (res['code'] == 1000) {
      String stat = '';
      if (res['data']['success']) {
        if (res['data']['code'] == 1000) {
          stat = 'Амжилттай илгээгдлээ.';
          submit = option.optionId;
        } else if (res['data']['code'] == 1001) {
          stat = 'Өмнө хариулсан байна';
        } else if (res['data']['code'] == 1002) {
          stat = 'Хөтөлбөрийн бүртгэлд хамрагдаагүй байна';
        }
      } else {
        stat = 'Алдаа гарлаа. Та дахин оролдоно уу.';
        toast.show(res['data']['message']);
      }
      setState(() {
        statusMessage = stat;
      });
    } else {
      toast.show(res['message']);
    }
  }

  void showSubmitDialog(PollOption option) {
    String title = pollQuestion.toUpperCase();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          backgroundColor: Color(0xFFb4b4b4),
          title: new Text(title, style: TextStyle(color: Color(0x80000000), fontSize: 15)),
          content: Container(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('${option.optionName}\n' + option.optionDescription),
                  ),
                  Center(
                      child: Text(
                    '(Дахин хариулах боломжгүй гэдгийг анхаарна уу)',
                    style: TextStyle(fontSize: 10),
                  ))
                ],
              )),
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
                Navigator.of(context).pop();
                sendPollOption(option);
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
}

class PollOption {
  final int optionId;
  final String optionName;
  final String optionDescription;

  PollOption({this.optionId, this.optionName, this.optionDescription});
  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      optionId: json.containsKey('id') && json['id'] != null ? json['id'] : 0,
      optionName: json.containsKey('option_name') && json['option_name'] != null ? json['option_name'] : '',
      optionDescription: json.containsKey('description') && json['description'] != null ? json['description'] : '',
    );
  }
}
