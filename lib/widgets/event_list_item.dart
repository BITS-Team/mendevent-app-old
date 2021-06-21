import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';

import 'package:mend_doctor/utils/staticData.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/pages/pageEvent.dart';

class EventItem extends StatelessWidget {
  final Event event;

  const EventItem({
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    double contextWidth = MediaQuery.of(context).size.width;
    bool soon = DateTime.now().compareTo(event.openDate) < 0;
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      EventPage(event: event)));
        },
        child: Container(
            // width: contextWidth * 5 / 7,
            height: 280,
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
             // color: Colors.red,
                    child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
//                      color: Colors.blue,
//                       width: contextWidth * 9 / 10 - 40,
//                       decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.blue[100]),borderRadius: BorderRadius.all(Radius.circular(16))),

                      height: contextWidth * 9 / 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(16)), //sData.StaticData.r10,

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
                              width: 50,
                              height: 50,
                              color: Colors.white70,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                                ),
                              )),
                          // errorWidget: (context, url, error) => new Icon(Icons.error),
                          errorWidget: (context, url, error) => ClipRRect(borderRadius: BorderRadius.all(Radius.circular(16)),child: Image.asset('assets/event_default.webp', fit: BoxFit.fill),)
                        ),
                      ),
                    ),
                    Container(
                       // width: contextWidth * 9 / 10 - 40,
                        height: 80,
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            child: Container(
                                height: 80,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(10),
                                color: Color(0xBB000000),
                                child: Text(
                                  event.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )))),
                    soon ? Container(
                      height: 240,
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.only(top: 10),
                      child: Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.only(top: 5, left: 6),
                        decoration: BoxDecoration(
                            image: DecorationImage(image: AssetImage('assets/ribbon.webp'))
                          // image: Image.asset('assets/new_ribbon.webp', width: 50, height: 50,),),
                          // padding: EdgeInsets.only(top: 10),
                          // alignment: Alignment.topLeft,

                        ),
                        // child: Text('NEW', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w800),)
                        child: Transform.rotate(angle: - pi / 4, child: Text("Удахгүй", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800,
                            fontSize: 10)))
                      )
                      // child: Image.asset('assets/new_ribbon.webp', width: 50, height: 50,)
                    ) : Container()
                  ],
                )),
                Container(
                    height: 20,
                    margin: EdgeInsets.only(left: 30),
                    child: Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Хаана:',
                          style: TextStyle(
                            color: Color(0xff021863),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '  ${event.location}',
                          style: TextStyle(
                            color: Color(0xB3000000),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )),
                Container(
                    height: 20,
                    margin: EdgeInsets.only(left: 30),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Хэзээ:',
                          style: TextStyle(
                            color: Color(0xff021863),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '  ${event.getOpenDate()}',
                          style: TextStyle(
                            color: Color(0xB3000000),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )),
              ],
            )));
  }
}
