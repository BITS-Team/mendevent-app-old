
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';

class EventAttendancePage extends StatefulWidget {
  static const routeName = '/eventSpeakerDetailsPage';
  final Event event;
  final EventProgramItem program;
  bool isExpanded = false;

  EventAttendancePage({Key key, @required this.event, @required this.program}) : super(key: key);
  @override
  EventAttendancePageState createState() {
    return EventAttendancePageState(event, program);
  }
}

class EventAttendancePageState extends State<EventAttendancePage> with SingleTickerProviderStateMixin {
  Event event;
  EventProgramItem mProgram;
  EventAttendancePageState(this.event, this.mProgram);

  TextEditingController _txtRegisterController;
  User user;
  int _msgState;
  bool _confirm;
  bool foundActive;
  String _registerCode; /// huselt ilgeehees omno shalgah zorilgotoi baisan.
  bool alreadyRegistered;
  int activeBucket = 0;

  @override
  void initState() {
    super.initState();
    foundActive = false;
    _registerCode = '';
    _txtRegisterController = TextEditingController();
    _msgState = 0;
    _confirm = false;
    alreadyRegistered = false;
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    // eventData.firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print('message = $message');
    //     dynamic notification = message['notification'];
    //     NotificationFirebase(context, notification['title'] ?? '', notification['body'] ?? '').showNotification();
    //   },
    // );
  }

  _afterLayout(_) {
    checkEnableRegister();
  }

  @override
  void dispose() {
    super.dispose();
    _txtRegisterController.dispose();
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
            'Ирц бүртгэл',
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

    String msg1 = "Та бүртгэлийн тоогоо дутуу оруулсан байна. Шалгаад дахин оролдоно уу...";
    String msg2 = "Баталгаажуулж байна...";
    String msg3 = "Баталгаажлаа.";
    String msg4 = "Баталгаажуулах явцад алдаа гарлаа. Дахин оролдоно уу...";
    String msg5 = "Баталгаажуулах код буруу байна. Дахин оролдоно уу...";

    String lblRegButton =  foundActive ? 'Баталгаажуулах' : 'Буцах';

    return Container(
        color: Color(0xFFFFFFFF),
        child: ListView(
          children: <Widget>[
            Image.asset('assets/header_top.png'),
            drawHeader(),

            Container(
              margin: EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 50),
              child: Center(
                  child: Text(!foundActive ? 'Бүртгэлийн цаг нээгдээгүй байна.'
                      : (alreadyRegistered ? 'Та бүртгүүлсэн байна.'
                      : 'Та бүртгэлийн 5 оронтойг тоог бөглөж хөтөлбөрт суусан эсэхээ баталгаажуулна уу...'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0x80000000), fontSize: 18))),
            ),
            foundActive && !alreadyRegistered? Center(
              child: Container(
                alignment: Alignment.center,
                  width: 120,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0x10000000),
                  ),
                  child: Container(
                    width: 120,
                    child:  TextField(
                      style: TextStyle(
                        color: sData.StaticData.blueLogo,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                      maxLength: 5,
                      keyboardType: TextInputType.number,
                      //textInputAction: TextInputAction.next,
                      controller: _txtRegisterController,
                      obscureText: false,
                      decoration: InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        hintText: '.....',
                        hintStyle: TextStyle(
                          color: Color(0x40000000),
                          fontSize: 24.0,
                        ),
                      ),
                    )
                  ) ,
              ),
            ) : Container(),
            Container(
                margin: EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 50),
              child: Text(
                  _msgState == 1 ? msg1
                  : _msgState == 2 ? msg2
                  : _msgState == 3 ? msg3
                  : _msgState == 4 ? msg4
                  : _msgState == 5 ? msg5 :'',
                  style: TextStyle(color: Color(0x80000000), fontSize: 16)
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 120),
              child: FlatButton(
                  onPressed: () {
                    if(lblRegButton == 'Буцах' || _confirm || alreadyRegistered) {
                      Navigator.pop(context);
                      return;
                    } else {
                      if(_txtRegisterController.text.trim().length < 5){
                        setState(() {
                          _msgState = 1;
                        });
                      } else {
                        setState(() {
                          _msgState = 2;
                        });
                        registerAttendance(_txtRegisterController.text.trim());
                      }

                    }
                  },
                  child: Container(
                      padding: EdgeInsets.only(left: 50, right: 50, top: 16, bottom: 16),
                      decoration: BoxDecoration(
                          color: sData.StaticData.blueLogo, borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Text(
                        !_confirm && !alreadyRegistered ? lblRegButton.toUpperCase() : 'Буцах',
                        style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
                      )))
            ),

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

  Future<void> checkEnableRegister() async {
    Map<String, dynamic> params = {"event": event.id, "eventprogram": mProgram.id};
    dynamic res = await api.get('${StaticUrl.getEventAttendancesUrlwithDomain()}/active', params: params);
    if(res['code'] == 1000){
      if (res['data'].containsKey('result')) {
        toast.show(res['data']['message']);
        return;
      }
      if(res['data']['success']){
        setState(() {
          foundActive = true;
          _registerCode = res['data']['code'];
          alreadyRegistered = res['data']['already'];
          activeBucket = res['data']['id'];
        });
      } else {
        /// not found active
      }
    } else {
      toast.show(res['message']);
    }
  }


  Future<void> registerAttendance(code) async{
    Map<String, dynamic> params = {"eventprogram": mProgram.id, "event": event.id, "code": code, "bucket": activeBucket};
    String url = '${StaticUrl.getEventAttendancesUrlwithDomain()}/regbycode';
    dynamic res = await api.post(url, params: params);
    if(res['code'] == 1000){
      if (res['data']['success']) {
        if(res['data']['code'] == 1000){
          ///success
          setState(() {
            _msgState = 3;
            _confirm = true;
          });
        } else {
          ///wrong code
          setState(() {
            _msgState = 5;
          });
        }
      } else {
        toast.show(res['data']['message']);
      }
    } else {
      toast.show(res['message']);
    }
    // Map<String, dynamic> jsonMap = {'event_program': mProgram.id, 'event_user': eventData.mRegisteredEventUserIds[event.id].eventUserId};
    // Dio dio = Dio();
    // dio.options.responseType = ResponseType.plain;
    // dio.options.headers = {
    //   // 'Authorization': 'Bearer ' + user.jwt,
    // };
    // int id;
    // try {
    //   print('${StaticUrl.getEventAttendancesUrlwithDomain()}');
    //   final response = await dio.post(
    //     '${StaticUrl.getEventAttendancesUrlwithDomain()}',
    //     data: json.encode(jsonMap),
    //   );
    //   if (response.statusCode == 200) {
    //     Map<String, dynamic> res = jsonDecode(response.data);
    //     id = res.containsKey('id') && res['id'] != null ? res['id'] : -1;
    //   } else {
    //     throw Exception('Event has not been..');
    //   }
    // } on DioError catch (e) {
    //   print(e.response.data);
    //   print(e.response.headers);
    //   print(e.response.request.data);
    // }
    //
    // if (!mounted) return;
    // if(id != null){
    //   if(id < 0){
    //     setState(() {
    //       _msgState = 4;
    //     });
    //   } else {
    //     setState(() {
    //       _msgState = 3;
    //       _confirm = true;
    //     });
    //   }
    // } else {
    //   setState(() {
    //     _msgState = 4;
    //   });
    // }
  }
}
