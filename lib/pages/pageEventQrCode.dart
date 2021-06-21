import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mend_doctor/models/modDoctor.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatefulWidget {
  static const routeName = '/qrcodPage';
  final Event event;
  QrCodePage({Key key, @required this.event}) : super(key: key);
  @override
  QrCodePageState createState() {
    return QrCodePageState(event);
  }
}

class QrCodePageState extends State<QrCodePage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  final storage = new FlutterSecureStorage();
  Event event;
  QrCodePageState(this.event);

  User user;
  bool finish = false;

  String _dataString;
  Doctor doctor;

  Future<void> init() async {
    String mendUser = await storage.read(key: 'mendUser') ?? '';
    user = User.fromJson(jsonDecode(mendUser));
    _dataString = "";
    prepareData();
  }

  @override
  Widget build(BuildContext context) {
//    WidgetsBinding.instance
//        .addPostFrameCallback((_) => executeAfterBuild());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Таны QR код'.toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Color.fromARGB(255, 2, 24, 99),
      ),
      body: _contentWidget(),
    );
  }

  void prepareData() {
    Map<String, dynamic> data = Map();
    data['user_id'] = user.id;
    data['username'] = user.name;
    data['event'] = event.id;

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(jsonEncode(data));

    setState(() {
      _dataString = encoded;
      finish = true;
    });
  }

  _contentWidget() {
    return Center(
        child: Container(
      color: const Color(0xFFFFFFFF),
      child: ListView(
        children: <Widget>[
          Image.asset('assets/header_top.png'),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Text(
              event.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xff021863), fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 50.0,
              right: 10.0,
            ),
            child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Таны QR код:',
                    //   style: TextStyle(
                    //     color: sData.StaticData.blueLogo,
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          width: 200,
                          child: Text(
                            'Утасны дугаар: ',
                            style: TextStyle(
                              color: sData.StaticData.blueLogo,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Text(
                          user.name,
                          style: TextStyle(
                            color: sData.StaticData.blueLogo,
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                          ),
                        )
                      ],
                    ),
                  ],
                )),
          ),
          finish
              ? Center(
                  child: Center(
                    child: QrImage(
                      data: _dataString,
                      size: 250,
                      errorStateBuilder: (cxt, err) {
                        return Container(
                          child: Center(
                            child: Text(
                              "Алдаа гарлаа...",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : Container(
                  child: Center(
                      child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                  )),
                ),
        ],
      ),
    ));
  }
}
