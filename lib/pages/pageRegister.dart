import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mend_doctor/pages/pageLogin.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/registerPage';
  @override
  RegisterPageState createState() {
    // TODO: implement createState
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController txtPhoneController;
  TextEditingController txtLastNameController;
  TextEditingController txtFirstNameController;
  TextEditingController txtPassword1Controller;
  TextEditingController txtPassword2Controller;
  bool isKeyboardShowing;
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _pass1Focus = FocusNode();
  final FocusNode _pass2Focus = FocusNode();
  final FocusNode _submitFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    txtPhoneController = TextEditingController();
    txtLastNameController = TextEditingController();
    txtFirstNameController = TextEditingController();
    txtPassword1Controller = TextEditingController();
    txtPassword2Controller = TextEditingController();
  }

  @override
  void dispose() {
    txtPhoneController.dispose();
    txtLastNameController.dispose();
    txtFirstNameController.dispose();
    txtPassword1Controller.dispose();
    txtPassword2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isKeyboardShowing = MediaQuery.of(context).viewInsets.vertical > 0;
    double contextWidth = MediaQuery.of(context).size.width;
    double contextHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Бүртгүүлэх',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Color(0xff021863),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          !isKeyboardShowing
              ? Container(
                  color: sData.StaticData.blueLogo,
                  padding: EdgeInsets.only(top: 30, left: 0, right: 0),
                  height: contextHeight * 0.1,
                  width: contextWidth,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.only(top: 0, left: 65, right: 5),
                            height: contextHeight * 0.1,
                            color: sData.StaticData.blueLogo,
                            child: Image(
                              image: AssetImage("assets/logo_without_text.png"),
                            )),
                        flex: 1),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.only(top: 0, left: 10, right: 60),
                            height: contextHeight * 0.04,
                            color: sData.StaticData.blueLogo,
                            child: Image(
                              image: AssetImage("assets/logo_text.png"),
                            )),
                        flex: 2),
                  ]))
              : Container(),
          Container(
            width: contextWidth,
            child: new Image(
              image: new AssetImage("assets/top_bg1000x.webp"),
              color: null,
              fit: BoxFit.fitWidth,
            ),
          ),
          drawPhoneNumber(),
          drawLastName(),
          drawFirstName(),
          drawPass1Name(),
          drawPass2Name(),

          Container(
            margin: EdgeInsets.only(left: 60, right: 60, top: 10),
            padding: EdgeInsets.only(left: 30, right: 30),
            height: 50,
            alignment: Alignment.center,
            child: FlatButton(
              focusNode: _submitFocus,
              onPressed: () {
//                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                register();
              },
              shape: new RoundedRectangleBorder(
                borderRadius: sData.StaticData.r25,
              ),
              color: sData.StaticData.yellowLogo,
              child: Center(
                  child: Text('Бүртгүүлэх'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ))),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 40, top: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                '(*) - зайлшгүй шаардлагатай утгууд',
                style: TextStyle(color: Colors.black26, fontSize: 13),
              )),
        ],
      )),
    );
  }

  Container drawPhoneNumber() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 50, right: 50, top: 6),
                padding: EdgeInsets.only(left: 20, right: 10),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (text) {},
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _fieldFocusChange(context, _phoneFocus, _lNameFocus);
                      },
                      controller: txtPhoneController,
                      textAlign: TextAlign.left,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: ' ',
                        hintStyle: TextStyle(
                          color: Color(0x30000000),
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.phone_iphone,
//                    color: Color(0xff021863),
                    color: Color(0x80000000),
                  ),
                ])),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Утасны дугаар: (*)'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Container drawLastName() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 50, right: 50, top: 6),
                padding: EdgeInsets.only(left: 20, right: 10),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (text) {},
                      focusNode: _lNameFocus,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _fieldFocusChange(context, _lNameFocus, _fNameFocus);
                      },
                      controller: txtLastNameController,
                      textAlign: TextAlign.left,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: ' ',
                        hintStyle: TextStyle(
                          color: Color(0x30000000),
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.person_outline,
                    color: Color(0x80000000),
                  ),
                ])),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Овог'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Container drawFirstName() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 50, right: 50, top: 6),
                padding: EdgeInsets.only(left: 20, right: 10),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (text) {},
                      focusNode: _fNameFocus,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _fieldFocusChange(context, _fNameFocus, _pass1Focus);
                      },
                      controller: txtFirstNameController,
                      textAlign: TextAlign.left,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: ' ',
                        hintStyle: TextStyle(
                          color: Color(0x30000000),
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.person_outline,
                    color: Color(0x80000000),
                  ),
                ])),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Нэр'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Container drawPass1Name() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 50, right: 50, top: 6),
                padding: EdgeInsets.only(left: 20, right: 10),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (text) {},
                      focusNode: _pass1Focus,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _fieldFocusChange(context, _pass1Focus, _pass2Focus);
                      },
                      controller: txtPassword1Controller,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: ' ',
                        hintStyle: TextStyle(
                          color: Color(0x30000000),
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.lock_outline,
                    color: Color(0x80000000),
                  ),
                ])),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Нууц үг (*)'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Container drawPass2Name() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 50, right: 50, top: 6),
                padding: EdgeInsets.only(left: 20, right: 10),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (text) {},
                      focusNode: _pass2Focus,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _fieldFocusChange(context, _pass2Focus, _submitFocus);
                      },
                      controller: txtPassword2Controller,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: ' ',
                        hintStyle: TextStyle(
                          color: Color(0x30000000),
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.lock_outline,
                    color: Color(0x80000000),
                  ),
                ])),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Нууц үг (давтах)'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  register() {
    String phoneNumber, lName, fName, pass;

    if (txtPhoneController.text.trim() == '') {
      _showDialog(1);
      return;
    }
    if (txtPassword1Controller.text.trim() == '') {
      _showDialog(2);
      return;
    }
    if (txtPassword1Controller.text != txtPassword2Controller.text) {
      _showDialog(3);
      return;
    }
    if (txtPassword1Controller.text.length < 6) {
      _showDialog(4);
      return;
    }
    lName = txtLastNameController.text.trim() == '' ? '' : txtLastNameController.text.trim();
    fName = txtFirstNameController.text.trim() == '' ? '' : txtFirstNameController.text.trim();
    phoneNumber = txtPhoneController.text.trim();
    pass = txtPassword1Controller.text;
    callRegisterApi(phoneNumber, lName, fName, pass);
  }

  Future<void> callRegisterApi(String phoneNumber, String lName, String fName, String pass) async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
