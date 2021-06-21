import 'dart:convert';
import 'dart:io' as Io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mend_doctor/models/lstAppointmentsList.dart';
import 'package:mend_doctor/models/modDoctor.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/singletons/singletonEvent.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profilePage';
  ProfilePage({Key key}) : super(key: key);
  @override
  ProfilePageState createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {

  User user;

  ProfilePageState();
  Doctor _doctor;
  String _picUrl;

  bool dataChanged =false;
  bool submitButtonAction = false;

  BuildContext mContext;
  TextEditingController ctrlLname, ctrlFname, ctrlRnumber, ctrlLnumber, ctrlAbout;
  FocusNode _fLname, _fFname, _fRnumber, _fLnumber, _fAbout, _fSubmit;


  final storage = new FlutterSecureStorage();
  bool _isFingerPrintCheck = false;

  LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _showFingerPrint = false;
  String _pass;

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
//      _availableBiometrics = availableBiometrics;
      _showFingerPrint = availableBiometrics.contains(BiometricType.fingerprint);
    });
  }

  Future<void> _useFingerPrint(SharedPreferences prefs){
    bool _isCheck = prefs.getBool('checkFingerLogin') ?? false;
    setState((){
      _isFingerPrintCheck = _isCheck;
    });
  }

  void getUser() async {
    ///TODO: error uuswel LoginPage ruu usergeh
    String jsonString = await storage.read(key: 'mendUser');
    user = User.fromJson(jsonDecode(jsonString));

    _checkBiometrics();
    _getAvailableBiometrics();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> mapD = jsonDecode(await prefs.getString('profileData'));
    _doctor = Doctor.fromJson(mapD);
    _picUrl = _doctor.avatarUrl;
    ctrlLname.text = _doctor.lastName;
    ctrlFname.text = _doctor.firstName;
    ctrlRnumber.text = _doctor.registerNumber;
    ctrlLnumber.text = _doctor.licenseNumber;
    ctrlAbout.text = _doctor.description;

    _useFingerPrint(prefs);
  }

  _afterLayout(_) {
    getUser();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();

    ctrlLname = TextEditingController();
    ctrlFname = TextEditingController();
    ctrlRnumber = TextEditingController();
    ctrlLnumber = TextEditingController();
    ctrlAbout = TextEditingController();

    _fLname = FocusNode();
    _fFname = FocusNode();
    _fRnumber = FocusNode();
    _fLnumber = FocusNode();
    _fAbout = FocusNode();
    _fSubmit = FocusNode();

  }



  @override
  void dispose() {
    ctrlLname.dispose();
    ctrlFname.dispose();
    ctrlRnumber.dispose();
    ctrlLnumber.dispose();
    ctrlAbout.dispose();
    super.dispose();
  }

  saveFingerPrintConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('checkFingerLogin', _isFingerPrintCheck);
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Хувийн мэдээлэл',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color(0xff021863),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Container(
              child: Image.asset('assets/header_top.png'),
            ),
            drawAvatar(),
            Container(
                child: Center(
                    child: Text('(Зурган дээр дарж аватараа шинэчилж болно)',
                        style: TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic)))),
            Container(
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                color: Colors.grey[300],
                padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                child: Text('Үндсэн мэдээлэл'.toUpperCase(), style: TextStyle(color: Colors.black54, fontSize: 13))),
            drawLastName(),
            drawFirstName(),
            drawRegisterNumber(),
            drawLicenseNumber(),
            drawAbout(),
            Container(
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                color: Colors.grey[300],
                padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                child: Text('Аппликэйшний тохиргоо'.toUpperCase(), style: TextStyle(color: Colors.black54, fontSize: 13))),
            _canCheckBiometrics && _showFingerPrint ? Container(
              margin: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Checkbox(
                    value: _isFingerPrintCheck,
                    onChanged: (bool value){
                      if(value){
//                        storage.write(key: 'mendPass', value: pass);
                      }else {
                        storage.delete(key: 'mendPass');
                      }
                      setState((){
                        _isFingerPrintCheck = value;
                      });
                      saveFingerPrintConfig();
                    },

                  ),
                  Flexible(
                    flex: 1,
                    child: Text('Цаашид хурууны хээгээр нэвтрэх',
                        style: TextStyle(color: Colors.black54, fontSize: 14)
                    )
                  )
                ]
              ),

            ) : Container(),
            Container(
                margin: EdgeInsets.only(top: 40),
                child: Center(
                    child: FlatButton(
                        onPressed: () {
                          submitButtonAction ? changeProfile() : Navigator.pop(context);
                        },
                        focusNode: _fSubmit,
                        child: Container(
                            padding: EdgeInsets.only(left: 50, right: 50, top: 16, bottom: 16),
                            decoration: BoxDecoration(
                                color: sData.StaticData.blueLogo, borderRadius: BorderRadius.all(Radius.circular(12))),
                            child: Text(
                                !dataChanged ? 'Буцах'.toUpperCase() : 'Хадгалах'.toUpperCase(),
                              style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
                            ))))),
            Container(height: 60,),
          ],
        )));
  }


  Container drawAvatar() {
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: 10, left: 20, right: 20),
      child: Center(
        child: GestureDetector(
          onTap: () {
            changePic();
          },
          child: Container(
              padding: EdgeInsets.only(top: 0),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xaa021863),
                border: Border.all(
                  width: 0.7,
                  color: Color(0x33000000),
                ),
                borderRadius: BorderRadius.all(const Radius.circular(60)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(const Radius.circular(60)),
                child: (_doctor?.hasPic() ?? false)
                    ? Center(
                        child: CachedNetworkImage(
//                          imageUrl: '${StaticUrl.getDomainPort()}${_doctor.avatarUrl}',
                          imageUrl: '${StaticUrl.getDomainPort()}$_picUrl',
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  ),
                            ),
                          ),
//                          fit: BoxFit.cover,
                          placeholder: (context, url) => new CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                          ),
                          errorWidget: (context, url, error) => Center(
                              child: Text(_doctor?.firstName?.substring(0, 1)  ?? '',
                                  style: TextStyle(
                                      color: sData.StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
//                                  new Icon(Icons.error),
                        ),
                      )
                    : Center(
                        child: Text((_doctor?.firstName ?? '')!= '' ? _doctor.firstName.substring(0, 1) : 'ME',
                            style: TextStyle(
                                color: sData.StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
              )),
        ),
      ),
    );
  }

  Container drawLastName() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 60, right: 60, top: 6),
                padding: EdgeInsets.only(
                  left: 20,
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: TextField(
                  onChanged: (text) {
                    if(text != _doctor.lastName){
                      if(!dataChanged) {
                        setState(() {
                          dataChanged = true;
                        });
                        submitButtonAction = true;
                      }
                    }
                  },
                  controller: ctrlLname,
                  focusNode: _fLname,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    _fieldFocusChange(mContext, _fLname, _fFname);
                  },
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
                )),
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
                margin: EdgeInsets.only(left: 60, right: 60, top: 6),
                padding: EdgeInsets.only(
                  left: 20,
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: TextField(
                  onChanged: (text) {
                    if(text != _doctor.firstName){
                      if(!dataChanged) {
                        setState(() {
                          dataChanged = true;
                        });
                        submitButtonAction = true;
                      }
                    }
                  },
                  controller: ctrlFname,
                  focusNode: _fFname,
                  onEditingComplete: () {
                    _fieldFocusChange(mContext, _fFname, _fRnumber);
                  },
                  textInputAction: TextInputAction.next,
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
                )),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'нэр'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Container drawRegisterNumber() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 60, right: 60, top: 6),
                padding: EdgeInsets.only(
                  left: 20,
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: TextField(
                  onChanged: (text) {
                    if(text != _doctor.registerNumber){
                      if(!dataChanged) {
                        setState(() {
                          dataChanged = true;
                        });
                        submitButtonAction = true;
                      }
                    }
                  },
                  controller: ctrlRnumber,
                  focusNode: _fRnumber,
                  onEditingComplete: () {
                    _fieldFocusChange(mContext, _fRnumber, _fLnumber);
                  },
                  textInputAction: TextInputAction.next,
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
                )),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Регистрийн дугаар'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Container drawAbout() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.topLeft,
                height: 180,
                margin: EdgeInsets.only(left: 60, right: 60, top: 6),
                padding: EdgeInsets.only(
                  left: 20,
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: TextField(
                  onChanged: (text) {
                    if(text != _doctor.description){
                      if(!dataChanged) {
                        setState(() {
                          dataChanged = true;
                        });
                        submitButtonAction = true;
                      }
                    }
                  },
                  minLines: 8,
                  controller: ctrlAbout,
                  focusNode: _fAbout,
//                  onEditingComplete: () {
//                    _fieldFocusChange(mContext, _fAbout, _fSubmit);
//                  },
                  textInputAction: TextInputAction.newline,
                  textAlign: TextAlign.left,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: ' ',
                    hintStyle: TextStyle(
                      color: Color(0x30000000),
                      fontStyle: FontStyle.italic,
                      fontSize: 16.0,
                    ),
                  ),
                )),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Миний тухай'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Container drawPhoneNumber() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 60, right: 60, top: 6),
                padding: EdgeInsets.only(
                  left: 20,
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: TextField(
                  textInputAction: TextInputAction.next,
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
                )),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Утасны дугаар'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Container drawLicenseNumber() {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomLeft,
                height: 50,
                margin: EdgeInsets.only(left: 60, right: 60, top: 6),
                padding: EdgeInsets.only(
                  left: 20,
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0x20000000), style: BorderStyle.solid, width: 1)),
                child: TextField(
                  onChanged: (text) {
                    if(text != _doctor.licenseNumber){
                      if(!dataChanged) {
                        setState(() {
                          dataChanged = true;
                        });
                        submitButtonAction = true;
                      }
                    }
                  },
                  controller: ctrlLnumber,
                  focusNode: _fLnumber,
                  onEditingComplete: () {
                    _fieldFocusChange(mContext, _fLnumber, _fAbout);
                  },
                  textInputAction: TextInputAction.next,
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
                )),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.only(left: 80),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Эмчийн лицензийн дугаар'.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Color(0x80000000), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Future<Io.File> getImage(double maxHeight, double maxWidth, int quality) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: maxHeight, maxWidth: maxWidth, imageQuality: quality);
    return image;
  }
  changePic() async {
    Io.File image2 = await getImage(200,200,80);
    if(image2 != null) {
      uploadPic(image2, basename(image2.path));
    }
  }

  changeProfile() {
    uploadProfile();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Io.File> get _localFile async {
    final path = await _localPath;
    return Io.File('$path/newAvatar.jpg');
  }

  Future<FormData> formData(Io.File path, String name) async {
    MultipartFile mpf = await MultipartFile.fromFile(path.path, filename: name);
    return FormData.fromMap({"ref": "doctor", "refId": user.relatedId, "field": "avatar", "files": mpf});
  }

  Future<void> uploadPic(Io.File file, String name) async {
    FormData data = await formData(file, name);
    Map<String, dynamic> params = {};
    String url = StaticUrl.getUploadUrlwithDomain();
    dynamic json = await api.formPost(url, formData: data);
    if(json['code'] == 1000){
      dynamic upload = json['data'].first;
      String picUrl = upload.containsKey('url') && upload['url'] != null ? upload['url'] : null;
      setState(() {
        _picUrl = picUrl;
        // _doctor.avatarUrl = picUrl;
      });
      toast.show('Зураг амжилттай шинэчлэгдлээ');
    } else {
      toast.show(json['message'] ?? '');
    }
    // Dio dio = new Dio();
    // dio.options.responseType = ResponseType.plain;
    // dio.options.headers = {
    //   'mimeType': 'multipart/form-data',
    //   // 'Authorization': 'Bearer ' + user.jwt,
    // };
    // FormData data = await formData(file, name);
    // String picUrl;
    // try {
    //   print(StaticUrl.getUploadUrlwithDomain());
    //   final response = await dio.post(StaticUrl.getUploadUrlwithDomain(), data: data);
    //   if (response.statusCode == 200) {
    //     List<dynamic> res = jsonDecode(response.data);
    //     Map<String, dynamic> data = Map<String, dynamic>.from(res.first);
    //     picUrl = data.containsKey('url') && data['url'] != null ? data['url'] : null;
    //
    //   } else {
    //     throw Exception('Хэрэглэгчийн мэдээллийг олсонгүй..');
    //   }
    // } on DioError catch (e) {
    //   print('response.data: ${e.response.data}');
    //   print('response.header: ${e.response.headers}');
    //   print(e.response.request.data);
    // }
    //
    // if(!mounted) return;
    // if(picUrl != null){
    //   Fluttertoast.showToast(
    //       msg: "Зураг амжилттай шинэчлэгдлээ",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.TOP,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Color(0xff021863),
    //       textColor: Colors.white,
    //       fontSize: 15.0
    //   );
    //   setState((){
    //     _picUrl = picUrl;
    //   });
    //
    // }
  }

  Future<void> uploadProfile() async {
    Map<String, dynamic> jsonMap;

    jsonMap = {
      "firstname": ctrlFname.text,
      "lastname": ctrlLname.text,
      "register_number": ctrlRnumber.text,
      "license_number": ctrlLnumber.text,
      "description": ctrlAbout.text,
    };

    String jsonString = json.encode(jsonMap);

    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      // 'Authorization': 'Bearer ' + user.jwt,
    };
    Doctor doctor;
    try {
      final response = await dio.put(
        '${StaticUrl.getProfileUrlwithDomain()}${user.relatedId}',
        data: jsonString
      );
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
      doctor = Doctor.fromJson(jsonDecode(response.data));
      eventData.mProfile = doctor;

//      print(doctor);
//        doctor.setToken(user.jwt);
//        return doctor;
      } else {
        throw Exception('Хэрэглэгчийн мэдээллийг олсонгүй..');
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
//      return null;
    }

    if(!mounted) return;
    if(doctor != null){
      setState((){
        _doctor = doctor;
        dataChanged =false;

      });
      submitButtonAction = false;
    }

  }


  Future<void> getProfile() async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      // 'Authorization': 'Bearer ' + user.jwt,
    };
    try {
      final response = await dio.get(
        '${StaticUrl.getProfileUrlwithDomain()}${user.relatedId}',
      );
      if (response.statusCode == 200) {
        Doctor doctor = Doctor.fromJson(jsonDecode(response.data));
        eventData.mProfile = doctor;
      } else {
        throw Exception('Хэрэглэгчийн мэдээллийг олсонгүй..');
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
    }
  }

  Future<AppointmentsList> getAppointments(String doctorId, String token) async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      'Authorization': 'Bearer ' + token,
    };
    try {
      final response = await dio.get(
        StaticUrl.getAppointmentUrlwithDomain() + '?doctor=$doctorId',
      );
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        return AppointmentsList.fromJson(jsonDecode(response.data));
      } else {
        throw Exception('Хэрэглэгчийн мэдээллийг олсонгүй..');
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
      return null;
    }
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
