import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_verification_code_input/flutter_verification_code_input.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/pages/pageEventList.dart';
import 'package:mend_doctor/pages/pageRegister.dart';
import 'package:mend_doctor/singletons/singletonEvent.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginPage extends StatefulWidget {
  static const routeName = '/loginPage';
  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  LocalAuthentication auth = LocalAuthentication();
  final storage = new FlutterSecureStorage();

  TextEditingController txtNameController1; // = TextEditingController();
  TextEditingController txtNameController; // = TextEditingController();
  TextEditingController txtPasswordController; //= TextEditingController();

  TextEditingController contAskPassword; //= TextEditingController();
  TextEditingController contResetPassword1; //= TextEditingController();
  TextEditingController contResetPassword2; //= TextEditingController();


  bool _isKeyboardShowing;
  bool _isLoginPressed;
  User user;
  final _askPhoneFormKey = GlobalKey<FormState>();
  final _resetPassFormKey = GlobalKey<FormState>();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  String tempUser;
  String tempPass;
  String devId = '';
  String userJson = '';

  /// sms code request attempts
  int requestAttempt = 3;

  ///states
  bool _hasFingerPrint = false;

  ///  bool _canCheckBiometrics = false;
  /// has device support finger print
  bool _fingerLogin = false;

  /// set finger login in config
  bool _checkFingerLogin = false;

  bool tmpCheckFingerLogin = false;

  /// biometrics verify
  bool _authorized = false;

  /// sms code request
  bool requestSent = false;
  bool _isGetCodePressed = false;

  /// reset password purpose
  bool isContinue = false;
  String tmpPassword = '';

  /// device biometrics demjdeg eseh
  /// fingerprint, face recognition, irises etc.
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;
    if (canCheckBiometrics) {
      _getAvailableBiometrics();
    } else {
      ///TODO: tsegtsleh, olon duudagdaj baigaa, _getAvailableBiometrics()
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('_checkFingerLogin', false);
    }
  }

  /// if fingerprint is available return true, otherwise false
  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    _hasFingerPrint = availableBiometrics.contains(BiometricType.fingerprint);
    if (!_hasFingerPrint) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('_checkFingerLogin', false);
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
        localizedReason: 'Хурууны хээгээ уншуулна уу..',
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _authorized = authenticated;
      if (_authorized) _login();
    });
  }

  Future<void> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      devId = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      devId = androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  @override
  void dispose() {
    txtNameController.dispose();
    txtNameController1.dispose();
    txtPasswordController.dispose();

    contAskPassword?.dispose();
    contResetPassword1?.dispose();
    contResetPassword2?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    user = null;
    _isLoginPressed = false;
    txtNameController = TextEditingController();
    txtNameController1 = TextEditingController();
    txtPasswordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    _getId();
   // _checkBiometrics();

    eventData.resetData();
  }

  _afterLayout(_) {
    checkLoginConfigs();
  }

  void setState(fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    _isKeyboardShowing = MediaQuery.of(context).viewInsets.vertical > 0;
    double contextWidth = MediaQuery.of(context).size.width;
    double contextHeight = MediaQuery.of(context).size.height;
//    txtNameController.addListener(() {
//      final newText = txtNameController.text;
//      txtNameController.value = txtNameController.value.copyWith(
//        text: newText,
//        selection: TextSelection(baseOffset: newText.length, extentOffset: newText.length),
//        composing: TextRange.empty,
//      );
//    });
    return WillPopScope(
        onWillPop: () {
          exit(0);
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: new ListView(children: <Widget>[
            new Column(
              children: <Widget>[
                !_isKeyboardShowing
                    ? Container(
                        color: StaticData.blueLogo,
                        padding: EdgeInsets.only(top: 60, left: 0, right: 0),
                        height: contextHeight * 0.2,
                        width: contextWidth,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                          Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(top: 0, left: 65, right: 5),
                                  height: contextHeight * 0.1,
                                  color: StaticData.blueLogo,
                                  child: Image(
                                    width: 200,
                                    image: AssetImage("assets/logo_white300x.png"),
                                  )),
                              flex: 1),
                          Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(top: 0, left: 10, right: 60),
                                  height: contextHeight * 0.08,
                                  color: StaticData.blueLogo,
                                  child: Image(
                                    image: AssetImage("assets/logo_text600x.png"),
                                  )),
                              flex: 2),
                        ]))
                    : Container(),
                Container(
                  width: contextWidth,
                  child: new Image(
                    image: new AssetImage("assets/top_bg1000x.webp"),
                    color: null,
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  height: 20,
                ),
                Container(
                  width: contextWidth,
                  margin: const EdgeInsets.only(left: 60.0, right: 60.0, top: 0.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: StaticData.r10,
                      border: Border.all(
                        width: 1,
                        color: StaticData.loginTextFieldBorder,
                      )),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                          child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: FutureBuilder(
                            future: getPhoneNumber(),
                            builder: (context, snapshot) {
                              return TextField(
                                onChanged: (text) {
                                  tempUser = text;
                                },
                                focusNode: _nameFocus,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () {
                                  _fieldFocusChange(context, _nameFocus, _passFocus);
                                },
                                controller: txtNameController1,
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Утасны дугаар',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(179, 0, 0, 0),
                                    fontSize: 16.0,
                                  ),
                                ),
                              );
                            }),
                      )),
                      Icon(
                        Icons.phone_iphone,
                        color: Color.fromARGB(179, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                Container(
                  width: contextWidth,
                  margin: const EdgeInsets.only(left: 60.0, right: 60.0, top: 0.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: StaticData.r10,
                      border: Border.all(
                        width: 1,
                        color: StaticData.loginTextFieldBorder,
                      )),
//                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                          child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextField(
                          controller: txtPasswordController,
                          textInputAction: TextInputAction.done,
                          focusNode: _passFocus,
                          onEditingComplete: () {
                            login(txtNameController1.text, txtPasswordController.text);
                          },
                          obscureText: true,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Нууц үг',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(179, 0, 0, 0),
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      )),
                      Icon(
                        Icons.lock_outline,
                        color: Color.fromARGB(179, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                Container(
                    width: contextWidth,
                    margin: const EdgeInsets.only(left: 60.0, right: 60.0, top: 0.0, bottom: 0.0),
                    alignment: Alignment.center,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      Checkbox(
                        value: tmpCheckFingerLogin,
                        onChanged: (bool value) {
                          toggleChecks('finger_login', value);
                        },
                      ),
                      Flexible(flex: 1, child: Text('Цаашид хурууны хээгээр нэвтрэх', style: TextStyle(color: Colors.black54, fontSize: 14)))
                    ])),
                Container(
                  height: 10,
                ),
                Container(
                  width: contextWidth,
                  height: contextHeight / 14,
                  margin: const EdgeInsets.only(left: 60.0, right: 60.0, top: 10.0),
                  child: new Row(
                    children: <Widget>[
                      Container(
                        width: 0,
                      ),
                      Expanded(
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: StaticData.r10,
                          ),
                          color: StaticData.blueLogo,
                          onPressed: () {
                            setState(() {
                              _isLoginPressed = true;
                            });
                            login(txtNameController1.text, txtPasswordController.text);
                          },
                          child: Container(
                              height: contextHeight / 14,
                              child: Center(
                                child: !_isLoginPressed
                                    ? (Text("Нэвтрэх".toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17.0,
                                        )))
                                    : Container(
                                        width: 25,
                                        height: 25, //contextHeight / 13 - 4,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFFFFFF)),
                                        )),
                              )),
                        ),
                        flex: 1,
                      ),
                      _hasFingerPrint && _checkFingerLogin
                          ? Container(
                              width: 10,
                            )
                          : Container(),
                      _hasFingerPrint && _checkFingerLogin
