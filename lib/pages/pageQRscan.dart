import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewScan extends StatefulWidget {
  static const routeName = '/testqrscan';
  final Event event;
  final EventProgramItem program;

  const QRViewScan({Key key, this.event, this.program}) : super(key: key);
  @override
  _QRViewScanState createState() => _QRViewScanState(event, program);
}

class _QRViewScanState extends State<QRViewScan> with SingleTickerProviderStateMixin {
  Event event;
  EventProgramItem program;
  _QRViewScanState(this.event, this.program);

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var statusText = "QR код уншуулна уу...";
  QRViewController controller;

  bool starting = false;
  bool finished = false;
  bool reset = true;
  bool hasError = false;

  double contextWidth;
  double cameraHeight;
  // AnimationController _animController;
  // Animation<double> animation;

  String username = '';
  List<dynamic> payments = [];
  List<dynamic> mPackages = List();
  Map<String, dynamic> mMember = Map();
  bool registering = false;
  String responseMessage = '';
  bool isEvent;
  bool _acceptProgram = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    isEvent = program == null ? true : false;
    super.initState();
  }

  _afterLayout(_) {
    contextWidth = MediaQuery.of(context).size.width;
    setState(() {
      cameraHeight = contextWidth;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    // _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: reset
              ? Container(
                  child: drawQrScan(),
                )
              : Container(
                  child: drawScannedResult(),
                )),
      floatingActionButton: !reset
          ? FloatingActionButton(
              onPressed: () {
                resetScanner();
              },
              child: Icon(Icons.qr_code_scanner),
              backgroundColor: StaticData.yellowLogo,
            )
          : null,
    );
  }

  void resetScanner() {
    setState(() {
      reset = true;
      cameraHeight = contextWidth;
      starting = false;
      hasError = false;
      registering = false;
      mPackages.clear();
    });
  }

  Container drawUserInfo() {
    return hasError
        ? Container(child: Center(child: Text('Хэрэглэгчийн мэдээлэл олдсонгүй.')))
        : Container(
            padding: EdgeInsets.only(left: 50, right: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Утасны дугаар:', style: TextStyle(fontSize: 14, color: Color(0xff021863), fontWeight: FontWeight.w500)),
                    ),
                    Text(mMember['phone'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  child: Image.network(
                    '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(mMember['avatar']['url'])}',
                    height: 200,
                  ),
                ),
                SizedBox(height: 10),
                mMember['description'] != ''
                    ? Row(
                        children: [
                          Expanded(
                            child: Text(' ', style: TextStyle(fontSize: 14, color: Color(0xff021863), fontWeight: FontWeight.w500)),
                          ),
                          Text(mMember['description'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
                        ],
                      )
                    : Container(),
                SizedBox(height: 10),
                mMember['lastname'] != ''
                    ? Row(
                        children: [
                          Expanded(
                            child: Text('Овог:', style: TextStyle(fontSize: 14, color: Color(0xff021863), fontWeight: FontWeight.w500)),
                          ),
                          Text(mMember['lastname'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
                        ],
                      )
                    : Container(),
                SizedBox(height: 10),
                mMember['firstname'] != ''
                    ? Row(
                        children: [
                          Expanded(
                            child: Text('Нэр', style: TextStyle(fontSize: 14, color: Color(0xff021863), fontWeight: FontWeight.w500)),
                          ),
                          Text(mMember['firstname'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
                        ],
                      )
                    : Container(),
                SizedBox(height: 40),

                Container(child: Text('ЗӨВШӨӨРӨГДСӨН БАГЦУУД', style: TextStyle(fontSize: 14, color: Color(0xff021863), fontWeight: FontWeight.w500))),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: mPackages.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          // height: 50,
                          child: Row(
                        children: [
                          Expanded(
                            child: Text(mPackages[index]['name'], style: TextStyle(fontSize: 14, color: Color(0xff021863), fontWeight: FontWeight.w500)),
                          ),
                          Text(mPackages[index]['payment_type'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
                        ],
                      ));
                    }),
                !isEvent  ? Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Center(child: Text(_acceptProgram ? 'ТӨЛСӨН' : "ТӨЛӨӨГҮЙ", style: TextStyle(fontSize: 16, color: Color(0xff021863), fontWeight:
                  FontWeight
                      .w800)))
                ) : Container(),
              ],
            ));
  }

  Widget drawScannedResult() {
    return Container(
        child: Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 60, bottom: 20),
          child: Text(
            "$statusText",
            style: TextStyle(fontSize: 16, color: Color(0xff021863), fontWeight: FontWeight.w600),
          ),
        ),
        starting
            ? Container(
                child: finished
                    ? Expanded(flex: 1, child: drawUserInfo())
                    : Container(
                        child: Center(
                            child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                      ))))
            : Container(),
        responseMessage != '' ? Container(child: Text('$responseMessage')) : Container(),
        mPackages.length > 0 && (isEvent || _acceptProgram)
            ? Container(
                padding: EdgeInsets.only(bottom: 20),
                child: registering
                    ? Container(
                        width: 25,
                        height: 25, //contextHeight / 13 - 4,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(StaticData.blueLogo),
                        ))
                    : RaisedButton(
                        onPressed: () => registerAttendance(),
                        child: Text('Бүртгэх',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            )),
                        color: StaticData.blueLogo,
                      ),
              )
            : Container(),
      ],
    ));
  }

  Widget drawQrScan() {
    return Container(
        child: Column(children: [
      Container(
          padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
          width: cameraHeight ?? 1,
          height: cameraHeight ?? 1,
          decoration: BoxDecoration(color: StaticData.blueLogo),
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          )),
      Container(
        margin: EdgeInsets.only(top: 60, bottom: 20),
        child: Text(
          "$statusText",
          style: TextStyle(fontSize: 16, color: Color(0xff021863), fontWeight: FontWeight.w600),
        ),
      ),
      Expanded(
          child: Container(
              padding: EdgeInsets.only(left: 40, right: 40, bottom: 40),
              alignment: Alignment.center,
              child: Column(children: [
                Expanded(flex: 1, child: Container()),
                Text(isEvent ? 'Эвэнтийн бүртгэл' : 'Хөтөлбөрийн бүртгэл', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                Text(
                  isEvent ? '${event.name}' : '${program.title}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                )
              ]))),
    ]));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      try {
        var decoded = String.fromCharCodes(base64Decode(scanData));

        ///{"user_id":14,"username":"88774777","event":215}
        try {
          Map<String, dynamic> obj = jsonDecode(decoded);
          if (obj.containsKey('username') && obj.containsKey('event')) {
            setState(() {
              statusText = 'Амжилттай уншлаа. Шалгаж байна..';
              starting = true;
            });
            checkPayment(obj);
          } else {
            setState(() {
              statusText = "Буруу QR код";
            });
          }
        } catch (e) {
          print(e.toString());
          setState(() {
            statusText = "Боловсруулж чадсангүй, дахин уншуулна уу..";
          });
        }
      } catch (e) {
        setState(() {
          statusText = "Буруу QR код";
        });
      }
    });
  }

  Future<void> checkPayment(Map<String, dynamic> obj) async {
    setState(() {
      finished = false;
      reset = false;
      cameraHeight = 10.0;
    });
    controller.dispose();
    Map<String, dynamic> params = {'user': obj['user_id'], 'event': obj['event'], 'phone': obj['username']};
    if(!isEvent){
      params['program'] = program.id;
    }
    // print('user = ' + obj['user_id'].toString() + ' event=' + obj['event'].toString() + ' phone=' + obj['username'].toString());

    String url = '${StaticUrl.getEventPaymentUrlwithDomain()}/check';
    dynamic json = await api.post(url, params: params);
    // dynamic json = await api.post(url, params: {'user': '1231231231', 'event': obj['event'], 'phone': obj['username']});
    if (json['code'] == 1000) {
      if (json['data'].containsKey('result')) {
        /// result: always false
        toast.show(json['data']['message']);
        setState(() {
          finished = true;
          hasError = true;
          statusText = 'Алдаа гарлаа, дахин уншуулна уу';
        });
      } else {
        Map<String, dynamic> member = json['data']['member'];
        List<dynamic> packages = json['data']['packages'];
        setState(() {
          finished = true;
          statusText = 'Хэрэглэгчийн мэдээлэл:';
          mMember = member;
          //username = member['firstname'];
          mPackages = packages;
          _acceptProgram = json['data']['accept'] ?? false;
          // payments.addAll(json['data']['payments']);
        });
      }
    } else {
      toast.show(json['message']);
    }
  }

  Future<void> registerAttendance() async {
    setState(() {
      registering = true;
    });
    Map<String, dynamic> params = {'user': mMember['user'], 'event': event.id};
    if(!isEvent){
      params['program'] = program.id;
    }
    String url = '${StaticUrl.getAttendanceEventByOperatorUrlwithDomain()}';
    dynamic json = await api.post(url, params: params);
    String resMessage = '';
    if (json['code'] == 1000 && json['data']['result']) {
      if (json['data']['status'] == 2) {
        // registered
        resMessage = 'Амжилттай бүртгэгдлээ';
      } else if (json['data']['status'] == 1) {
        //already registered
        resMessage = 'Бүртгэгдсэн байна';
      } else {
        resMessage = '';
      }
    } else {
      resMessage = json['message'] ?? '' + '\n Дахин оролдоно уу.';
    }
    setState(() {
      registering = false;
      responseMessage = resMessage;
    });
  }
}
