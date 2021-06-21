import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mend_doctor/models/lstEventParticipantsList.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventParticipant.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modEventRoom.dart';
import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/pages/pageEventInvoice.dart';
import 'package:mend_doctor/pages/pageEventParticipantDetail.dart';
import 'package:mend_doctor/pages/pageEventParticipantList.dart';
import 'package:mend_doctor/pages/pageEventQrCode.dart';
import 'package:mend_doctor/pages/pageEventSpeakerDetails.dart';
import 'package:mend_doctor/pages/pageEventSpeakerList.dart';
import 'package:mend_doctor/pages/pageExhibition.dart';
import 'package:mend_doctor/pages/pageGuide.dart';
import 'package:mend_doctor/pages/pageInitialize.dart';
import 'package:mend_doctor/pages/pageMyPrograms.dart';
import 'package:mend_doctor/pages/pageQRscan.dart';
import 'package:mend_doctor/singletons/singletonEvent.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:sqflite/sqflite.dart';

class EventInfo extends StatefulWidget {
  static const routeName = '/eventSchedulePage';
  final Event event;
  final List<EventParticipant> participants;
  final String mainOrganizer;
  final List<EventRoom> rooms;
  final TabController tabController;
  EventInfo({Key key, @required this.event, this.participants, this.mainOrganizer, this.rooms, this.tabController}) : super(key: key);
  @override
  EventInfoState createState() => EventInfoState(event, participants, mainOrganizer, rooms, tabController);
}

class EventInfoState extends State<EventInfo> {
  final storage = new FlutterSecureStorage();
  Event event;
  User user;
  List<EventParticipant> participants;
  String mainOrganizer;
  List<EventRoom> rooms;
  TabController tabController;
  EventInfoState(this.event, this.participants, this.mainOrganizer, this.rooms, this.tabController);

  GlobalKey _banner = GlobalKey();
  GlobalKey _elevatedContainer = GlobalKey();
  GlobalKey _infoText = GlobalKey();

  double marginInfo = 100;
  double elevatedContainerWidth = 100;
  double infoTextHeight;

  bool expandedInfo = true;

//  String zohionBaiguulagch = "";
  bool _isRegistered = false;
  int _hasExhibition = 0;
  bool paid = false;

  Database db;

  ///states
  List<EventSpeaker> featuredSpeakers;
  bool isOperator = false;