//                      false
                          ? FlatButton(
                              shape: new RoundedRectangleBorder(
                                borderRadius: StaticData.r10,
                              ),
                              color: StaticData.yellowLogo,
                              onPressed: () {
                                _authenticate();
                              },
                              child: new Container(
                                height: contextHeight / 14,
                                width: (contextHeight * 3) / 35 - 30,
                                child: Image(
                                  image: AssetImage("assets/finter-print-w.png"),
                                ),
                              ))
                          : Container(),
                    ],
                  ),
                ),
                Container(
                  height: 20,
                ),
                Container(
                    margin: const EdgeInsets.only(left: 60.0, right: 60.0),
                    width: contextWidth,
                    height: contextHeight / 16,
                    child: Container(
//                      padding: EdgeInsets.only(left: 60, right: 60),
//                    color: Colors.blue,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                        },
                        shape: new RoundedRectangleBorder(
                          borderRadius: StaticData.r10,
                        ),
                        color: StaticData.yellowLogo,
                        child: Center(
                            child: Text('Бүртгүүлэх'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17.0,
                                ))),
                      ),
                    )),
                Container(
                  height: 10,
                ),
                Container(
                  width: 400,
//                    alignment: Alignment.center,
//                    margin: EdgeInsets.only(left: 60, right: 60),
                  padding: EdgeInsets.only(left: 80, right: 80),
                  child: Container(
//                        decoration: BoxDecoration(
//                            borderRadius: StaticData.r10,
//                            color: Color.fromARGB(255, 255, 255, 228)),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                        Icon(
                          Icons.lock_open,
                          color: Color.fromARGB(179, 0, 0, 0),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
//                              _showDialog(context, 6, '');
                              _showAskPhoneNumberDialog();
                            },
//                          shape: new RoundedRectangleBorder(
//                            borderRadius: StaticData.r10,
//                          ),
//                          color: Color.fromARGB(255, 255, 242, 216),
                            child: Container(
//                              alignment: Alignment.center,
//                              padding: EdgeInsets.only(top: 15, bottom: 10),
                                child: Text('Нууц үгээ мартсан',
                                    style: TextStyle(
                                      color: Color.fromARGB(179, 0, 0, 0),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.0,
                                    ))),
                          ),
                          flex: 1,
                        )
                      ])),
                ),
              ],
            ),
          ]),
        ));
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = prefs.getString('phoneNumber') ?? '';
    if (tempUser != null && tempUser != '')
      txtNameController1.text = tempUser;
    else
      txtNameController1.text = phoneNumber;
  }

  void setPhoneNumber(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
  }

  void checkLoginConfigs() async {
    _checkBiometrics();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool fingerLogin = prefs.getBool('checkFingerLogin');
    // print('fingerLogin = ' + fingerLogin.toString());
    setState(() {
      /// draw checkbox's checked or not
      _checkFingerLogin = prefs.getBool('checkFingerLogin') ?? false;
      tmpCheckFingerLogin = _checkFingerLogin;
    });
  }

  void setLoginConfigs(String phoneNumber, bool checkFingerLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkFingerLogin', checkFingerLogin);
    await prefs.setString('phoneNumber', phoneNumber);

    if (!checkFingerLogin) {
      await prefs.setBool('needAuthFingerPrint', checkFingerLogin);
    }
  }

  void toggleChecks(String checkbox, bool value) {
    if (checkbox == 'finger_login') {
      setState(() {
        tmpCheckFingerLogin = value;
      });
    }
  }

  void login(String name, String pass) async {
    FocusScope.of(context).unfocus();
    if (name?.trim() == '' || pass?.trim() == '') {
      _showDialog(context, EMPTY_LOGIN_INFO);
      setState(() {
        _isLoginPressed = false;
      });
      return;
    }
    Map<String, String> jsonMap = {'identifier': name, 'password': pass};
    dynamic res = await api.post(StaticUrl.getLoginUrlwithDomain(), params: jsonMap, auth: false);
    setState(() {_isLoginPressed = false;});
    if(res['code'] == 1000){
        user = User.fromJson(res['data']['user']);

        await storage.write(key: 'mendJwt', value: res['data']['jwt'].toString());

        if (!user.confirmed) {
          _showSubmitDialog();
        } else {

          setLoginConfigs(name, tmpCheckFingerLogin);
          storage.write(key: 'mendUserName', value: name);
          storage.write(key: 'mendPass', value: pass);
        //   Map<String, dynamic> mUser = {"id":14,"email":"adi@gmail.com","provider":"local","confirmed":true,"blocked":false,"role":{"id":6,"name":"Doctor","description"
        // :"","type":"doctor"},"created_at":"2019-07-30T10:33:30.000Z","updated_at":"2020-10-02T10:32:56.000Z","related_id":2};
        //   storage.write(key: 'mendUser', value: jsonEncode(mUser));
          storage.write(key: 'mendUser', value: jsonEncode(res['data']['user']));
          sendToken(eventData.firebaseToken);
          eventData.firebaseToken = ''; /// unnecessary
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventListPage()));
        }
    } else {
      if(res['code'] == 1002 && res['message'] == "Identifier or password invalid."){
        _showDialog(context, WRONG_LOGIN_INFO);
      } else {
        _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
      }
    }
  }

  /// fingerprint login
  Future<void> _login() async {
    String username = await storage.read(key: "mendUserName");
    String password = await storage.read(key: "mendPass");

    ///    print('###### user: $username password: $password');
    if (!mounted) return;
    if (username != null && password != null) {
      login(username, password);
    } else {
      _showDialog(context, 10);
    }
  }

  ///error,warning msg dialog
  void _showDialog(BuildContext context, int msgType, {String additionalMsg: ''}) {
    String msg = messages[msgType];
    msg += '\n' + additionalMsg;
    String title = "Уучлаарай!!";
    if (msgType > 9) {
      title = "Анхааруулга!";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          backgroundColor: Color(0xFFb4b4b4),
          title: new Text(title, style: TextStyle(color: Color(0xFF021863), fontSize: 15)),
          content: new Text(msg, style: TextStyle(color: Color(0xFF021863), fontSize: 13)),
          actions: <Widget>[
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

  ///register confirmation dialog || sms code verify
  void _showSubmitDialog() {
    String _code = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          backgroundColor: Color(0xFFCCCCCC),
          content: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.close),
                    backgroundColor: Color(0xFF021863),
                  ),
                ),
              ),
              !requestSent
                  ? Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('АНХААРУУЛГА', style: TextStyle(color: Color(0xFF021863), fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Таны аккаунт баталгаажаагүй байна. Таны бүртгүүлсэн утсанд ирсэн баталгаажуулах кодыг ашиглаарай.',
                                style: TextStyle(color: Color(0xFF021863), fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                              color: StaticData.yellowLogo,
                              child: !_isGetCodePressed
                                  ? Text("КОД АВАХ", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))
                                  : Container(
                                      width: 18,
                                      height: 18, //contextHeight / 13 - 4,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFFFFFF)),
                                      )),
                              onPressed: () {
                                setState(() {
                                  _isGetCodePressed = true;
                                });
                                sendRequest();
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Баталгаажуулах кодоо оруулна уу...',
                                style: TextStyle(color: StaticData.blueLogo, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          VerificationCodeInput(
                            keyboardType: TextInputType.number,
                            length: 6,
                            itemSize: 35.0,
                            itemDecoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: StaticData.blueLogo))),
                            textStyle: TextStyle(color: StaticData.blueLogo, fontSize: 18, fontWeight: FontWeight.w700),
                            onCompleted: (String value) {
                              _code = value;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                              color: StaticData.yellowLogo,
                              child: Text("БАТЛАХ", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              onPressed: () {
                                if (_code.length > 5) {
                                  verifyCode(_code);
                                }
                              },
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 4),
                              child: FlatButton(
                                  color: Color(0xFFCCCCCC),
                                  onPressed: () {
                                    if (2 - requestAttempt > 0) sendRequest();
                                  },
                                  child: Text('Дахин код авах (${2 - requestAttempt})',
                                      style: TextStyle(color: StaticData.blueLogo, fontSize: 13, fontWeight: FontWeight.w500))))
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  /// sms code request for register confirmation
  void sendRequest() async {
    Map<String, String> body = {'phone': user.name, 'device_id': devId, 'user_id': user.id.toString()};
    dynamic res = await api.post(StaticUrl.getCodeRequestUrlwithDomain(), params: body);
    if(res['code'] == 1000){
      if (res['data']['code'] == 1000 || res['data']['code'] == 1002) {
        // 1002: 'Already sent code. Trying too many attempts..'
        setState(() {
          requestSent = true;
          _isGetCodePressed = false;
          requestAttempt = res['data']['attempt'] ?? 3;
          Navigator.of(context).pop();
          _showSubmitDialog();
        });
      } else {
        _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: '${res['data']['message']}');
      }
    } else {
      _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
    }
  }

  /// code verify
  void verifyCode(String code) async {
    Map<String, String> body = {'phone': user.name, 'device_id': devId, 'code': code, 'intent': 'register'};
    dynamic res = await api.post(StaticUrl.getCodeConfirmationUrlwithDomain(), params: body);
    if(res['code'] == 1000){
      if (res['data']['code'] == 1000) {
        await checkUser();
      } else {
        _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: '${res['data']['message']}');
      }
    } else {
      _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
    }
  }

  /// check user is confirmed
  checkUser() async {
    dynamic res = await api.get(StaticUrl.getUsersUrlwithDomain() + '/' + user.id.toString());
    if(res['code'] == 1000){
      if(res['data']['confirmed'] ?? false){
        // login(user.name, user.getPassword());
        login(user.name, txtPasswordController.text);
      } else {
        _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
      }
    } else {
      _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
    }
  }
  /// send Firebase messaging token to Server
  sendToken(token) async {
    dynamic res = await api.post(StaticUrl.getFirebaseTokenUrlwithDomain(), params : {"token": token});
    if(res['code'] == 1000){
      if(res['data']['success']){
        /// DONE. 
      } else {
        toast.show('Warning! Re login is required!');
      }
    } else {
      toast.show('FireBase token error!');
    }
  }



  /// password reset logic:
  /// 1. hereglegchees utasnii dugaar awna (app)
  /// 2. systemd burtgeltei esehiig shalgana (api)
  /// 3. solih password awna (app)
  /// 4. sms code request shidne (api)
  /// 5. shine password + sms code shidne (api)
  /// 6. success ued login tsonh ruu userne (app)

  ///ask phone number dialog for reset password
  void _showAskPhoneNumberDialog() {
    contAskPassword = new TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                backgroundColor: Color(0xFFCCCCCC),
                content: Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Positioned(
                      right: -40.0,
                      top: -40.0,
                      child: InkResponse(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.close),
                          backgroundColor: Color(0xFF021863),
                        ),
                      ),
                    ),
                    Form(
                      key: _askPhoneFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('НУУЦ ҮГ СЭРГЭЭХ', style: TextStyle(color: Color(0xFF021863), fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Та БҮРТГЭЛ-тэй утасны дугаараа оруулна уу. Таны утас руу баталгаажуулах код илгээнэ.',
                                style: TextStyle(color: Color(0xFF021863), fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                                controller: contAskPassword,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val.length < 8) {
                                    return 'Утасны дугаараа оруулна уу..';
                                  }
                                  return null;
                                },
                                inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                                decoration: InputDecoration(
                                    hintText: "Утасны дугаар",
                                    border: InputBorder.none,
                                    icon: Icon(
                                      Icons.phone_iphone,
                                      color: StaticData.blueLogo,
                                    ))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                              color: StaticData.yellowLogo,
                              child: !isContinue
                                  ? Text("ҮРГЭЛЖЛҮҮЛЭХ", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))
                                  : Container(
                                      width: 18,
                                      height: 18, //contextHeight / 13 - 4,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFFFFFF)),
                                      )),
                              onPressed: () {
                                if (_askPhoneFormKey.currentState.validate()) {
                                  setState(() {
                                    isContinue = true;
                                  });
                                  checkPhoneNumber(setState);
                                }
                              },
                            ),
                          ),
                          isContinue
                              ? Padding(
                                  padding: EdgeInsets.only(right: 8, left: 8, bottom: 8),
                                  child: Text('Шалгаж байна. Түр хүлээнэ үү...',
                                      style: TextStyle(color: Color(0xFF021863), fontSize: 13, fontWeight: FontWeight.w300)))
                              : Container()
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }).then((val) {
      isContinue = false;
    });
  }

  ///checking phone number has registered
  checkPhoneNumber(setState) async {
    dynamic res = await api.get(StaticUrl.getUsersUrlwithDomain() + "?username=" + contAskPassword.text);
    if(res['code'] == 1000){
      if(res['data'].length > 0){
        Navigator.of(context).pop();
        _showResetPasswordDialog();
      } else {
        _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
      }
      setState(() {
        isContinue = false;
      });
    } else {
      _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
    }
  }

  ///password reset verify dialog
  void _showResetPasswordDialog() {
    String _code = '';
    contResetPassword1 = TextEditingController();
    contResetPassword2 = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          backgroundColor: Color(0xFFCCCCCC),
          content: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.close),
                    backgroundColor: Color(0xFF021863),
                  ),
                ),
              ),
              !requestSent
                  ? Form(
                      key: _resetPassFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('НУУЦ ҮГ СЭРГЭЭХ', style: TextStyle(color: Color(0xFF021863), fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
//                          Padding(
//                            padding: EdgeInsets.all(8.0),
//                            child: Text('Таны аккаунт баталгаажаагүй байна. Таны бүртгүүлсэн утсанд ирсэн баталгаажуулах кодыг ашиглаарай.',
//                                style: TextStyle(color: Color(0xFF021863), fontSize: 13, fontWeight: FontWeight.w500)),
//                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                                controller: contResetPassword1,
                                autofocus: true,
                                obscureText: true,
//                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val.length < 6) {
                                    return 'Таны нууц үг 6 тэмдэгтээс урт байх ёстой.';
                                  }
                                  return null;
                                },
//                                inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                                decoration: InputDecoration(
//                              labelText:"whatever you want",
                                    hintText: "Нууц үг",
//                                    border: InputBorder,
                                    icon: Icon(
                                      Icons.lock,
                                      color: StaticData.blueLogo,
                                    ))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                                controller: contResetPassword2,
                                autofocus: true,
                                obscureText: true,
