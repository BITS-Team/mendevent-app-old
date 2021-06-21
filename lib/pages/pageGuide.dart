import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:mend_doctor/models/modDoctor.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventFaq.dart';
import 'package:mend_doctor/models/modEventRoom.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/singletons/singletonEvent.dart';
import 'package:mend_doctor/utils/staticUrl.dart';

class GuidePage extends StatefulWidget {
  static const routeName = '/guidePage';
  final Event event;
  final User user;
  final List<EventRoom> rooms;
  GuidePage({Key key, @required this.event, @required this.user, this.rooms}) : super(key: key);
  @override
  GuidePageState createState() {
    // TODO: implement createState
    return GuidePageState(event, user, rooms);
  }
}

class GuidePageState extends State<GuidePage> {
  Event event;
  User user;
  List<EventRoom> rooms;

  GuidePageState(this.event, this.user, this.rooms);

  Doctor doctor;
  List<EventFaq> faqs;

  var expanded = Map<int, bool>();
  GlobalKey keyMain = GlobalKey();
  GlobalKey subMain = GlobalKey();
  GlobalKey scrollItem;
  var globalKeys = Map<int, GlobalKey>();
  var subKeys = Map<int, GlobalKey>();

  ScrollController _scrollController;

  double getHeightOf(int index){
    double h = 0;
    for(int i=0; i<index; i++){
      final RenderBox sbox = subKeys[i].currentContext.findRenderObject();
      h += sbox.size.height;
      final RenderBox box = globalKeys[i].currentContext.findRenderObject();
      h += box.size.height;
    }
    return h;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    faqs = List();
    expanded[0] = true;
    globalKeys[0] = keyMain;
    subKeys[0] = subMain;
    for (int i = 0; i < rooms.length; i++) {
      expanded[i + 1] = false;
      globalKeys[i + 1] = GlobalKey();
      subKeys[i + 1] = GlobalKey();
    }
    _scrollController = ScrollController();

    super.initState();
  }

  _afterLayout(_) {
  }