  @override
  void initState() {
    featuredSpeakers = List();

    super.initState();
    init();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  _afterLayout(_) {
    setState(() {
      elevatedContainerWidth = _getElevatedContainerWidth();
      marginInfo = _getBannerHeight() > 20 ? _getBannerHeight() - 20 : 10;
      infoTextHeight = _getInfoTextHeight();
      expandedInfo = false;
    });
    setHasExhibition();
  }

  Future<void> init() async {
    String mendUser = await storage.read(key: 'mendUser') ?? '';
    user = User.fromJson(jsonDecode(mendUser));
    db = await SQLiteHelper.instance.getDb();
    getFeaturedSpeakers();
    setState(() {
      isOperator = user.roleId == 8;
    });
  }

  _expandInfo() {
    setState(() {
      expandedInfo = !expandedInfo;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 0),
      child: RefreshIndicator(
        child: ListView(
          children: <Widget>[
            drawEventHeader(),
            Container(
              height: 10,
            ),
            event.openDate.compareTo(DateTime.now()) > 0 ? drawButtons() : Container(),
            Container(
              height: 10,
            ),
            drawSpeakers(featuredSpeakers),
            drawParticipants(participants),
            drawEventMenus(),
            Container(
              height: 30,
            ),
          ],
        ),
        onRefresh: refreshData,
      ),
    );
  }

  double _getBannerHeight() {
    final RenderBox bannerBox = _banner.currentContext.findRenderObject();
    return bannerBox.size.height;
    return 100;
  }

  double _getElevatedContainerWidth() {
    final RenderBox elevatedContainer = _elevatedContainer.currentContext.findRenderObject();
    return elevatedContainer.size.width;
    return 100;
  }

  double _getInfoTextHeight() {
    final RenderBox infoText = _infoText.currentContext.findRenderObject();
    return infoText.size.height;
    return 100;
  }

  Container drawEventHeader() {
    return Container(
        child: Stack(
      children: <Widget>[
        Stack(
          key: _banner,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              height: 250,
              child: CachedNetworkImage(
                imageUrl: '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(event.bannerUrls[0])}',
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
                    color: Colors.white70,
                    child: Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 1,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                    ))),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
//                    FadeInImage.memoryNetwork(
//                  placeholder: kTransparentImage,
//                  image: StaticUrl.getDomainPort() + this.event.bannerUrls[0],
//                )
            ),
//            Image.network(
//              StaticUrl.getDomainPort() + this.event.bannerUrls[0],
//            ),
            Image.asset('assets/header_top.png'),
          ],
        ),
        Card(
            elevation: 8,
            key: _elevatedContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Color.fromARGB(255, 2, 24, 99), //rgba(2, 24, 99, 1)
            margin: EdgeInsets.only(top: marginInfo, left: 20, right: 20),
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Text(
                      event.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                getWhen(),
                getWhere(),
                getHosts(),
                GestureDetector(
                    onTap: () {
                      _expandInfo();
                    },
                    child: Container(
                        margin: EdgeInsets.only(left: 40, right: 40, top: 20),
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            'Хурлын танилцуулга'.toUpperCase(),
                            style: TextStyle(
                              color: Color(0xff021863),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))),
                // expandedInfo
                //     ? Container(
                //         padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
                //         child: Text(
                //           '${event.generalInfo}',
                //           textAlign: TextAlign.justify,
                //           style: TextStyle(
                //             color: Color(0xFFFFFFFF),
                //             fontSize: 12,
                //             fontWeight: FontWeight.w300,
                //           ),
                //         ),
                //       )
                //     : Container(),
                AnimatedContainer(
                  key: _infoText,
                  height: expandedInfo ? infoTextHeight : 0,
                  padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
                  duration: Duration(seconds: 2),
                  curve: Curves.fastOutSlowIn,
                  child: Text(
                    '${event.generalInfo}',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  width: 100,
                )
              ],
            ))
      ],
    ));
  }

  Container getWhen() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 0, top: 10),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.event_available,
//              color: Color.fromARGB(255, 255, 255, 255),
              color: Color(0xFFfdb92e),
            ),
            Container(
                padding: EdgeInsets.only(left: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center,
//                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Хэзээ: '.toUpperCase(),
                        style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w400),
                      ),
                      Text(
//                        getDate(open, close),
                        getOpenDate(),
                        style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w600),
                      ),
                    ]))
          ],
        ));
  }

  Container getWhere() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 10, top: 10),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.location_on,
              color: Color(0xFFfdb92e),
            ),
            Container(
                padding: EdgeInsets.only(left: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  Text(
                    'Хаана:'.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w400),
                  ),
                  Text(
                    event.location,
                    style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w600),
                  )
                ]))
          ],
        ));
  }

  Container getHosts() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 10, top: 10),
