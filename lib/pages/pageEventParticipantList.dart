import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventParticipant.dart';
import 'package:mend_doctor/pages/pageEventParticipantDetail.dart';
import 'package:mend_doctor/models/lstEventParticipantsList.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;

class EventParticipantListPage extends StatefulWidget {
  static const routeName = '/eventParticipantListPage';
  final Event event;
  final User user;
  final List<EventParticipant> participants;
  EventParticipantListPage({Key key, @required this.event, @required this.user, @required this.participants}) : super(key: key);
  @override
  EventParticipantListPageState createState() {
    return EventParticipantListPageState(event, user, participants);
  }
}

class EventParticipantListPageState extends State<EventParticipantListPage> with SingleTickerProviderStateMixin {
  Event event;
  User user;
  final List<EventParticipant> participants;
  EventParticipantListPageState(this.event, this.user, this.participants);
  EventParticipantsList _partList;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    _partList = EventParticipantsList(participants: participants);
    super.initState();
  }

  _afterLayout(_) {}

  @override
  void dispose() {
    super.dispose();
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
            "Илтгэгчид",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color(0xff021863),
        ),
        body: drawBody(),
      ),
    );
  }

  ListView drawBody() {
    return ListView(
      children: <Widget>[
        Container(
          child: Image.asset(
            'assets/header_top.png',
            fit: BoxFit.fitWidth,
          ),
        ),
        Container(
          height: 15,
        ),
        _partList.getMainOrganizers().length > 0 ? drawMainOrganizers() : Container(),
        _partList.getNormalOrganizers().length > 0 ? drawOrganizers() : Container(),
        _partList.getGoldens().length > 0 ? drawGoldens() : Container(),
        _partList.getSilvers().length > 0 ? drawSilvers() : Container(),
        _partList.getBronzes().length > 0 ? drawBronzes() : Container(),
        _partList.getNormals().length > 0 ? drawNormals() : Container(),
      ],
    );
  }

  Container drawGoldens() {
    List<Widget> list = [];
    String title = "";
    if (_partList.getGoldens().length > 0) title = _partList.getGoldens()[0].meta;
    for (EventParticipant es in _partList.getGoldens()) {
      GestureDetector con = GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventParticipantDetailsPage(
                          event: event,
                          user: user,
                          participant: es,
                        )));
          },
          child: Container(
              width: (MediaQuery.of(context).size.width - 70) / 3 - 20,
              child: Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 0),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                      child: es.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${es.bannerUrl}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
//                                            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.colorBurn)
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => new CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                              ),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Center(
                              child: Text(es.name.substring(0, 1),
                                  style: TextStyle(
                                      color: sData.StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      '${es.name}',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w700),
                    )),
              ])));
      list.add(con);
    }
    return Container(
      child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(left: 20, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 3, bottom: 3, left: 5),
                color: Color(0x10000000),
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 2, 24, 99), fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                  width: MediaQuery.of(context).size.width - 70,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                          width: MediaQuery.of(context).size.width - 70,
                          child: GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: 0.88,
                            physics: ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: list,
                          )),
                    ],
                  )),
            ],
          )),
    );
  }

  Container drawSilvers() {
    List<Widget> list = [];
    String title = "";
    if (_partList.getSilvers().length > 0) title = _partList.getSilvers()[0].meta;
    for (EventParticipant es in _partList.getSilvers()) {
      GestureDetector con = GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventParticipantDetailsPage(
                          event: event,
                          user: user,
                          participant: es,
                        )));
          },
          child: Container(
              width: (MediaQuery.of(context).size.width - 70) / 3 - 20,
              child: Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 0),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                      child: es.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${es.bannerUrl}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
//                                            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.colorBurn)
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => new CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                              ),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Center(
                              child: Text(es.name.substring(0, 1),
                                  style: TextStyle(
                                      color: sData.StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      '${es.name}',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w700),
                    )),
              ])));
      list.add(con);
    }
    return Container(
      child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(left: 20, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 3, bottom: 3, left: 5),
                color: Color(0x10000000),
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 2, 24, 99), fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                  width: MediaQuery.of(context).size.width - 70,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                          width: MediaQuery.of(context).size.width - 70,
                          child: GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: 0.88,
                            physics: ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: list,
                          )),
                    ],
                  )),
            ],
          )),
    );
  }

  Container drawBronzes() {
    List<Widget> list = [];
    String title = "";
    if (_partList.getBronzes().length > 0) title = _partList.getBronzes()[0].meta;
    for (EventParticipant es in _partList.getBronzes()) {
      GestureDetector con = GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventParticipantDetailsPage(
                          event: event,
                          user: user,
                          participant: es,
                        )));
          },
          child: Container(
              width: (MediaQuery.of(context).size.width - 70) / 3 - 20,
              child: Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 0),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                      child: es.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${es.bannerUrl}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