//    dio.options.headers = {
//      'Authorization': 'Bearer ' + token,
//    };
    FormData formData = FormData.fromMap({
      "username": phoneNumber,
      "password": pass,
      "role": 6, // role: Doctor=6
      "firstname": fName,
      "lastname": lName,
      "register_number": '',
      "phone": phoneNumber,
      "is_confirm": 0,
//      "file": await MultipartFile.fromFile("./text.txt",filename: "upload.txt")
    });
    int doctorId;
    try {
      final response = await dio.post(StaticUrl.getRegisterUrlwithDomain(), data: formData);
      print('response = ' + response.toString());
      if (response.statusCode == 200) {

        // If the call to the server was successful, parse the JSON.
//        Doctor doctor = Doctor.fromJson(jsonDecode(response.data));
        Map<String, dynamic> json = jsonDecode(response.data);
        bool success = json.containsKey('result') ? json['result'] : false;
        if (success) {
          Map<String, dynamic> data = json.containsKey('data') && json['data'] != null ? Map<String, dynamic>.from(json['data']) : null;
          if (data != null) {
            doctorId = data.containsKey('user') && data['user'].containsKey('id') ? data['user']['id'] : null;
          }
        } else {
          String errorMsg = json.containsKey('message') ? json['message'] : '';
          if (errorMsg == 'phone registered' || errorMsg == 'username' ) {
            _showDialog(6);
          } else {
            _showDialog(0);
          }
        }
      } else {
        _showDialog(0);
      }
    } on DioError catch (e) {
      _showDialog(11);
    }

    if (!mounted) return;
    if (doctorId != null) {
      setPhoneNumber(phoneNumber, pass);
      toast.show('Амжилттай бүртгэгдлээ.');
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  Future setPhoneNumber(String phoneNumber, String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _showDialog(int msgType) {
    String msgPhoneEmpty = "Утасны дугаараа оруулна уу...";

    String msgPassEmpty = "Нууц үгээ оруулна уу...";
    String msgPassDiff = "Нууц үгээ давтан оруулна уу...\nЭсвэл давтан оруулахдаа алдсан байна.";
    String msgPassLength = "Таны нууц үг 6 тэмдэгтээс урт байх ёстой.";

    String msgEmpty = "Нэг зүйл буруу байна..\nЯагаад гэдгийг мэдэхгүй учир та манай үйлчилгээний ажилтантай холбогдож лавлана уу.. :)";
    String msgNoNetwork = "Сервертэй холбогдож чадсангүй..\nТа интернэтээ шалгаад дахин оролдоно уу..";
    String msgDuplicate = "Бүртгэлтэй хэрэглэгч байна.\nХэрэв та нууц үгээ мартсан бол \"Нэвтрэх\" хуудаснаас 'Нууц үгээ мартсан' дарж сэргээнэ үү..";
    String msg = "";
    switch (msgType) {
      case 1:
        msg = msgPhoneEmpty;
        break;
      case 2:
        msg = msgPassEmpty;
        break;
      case 3:
        msg = msgPassDiff;
        break;
      case 4:
        msg = msgPassLength;
        break;
      case 5:
        msg = msgNoNetwork;
        break;
      case 6:
        msg = msgDuplicate;
        break;
      case 11:
        msg = msgNoNetwork;
        break;
      default:
        msg = msgEmpty;
        break;
    }
    String title = "Анхааруулга!!";
    if (msgType > 10) {
      title = "Уучлаарай!";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          backgroundColor: Color(0xFFb4b4b4),
          title: new Text(title, style: TextStyle(color: Color(0xFF021863), fontSize: 15)),
          content: new Text(msg, style: TextStyle(color: Color(0xFF021863), fontSize: 13)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Хаах", style: TextStyle(color: Color(0xFF021863), fontSize: 13)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