//        width: 100,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.people,
              color: Color(0xFFfdb92e),
            ),
            Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text(
                    'Зохион байгуулагч:'.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w400),
                  ),
                  Container(
                    width: elevatedContainerWidth > 130 ? elevatedContainerWidth - 130 : 100,
                    child: Container(
                        child: Text(
                      mainOrganizer,
                      maxLines: 3,
                      softWrap: true,
                      style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w600),
                    )),
                  )
                ]))
          ],
        ));
  }

  Container drawButtons() {
    ///HardCoded
    return Container(
        padding: EdgeInsets.only(top: 10, right: 20, left: 20),
        alignment: Alignment.center,
        child: Row(
          children: <Widget>[
//            Expanded(
//              flex: 1,
//              child: Container(
//                height: 30,
//              ),
//            ),
            GestureDetector(
              onTap: () {
                btnClick('qrcode');
              },
              child: Container(
                height: 30,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(const Radius.circular(10)),
                  color: Color(0xff021863),
                ),
                child: Text(
                  isOperator ? 'Ирц бүртгэх'.toUpperCase() : 'Миний QR код'.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 30,
              ),
            ),
            isOperator
                ? Container()
                : GestureDetector(
                    onTap: () {
                      btnClick('register');
                    },
                    child: Container(
                      height: 30,
                      width: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(const Radius.circular(10)),
                        color: Color.fromARGB(255, 253, 185, 46),
                      ),
                      child: Text(
                        !_isRegistered ? 'Бүртгүүлэх'.toUpperCase() : 'Бүртгүүлсэн'.toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
          ],
        ));
  }

  String getDate(DateTime open, DateTime close) {
    String date = '${open.month} сарын ${open.day}/${open.hour}:${open.minute} '
        '- ${close.month} сарын ${close.day}/${close.hour}:${close.minute}';
    return date;
  }

  String getOpenDate() {
    return DateFormat('yyyy.MM.dd - kk:mm').format(event.openDate);
  }

  void btnClick(String lbl) {
    switch (lbl) {
      case "register":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventInvoicePage(
                      event: event,
                    )));
        break;
      case "qrcode":
        doWithQr();
        break;
      default:
        break;
    }
  }

  void doWithQr() {
    if (isOperator) {
      //operator
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QRViewScan(
                    event: event,
                  )));
    } else {
      //event member
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QrCodePage(
                    event: event,
                  )));
    }
  }

  GestureDetector speakerListItem(EventSpeaker es) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventSpeakerDetailsPage(
                        event: event,
                        speaker: es,
                      )));
        },
        child: Container(
            child: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.only(top: 0),
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.7,
                  color: Color(0x33000000),
                ),
                borderRadius: BorderRadius.all(const Radius.circular(38)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(const Radius.circular(38)),
                child: es.hasPic()
                    ? CachedNetworkImage(
                        imageUrl: '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(es.picUrl)}',
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => new CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                        ),
                        errorWidget: (context, url, error) => new Icon(Icons.error),
                      )
                    : Image.asset('assets/default_speaker.png'),
              )),
          Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Text(
                '${es.name}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w700),
              )),
          Container(
              child: Text(
            '${es.position}',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0x80000000),
            ),
          ))
        ])));
  }

  Container drawSpeakers(List<EventSpeaker> speakers) {
    List<Widget> list = [];
    speakers.forEach((es) {
      list.add(speakerListItem(es));
    });
    return Container(
        padding: EdgeInsets.only(left: 20, right: 15, top: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Text(
                        'Илтгэгчид'.toUpperCase(),
                        style: TextStyle(fontSize: 12, color: Color(0xb8000000), fontWeight: FontWeight.w900),
                      )),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventSpeakerListPage(
                                    event: event,
                                  )));
                    },
                    child: Container(
                        padding: EdgeInsets.only(left: 30),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Text(
                              'БҮГД'.toUpperCase(),
                              style: TextStyle(fontSize: 12, color: Color(0xb8000000), fontWeight: FontWeight.w900),
                            ),
                            Icon(Icons.navigate_next, color: Color(0xb8000000))
                          ],
                        )),
                  ),
                ],
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width - 70,
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 0.68,
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: list,
              )),
        ]));
  }

  Container drawParticipants(List<EventParticipant> participants) {
    //TODO: bas l zawaartuulsan, zalhuursan bish LOGIC utgagui bolchihloo
    EventParticipantsList epl = EventParticipantsList(participants: participants);
    List<Widget> list = [];
    if (epl.participants.length == 0) return Container();
    int iLength = epl.getOrderedList().length;

    int mainSponsor = 0;
    int subSponsor = 0;
    if (iLength > 4) {
      mainSponsor = 2;
      subSponsor = 5;
    } else if (iLength > 1) {
      mainSponsor = 2;
      subSponsor = iLength;
    } else if (iLength < 2) {
      mainSponsor = 1;
      subSponsor = 1;
    }
    int i = 0;
    for (EventParticipant es in epl.getOrderedList()) {
      if (!es.participantType.toUpperCase().contains("зохион".toUpperCase())) {
        Container con;
        if (i < 2) {
          con = Container(
//          height: 400,
              width: (MediaQuery.of(context).size.width - 70) / 2 - 15,
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(60.0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(60)),
                      child: es.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(es.bannerUrl)}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => new CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                              ),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Image.asset('assets/sponsor_grey.png'),
                    )),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 70) / 3 - 15,
                      child: Text(
                        '${es.name}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w900),
                      )),
                  Container(
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 70) / 2 - 15,
                      child: Text(
                        '${es.meta}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0x80000000),
                        ),
                      ))
                ])),
              ])));
        } else if (i < 5) {
          con = Container(
              width: (MediaQuery.of(context).size.width) / 3 - 15,
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(40.0) //                 <--- border radius here
                          ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(40)),
                      child: es.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${es.bannerUrl}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => new CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                              ),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Image.asset('assets/sponsor_grey.png'),
                    )),
                Expanded(
                    child: Column(children: <Widget>[
                  Container(
//              height: 60,
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 70) / 2 - 15,
                      child: Text(
                        '${es.name}',
                        style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w900),
                      )),
                  Container(
                      //                height: 40,
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 70) / 2 - 15,
                      child: Text(
                        '${es.meta}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0x80000000),
                        ),
                      ))
                ])),
              ])));
        } else {
          continue;
        }
        list.add(GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventParticipantDetailsPage(
                            event: event,
                            participant: es,
                          )));
            },
            child: con));
      }
      i++;
    }

    return Container(
        padding: EdgeInsets.only(left: 20, right: 15, top: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Container(
              child: Row(
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Text(
                    'Ивээн тэтгэгчид'.toUpperCase(),
                    style: TextStyle(fontSize: 12, color: Color(0xb8000000), fontWeight: FontWeight.w900),
                  )),
              GestureDetector(
                onTap: () {
                  //tabController.animateTo(2);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EventParticipantListPage(event: event, participants: participants)));
                },
                child: Container(
                    padding: EdgeInsets.only(left: 30),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'БҮГД'.toUpperCase(),
                          style: TextStyle(fontSize: 12, color: Color(0xb8000000), fontWeight: FontWeight.w900),
                        ),
                        Icon(Icons.navigate_next, color: Color(0xb8000000))
                      ],
                    )),
              ),
            ],
          )),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: SizedBox(
                  child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: list.sublist(0, mainSponsor),
              ))),
          subSponsor - mainSponsor > 0
              ? SizedBox(
                  width: MediaQuery.of(context).size.width - 70,
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: list.sublist(mainSponsor, subSponsor),
                  ))
              : Container(),
        ]));
  }

  Container drawEventMenus() {
    return Container(
        child: Column(
      children: <Widget>[
        GestureDetector(
            onTap: () {
              tabController.animateTo(1);
            },
            child: Container(
                padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Хурлын хөтөлбөр'.toUpperCase(),
                          style: TextStyle(
                            color: Color(0xff021863),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    Icon(
                      Icons.navigate_next,
                      color: Color(0xff021863),
                    )
                  ],
                ))),
        GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GuidePage(event: event, rooms: rooms)));
            },
            child: Container(
                padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Таны хөтөч'.toUpperCase(),
                          style: TextStyle(
                            color: Color(0xff021863),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    Icon(
                      Icons.navigate_next,
                      color: Color(0xff021863),
                    )
                  ],
                ))),
        _hasExhibition > 0
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExhibitionPage(
                                event: event,
                                numberExhib: _hasExhibition,
                                paid: paid,
                              )));
                },
                child: Container(
                    padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 5),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: Text(
                              'Үзэсгэлэн'.toUpperCase(),
                              style: TextStyle(
                                color: Color(0xff021863),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                        Icon(
                          Icons.navigate_next,
                          color: Color(0xff021863),
                        )
                      ],
                    )))
            : Container(),
        GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPrograms(eventId: event.id)));
            },
            child: Container(
                padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Миний хөтөлбөр'.toUpperCase(),
                          style: TextStyle(
                            color: Color(0xff021863),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    Icon(
                      Icons.navigate_next,
                      color: Color(0xff021863),
                    )
                  ],
                )))
      ],
    ));
  }

  Future<void> setHasExhibition() async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      // 'Authorization': 'Bearer ' + user.jwt,
    };

    int hasExhibition = 0;
    try {
      final response = await dio.get(
        '${StaticUrl.getEventExhibitionsUrlwithDomain()}/count?event=${event.id}',
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.data);
        hasExhibition = json;
      } else {
        throw Exception('Event has not been..');
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
//      return null;
    }

    if (!mounted) return;
    if (hasExhibition > 0) {
      setState(() {
        _hasExhibition = hasExhibition;
      });
    }
  }

  Future<void> getFeaturedSpeakers() async {
    /// get speakers of the Event
    List<Map<String, dynamic>> countSpeakers = await db.rawQuery('SELECT count(id) cnt FROM speakers WHERE event_id = ${event.id}');
    List<dynamic> result = List();
    List<EventSpeaker> list = List();
    if (!(countSpeakers.length > 0 && countSpeakers[0]['cnt'] > 0)) {
      String url = '${StaticUrl.getEventSpeakerUrlwithDomain()}/list';
      dynamic json = await api.get(url, params: {'events': event.id}, auth: false);
      if (json['code'] == 1000) {
        if (json['data'].length > 0) {
          json['data'].forEach((sp) => {list.add(EventSpeaker.fromJson(sp))});
        }
        await db.transaction((txn) async {
          var batch = txn.batch();
          list.forEach((speaker) async {
            batch.insert('speakers', speaker.toMap());
            batch.rawInsert(
                'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['speaker', speaker.id, 'picUrl', speaker.picUrl]);
          });

          result = await batch.commit();
        }).catchError((e) {
          toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
          Future.delayed(const Duration(milliseconds: 2000), () {
            exit(0);
          });
        });
      } else {
        toast.show(json['message']);
      }
    }
    list.clear();
    List<Map<String, dynamic>> recordSpeakers = await db.rawQuery(
      'select r.event_id, r.speaker_id, r.name, r.description, r.is_featured, r.career, r.position, i.img_path picture '
      'from speakers r '
      'left join (SELECT * FROM images where related_type = "speaker") i on i.related_id = r.speaker_id '
      'where r.event_id = ${event.id} '
      'order by r.is_featured desc '
      'limit 6',
    );
    recordSpeakers.forEach((record) {
      list.add(EventSpeaker.fromMap(record));
    });

    setState(() {
      featuredSpeakers.addAll(list);
    });
  }

  Future<void> refreshData() async {
    ///TODO: Ene hesgiig saijruulahgui bol unen bolohgui shdee..
    /// ene hiij baigaa n buh data-g ustgaad dahij achaallaj bgaan
    /// Server taldaa oorchlolt orson entity=nuudiig update hiideg bolgoh heregtei
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.rawQuery("DELETE FROM events WHERE event_id = ${event.id};");

      batch.rawQuery("DELETE FROM images WHERE related_type = \'event\' and related_id = ${event.id};");

      batch.rawQuery("DELETE FROM images WHERE related_type = \'speaker\' and related_id in "
          "(SELECT speaker_id FROM speakers WHERE event_id = ${event.id});");
      batch.rawQuery("DELETE FROM images WHERE related_type = \'room\' and related_id in "
          "(SELECT room_id FROM rooms WHERE event_id = ${event.id});");
      batch.rawQuery("DELETE FROM images WHERE related_type = \'participants\' and related_id in "
          "(SELECT participant_id FROM participants WHERE event_id = ${event.id});");

      batch.rawQuery("DELETE FROM speaker_program WHERE speaker_id in "
          "(SELECT participant_id FROM participants WHERE event_id IN "
          "(SELECT speaker_id FROM speakers WHERE event_id = ${event.id}));");

      batch.rawQuery("DELETE FROM speakers WHERE event_id = ${event.id};");
      batch.rawQuery("DELETE FROM rooms WHERE event_id = ${event.id};");
      batch.rawQuery("DELETE FROM participants WHERE event_id = ${event.id};");
      batch.rawQuery("DELETE FROM programs WHERE event_id = ${event.id};");

      await batch.commit();
    }).catchError((e) {
      toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
      Future.delayed(const Duration(milliseconds: 2000), () {
        exit(0);
      });
    });
    List<dynamic> test = await db.rawQuery("SELECT COUNT(*) FROM programs WHERE event_id = ${event.id}");
    print('test = $test');
    await getData();
  }

  Future<void> getData() async {
    participants.clear();
    featuredSpeakers.clear();

    Database db = await SQLiteHelper.instance.getDb();

    dynamic json = await api.get('${StaticUrl.getEventUrlwithDomain()}?id=${event.id}', auth: false);
    if (json['code'] == 1000) {
      Event _event = Event.fromJson(json['data']['list'][0]);
      List<dynamic> result = List();
      await db.transaction((txn) async {
        ///TODO: if event has already inserted ignore it
        var batch = txn.batch();
        String bannerUrl = _event.bannerUrls.length > 0 ? _event.bannerUrls[0] : '';
        // await txn.insert('events', event.toMap());
        batch.insert('events', _event.toMap());
        batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', _event.id, 'bannerUrl', bannerUrl]);
        batch.rawInsert(
            'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['event', _event.id, 'locationUrl', _event.locationUrl]);
        result = await batch.commit();
      }).catchError((e) {
        toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
        Future.delayed(const Duration(milliseconds: 2000), () {
          exit(0);
        });
      });
      event = _event;
    } else {
      toast.show(json['message']);
    }
    /// get participants of the Event
    Map<String, dynamic> params = {'event': event.id};
    json = await api.get('${StaticUrl.getEventParticipantsUrlwithDomain()}/list', params: params, auth: false);
    if (json['code'] == 1000) {
      if (json['data'].length > 0) {
        print('participant list length = ${json['data'].length}');
        json['data'].forEach((sp) => {participants.add(EventParticipant.fromJson(sp))});
        print('parsed participants length = ${participants.length}');
        await db.transaction((txn) async {
          var batch = txn.batch();
          participants.forEach((participant) async {
            batch.insert('participants', participant.toMap());
            batch.rawInsert('INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)',
                ['participant', participant.id, 'bannerUrl', participant.bannerUrl]);
          });
          await batch.commit();
        }).catchError((e) {
          toast.show('Алдаа гарлаа.\nТа апп-аа устгаад дахин суулгана уу..', gravity: ToastGravity.TOP, length: 2);
          Future.delayed(const Duration(milliseconds: 2000), () {
            exit(0);
          });
        });
      }
    } else {
      toast.show('Ивээн тэтгэгчдийн мэдээлэл олдсонгүй');
    }

    /// get rooms of the Event
    json = await api.get('${StaticUrl.getEventRoomsUrlwithDomain()}/list', params: params, auth: false);
    List<EventRoom> eventRooms = List();
    if (json['code'] == 1000) {
      if (json['data'].length > 0) {
        json['data'].forEach((sp) => {eventRooms.add(EventRoom.fromJson(sp))});
        await db.transaction((txn) async {
          var batch = txn.batch();
          eventRooms.forEach((room) async {
            batch.insert('rooms', room.toMap());
            batch.rawInsert(
                'INSERT INTO images (related_type, related_id, field, img_path) values (?,?,?,?)', ['room', room.id, 'locationImg', room.locationImg]);
          });
          await batch.commit();
        }).catchError((e) {
          toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
          Future.delayed(const Duration(milliseconds: 2000), () {
            exit(0);
          });
        });
      }
    } else {
      toast.show('Хурлын танхимуудын мэдээлэл олдсонгүй');
    }

    /// get programs of the Event-

    json = await api.get('${StaticUrl.getEventSchedulesUrlwithDomain()}/list', params: params, auth: false);
    List<EventProgramItem> programs = List();
    if (json['code'] == 1000) {
      if (json['data'].length > 0) {
        json['data'].forEach((sp) => {programs.add(EventProgramItem.fromJson(sp))});
        await db.transaction((txn) async {
          var batch = txn.batch();
          programs.forEach((programItem) async {
            batch.insert('programs', programItem.toMap());
          });
          await batch.commit();
        }).catchError((e) {
          toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
          Future.delayed(const Duration(milliseconds: 2000), () {
            exit(0);
          });
        });
      }
    } else {
      toast.show(json['message']);
    }

    json = await api.get('${StaticUrl.getEventSpeakerProgramUrlwithDomain()}/list', params: {'event': event.id}, auth: false);
    List<SpeakerProgram> speakerPrograms = List();
    if (json['code'] == 1000 && json['data']['result']) {
      if (json['data']['data'].length > 0) {
        json['data']['data'].forEach((sp) => {speakerPrograms.add(SpeakerProgram.fromJson(sp))});
        await db.transaction((txn) async {
          var batch = txn.batch();
          speakerPrograms.forEach((sp) async {
            batch.insert('speaker_program', sp.toMap());
          });
          await batch.commit();
        }).catchError((e) {
          toast.show('Алдаа гарлаа.\nТа апп-аа дахин нээнэ үү..', gravity: ToastGravity.TOP, length: 2);
          Future.delayed(const Duration(milliseconds: 2000), () {
            exit(0);
          });
        });
      }
    } else {
      toast.show(json['message'] ?? json['data']['message']);
    }

    await getFeaturedSpeakers();
    // if (!mounted) return;
    setState((){});
  }

  showQRcodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Text(
              'Уучлаарай!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF021863),
              ),
            ),
            elevation: 10,