//                                            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.colorBurn)
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => new CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                              ),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Center(
                              child: Text(es.name.substring(0, 1),
                                  style: TextStyle(
                                      color: sData.StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      '${es.name}',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w700),
                    )),
              ])));
      list.add(con);
    }
    return Container(
      child: list.length != 0
          ? Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 3, bottom: 3, left: 5),
                    color: Color(0x10000000),
                    child: Text(
                      title.toUpperCase(),
                      style:
                          TextStyle(fontSize: 12, color: Color.fromARGB(255, 2, 24, 99), fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 70,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                              width: MediaQuery.of(context).size.width - 70,
                              child: GridView.count(
                                crossAxisCount: 3,
                                childAspectRatio: 0.88,
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: list,
                              )),
                        ],
                      )),
                ],
              ))
          : Container(),
    );
  }

  Container drawNormals() {
    List<Widget> list = [];
    String title = "";
    if (_partList.getNormals().length > 0) title = _partList.getNormals()[0].meta;
    for (EventParticipant es in _partList.getNormals()) {
      GestureDetector con = GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventParticipantDetailsPage(
                          event: event,
                          user: user,
                          participant: es,
                        )));
          },
          child: Container(
              width: (MediaQuery.of(context).size.width - 70) / 3 - 20,
              child: Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 0),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                      child: es.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${es.bannerUrl}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
//                                            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.colorBurn)
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => new CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                              ),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Center(
                              child: Text(es.name.substring(0, 1),
                                  style: TextStyle(
                                      color: sData.StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      '${es.name}',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w700),
                    )),
              ])));
      list.add(con);
    }
    return Container(
      child: list.length != 0
          ? Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 3, bottom: 3, left: 5),
                    color: Color(0x10000000),
                    child: Text(
                      title.toUpperCase(),
                      style:
                          TextStyle(fontSize: 12, color: Color.fromARGB(255, 2, 24, 99), fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 70,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                              width: MediaQuery.of(context).size.width - 70,
                              child: GridView.count(
                                crossAxisCount: 3,
                                childAspectRatio: 0.88,
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: list,
                              )),
                        ],
                      )),
                ],
              ))
          : Container(),
    );
  }

  Container drawMainOrganizers() {
    List<Widget> list = [];
    String title = "";
    if (_partList.getMainOrganizers().length > 0) title = _partList.getMainOrganizers()[0].meta;
    for (EventParticipant es in _partList.getMainOrganizers()) {
      GestureDetector con = GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventParticipantDetailsPage(
                          event: event,
                          user: user,
                          participant: es,
                        )));
          },
          child: Container(
              width: (MediaQuery.of(context).size.width - 70) / 3 - 20,
              child: Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 0),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                      child: es.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${es.bannerUrl}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
//                                            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.colorBurn)
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => new CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                              ),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Center(
                              child: Text(es.name.substring(0, 1),
                                  style: TextStyle(
                                      color: sData.StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      '${es.name}',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w700),
                    )),
              ])));
      list.add(con);
    }
    return Container(
      child: list.length != 0
          ? Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 3, bottom: 3, left: 5),
                    color: Color(0x10000000),
                    child: Text(
                      title.toUpperCase(),
                      style:
                          TextStyle(fontSize: 12, color: Color.fromARGB(255, 2, 24, 99), fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 70,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                              width: MediaQuery.of(context).size.width - 70,
                              child: GridView.count(
                                crossAxisCount: 3,
                                childAspectRatio: 0.88,
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: list,
                              )),
                        ],
                      )),
                ],
              ))
          : Container(),
    );
  }

  Container drawOrganizers() {
    List<Widget> list = [];
    String title = "";
    if (_partList.getNormalOrganizers().length > 0) title = _partList.getNormalOrganizers()[0].meta;
    for (EventParticipant es in _partList.getNormalOrganizers()) {
      GestureDetector con = GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventParticipantDetailsPage(
                          event: event,
                          user: user,
                          participant: es,
                        )));
          },
          child: Container(
              width: (MediaQuery.of(context).size.width - 70) / 3 - 20,
              child: Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 0),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(30)),
                      child: es.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${es.bannerUrl}',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
//                                            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.colorBurn)
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => new CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                              ),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            )
                          : Center(
                              child: Text(es.name.substring(0, 1),
                                  style: TextStyle(
                                      color: sData.StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      '${es.name}',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xCC000000), fontWeight: FontWeight.w700),
                    )),
              ])));
      list.add(con);
    }
    return Container(
      child: list.length != 0
          ? Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 3, bottom: 3, left: 5),
                    color: Color(0x10000000),
                    child: Text(
                      title.toUpperCase(),
                      style:
                          TextStyle(fontSize: 12, color: Color.fromARGB(255, 2, 24, 99), fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 70,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                              width: MediaQuery.of(context).size.width - 70,
                              child: GridView.count(
                                crossAxisCount: 3,
                                childAspectRatio: 0.88,
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: list,
                              )),
                        ],
                      )),
                ],
              ))
          : Container(),
    );
  }
}