//                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val != contResetPassword1.text) {
                                    return 'Нууц үг давтан оруулахдаа алдсан байна.';
                                  }
                                  return null;
                                },
//                                inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                                decoration: InputDecoration(
                                    hintText: "Нууц үг давтах",
//                                    border: InputBorder,
                                    icon: Icon(
                                      Icons.lock,
                                      color: StaticData.blueLogo,
                                    ))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                              color: StaticData.yellowLogo,
                              child: !_isGetCodePressed
                                  ? Text("ХАДГАЛАХ", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))
                                  : Container(
                                      width: 18,
                                      height: 18, //contextHeight / 13 - 4,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFFFFFF)),
                                      )),
                              onPressed: () {
                                if(_resetPassFormKey.currentState.validate()){
                                  setState(() {
                                    _isGetCodePressed = true;
                                  });
                                  tmpPassword = contResetPassword1.text.trim();
                                  sendResetRequest();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Баталгаажуулах кодоо оруулна уу...',
                                style: TextStyle(color: StaticData.blueLogo, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          VerificationCodeInput(
                            keyboardType: TextInputType.number,
                            length: 6,
                            itemSize: 35.0,
                            itemDecoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: StaticData.blueLogo))),
                            textStyle: TextStyle(color: StaticData.blueLogo, fontSize: 18, fontWeight: FontWeight.w700),
                            onCompleted: (String value) {
                              _code = value;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                              color: StaticData.yellowLogo,
                              child: Text("БАТЛАХ", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              onPressed: () {
                                if (_code.length > 5) {
//                                  verifyCode(_code);
                                  resetPassword(_code, setState);
                                }
                              },
                            ),
                          ),
//                          Padding(
//                              padding: EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 4),
//                              child: FlatButton(
//                                  color: Color(0xFFCCCCCC),
//                                  onPressed: () {
////                                    if (2 - requestAttempt > 0) sendRequest('reset');
//                                  },
//                                  child: Text('Дахин код авах (${2 - requestAttempt})',
//                                      style: TextStyle(color: StaticData.blueLogo, fontSize: 13, fontWeight: FontWeight.w500))))
                        ],
                      ),
                    ),
            ],
          ),
        );
          });
      },
    );
  }

  void sendResetRequest() async {
    if(contAskPassword.text == null || contAskPassword.text.trim() == ''){
      return;
    }
    Map<String, String> body = {'phone': contAskPassword.text.trim(), 'device_id': devId};
    dynamic res = await api.post(StaticUrl.getResetPasswordUrlwithDomain(), params: body);
    if(res['code'] == 1000){
      if (res['data']['code'] == 1000 || res['data']['code'] == 1002) {
        // 1002: 'Already sent code. Trying too many attempts..'
        setState(() {
          requestSent = true;
          _isGetCodePressed = false;
          requestAttempt = res['data']['attempt'] ?? 3;
          Navigator.of(context).pop();
          _showResetPasswordDialog();
        });
      } else {
        _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: '${res['data']['message']}');
      }
    } else {
      _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
    }
  }

  void resetPassword(String code, setState) async {
    if(contAskPassword.text == null || contAskPassword.text.trim() == ''){
      return;
    }
    if(tmpPassword == ''){
      return;
    }

    Map<String, String> body = {'password': tmpPassword, 'device_id': devId, 'phone': contAskPassword.text.trim(), 'code': code};
    dynamic res = await api.post(StaticUrl.getResetVerifyUrlwithDomain(), params: body);
    if(res['code'] == 1000){
      if (res['data']['code'] == 1000 || res['data']['code'] == 1002) {
        // 1002: 'Already sent code. Trying too many attempts..'
        setState(() {
          tempUser = res['data']['user'];
          requestSent = false;
        });
        Navigator.of(context).pop();
      } else {
        _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: '${res['data']['message']}');
      }
    } else {
      _showDialog(context, ERROR_WITH_RESPONSE, additionalMsg: res['message']);
    }
  }
}

const int WRONG_LOGIN_INFO = 1;
const int BLOCKED_USER = 2;
const int SERVER_FAULT = 3;
const int EMPTY_LOGIN_INFO = 4;
const int NO_INTERNET = 5;

const int ERROR_WITH_RESPONSE = 10;

const Map<int, String> messages = {
  1: 'Таны хэрэглэгчийн нэр эсвэл нууц үг буруу байна.',
  2: 'Таны эрхийг хаасан байна.\nТа үйлчилгээний ажилтантай холбогдож эрхээ нээлгэнэ үү',
  3: 'Сервертэй холбогдож чадсангүй..\nХарилцагчийн албатай холбогдож лавлана уу',
  4: 'Хэрэглэгчийн нэр, нууц үгээ оруулна уу',
  5: 'Сервертэй холбогдож чадсангүй..\nТа интернэтээ шалгаад дахин оролдоно уу',

  10: 'Алдаа гарлаа. Алдааны мэдээлэл:\n'
};