//          backgroundColor: Color(0xFF021863),
            backgroundColor: Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            titlePadding: EdgeInsets.only(top: 16, left: 30),
            contentPadding: EdgeInsets.all(10),
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(bottom: 10, left: 30, top: 20),
                  child: Text(
                    '${eventData.mProfile.firstName} ${eventData.mProfile.lastName} та',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF021863),
                    ),
                  )),
              Container(
                  margin: EdgeInsets.only(left: 20, bottom: 20),
                  child: Text('  Эвэнтэд бүртгүүлсний дараа QR код болон төлбөрийн кодоо харах боломжтой болно.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF021863),
                      ))),
              Container(
                  margin: EdgeInsets.only(top: 10, left: 20, bottom: 30),
                  child: Text('  Бүртгүүлэх товчийг дарж эвэнтэд бүртгүүлэх бөгөөд \"ТАНЫ ХӨТӨЧ\" цэснээс дэлгэрэнгүй мэдээлэл уншина уу..',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF021863),
                      ))),
              FlatButton(
                child: new Text("Хаах", style: TextStyle(color: Color(0xFF021863), fontSize: 13)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ]);
      },
    );
  }

  String formatTwoDecimal(int a) {
    if (a < 10) return '0$a';
    return '$a';
  }

  String capitalizeString(String str) {
    if (str.length > 1) {
      String first = str.substring(0, 1);
      String tail = str.substring(1, str.length);
      return '$first'.toUpperCase() + '$tail';
    } else if (str.length == 1) {
      return str.toUpperCase();
    }
    return '';
  }
}