  @override
  Widget build(BuildContext context) {
//    WidgetsBinding.instance
//        .addPostFrameCallback((_) => executeAfterBuild());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Таны хөтөч'.toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Color.fromARGB(255, 2, 24, 99),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.share),
//            onPressed: (){},
////            onPressed: _captureAndSharePng,
//          )
//        ],
      ),
      body: Container(
          child: ListView(
        controller: _scrollController,
        children: <Widget>[
          Image.asset('assets/header_top.png'),
          drawLocationImages(),
          drawFAQsection(),
        ],
      )),
//      body: _contentWidget(),
    );
  }

  Container drawLocationImages() {
    List<Widget> lst = List<Widget>();
    lst.add(Container(
        key: subMain,
        height: 50,
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          color: expanded[0] ? Color(0xB3000000) : Color(0x80000000),
        ),
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            setState(() {
              expanded[0] = !expanded[0];
            });
          },
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            Expanded(
                flex: 1,
                child: Text(
                  'Байршил'.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w900),
                )),
            IconButton(
              icon: expanded[0]
                  ? Icon(Icons.arrow_drop_down, color: Color(0xFFFFFFFF))
                  : Icon(Icons.arrow_drop_up, color: Color(0xFFFFFFFF)),

            )
          ]),
        )));
    lst.add(Container(
        key: keyMain,
        child:
        expanded[0] ?
        CachedNetworkImage(
                imageUrl: '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(event.locationUrl)}',
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
            : Container()
            )
    );
    for (int i = 0; i < rooms.length; i++) {
      String title = '${rooms[i].roomName != '' ? rooms[i].roomName : rooms[i].roomNumber} байршил';
      lst.add(Container(
          key: subKeys[i+1],
          height: 50,
          padding: EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            borderRadius: (i == rooms.length - 1 && !expanded[i + 1])
                ? BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
                : BorderRadius.all(Radius.circular(0)),
//            color: expanded[rooms[i].id] ? Color(0xB3000000) : Color(0x80000000),
            color: expanded[i + 1] ? Color(0xB3000000) : Color(0x80000000),
          ),
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {
              scrollToPosition(i);
            },
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w900),
                  )),
              IconButton(
                icon: expanded[i+1]
                    ? Icon(Icons.arrow_drop_down, color: Color(0xFFFFFFFF))
                    : Icon(Icons.arrow_drop_up, color: Color(0xFFFFFFFF)),

              )
            ]),
          )));
      lst.add(Container(
          key: globalKeys[i+1],
          child: expanded[i + 1]
              ? CachedNetworkImage(
            imageUrl: '${StaticUrl.getDomainPort()}${StaticUrl.fixImageUrl(rooms[i].locationImg)}',
//            imageBuilder: (context, imageProvider) => Container(
//              decoration: BoxDecoration(
//                image: DecorationImage(
//                  image: imageProvider,
//                  fit: BoxFit.cover,
////                                            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.colorBurn)
//                ),
//              ),
//            ),
            placeholder: (context, url) => new CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
            ),
            errorWidget: (context, url, error) => new Icon(Icons.error),
          )
              : Container()));
    }
    return Container(
        margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
//          color: Colors.blue,
        ),
        child: Container(
            child: Column(
          children: lst,
        )));
  }

  Container drawFAQsection() {
    return Container(
        child: FutureBuilder(
      future: getFaqs(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to reload.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
                child: CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
            ));
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            faqs = snapshot.data;
            return getFaqsWidget();
        }
        return null; // unreachable
      },
    ));
  }

  Container getFaqsWidget() {
    List<Widget> lst = List<Widget>();
    int i = 1;
    for (EventFaq faq in faqs) {
      lst.add(Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(bottom: 10),
          child: Text(
            '$i. ${faq.question}',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          )));
      lst.add(Container(
        margin: EdgeInsets.only(bottom: 24),
        alignment: Alignment.centerLeft,
        child: faq.imgUrl != '' && faq.answer != ''
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      height: 60,
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: CachedNetworkImage(
                        imageUrl: '${StaticUrl.getDomainPort()}${faq.imgUrl}',
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
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        faq.answer,
                        style: TextStyle(
                          color: Color(0x80000000),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ))
                ],
              )
            : faq.answer != ''
                ? Text(
                    faq.answer,
                    style: TextStyle(
                      color: Color(0x80000000),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width - 42,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: CachedNetworkImage(
                      imageUrl: '${StaticUrl.getDomainPort()}${faq.imgUrl}',
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
                    )),
      ));
      i++;
    }
    return Container(margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10), child: Column(children: lst));
  }

  Future<List<EventFaq>> getFaqs() async {
    if (faqs != null && faqs.length > 0) {
      return faqs;
    }
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = {
      // 'Authorization': 'Bearer ' + user.jwt,
    };
    try {
      print('${StaticUrl.getEventFaqsUrlwithDomain()}?event=${event.id}&_sort=priority:ASC');
      final response = await dio.get(
        '${StaticUrl.getEventFaqsUrlwithDomain()}?event=${event.id}&_sort=priority:ASC',
      );
//    print(response.data.toString());
      if (response.statusCode == 200) {
        List<EventFaq> _faqs = List<EventFaq>();
        List<dynamic> json = jsonDecode(response.data);
        try {
          _faqs = json.map((i) => EventFaq.fromJson(i)).toList();
          eventData.setFaqs(_faqs);
        } catch (e) {}
        return _faqs;
      } else {
        throw Exception('Event has not been..');
      }
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request.data);
      return null;
    }
  }

  scrollToPosition(int inex){
    double scrollPosition = getHeightOf(inex+1);
    print('scrollController to position: $scrollPosition');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
    setState(() {
      expanded[inex+1] = !expanded[inex+1];

    });

  }
}
