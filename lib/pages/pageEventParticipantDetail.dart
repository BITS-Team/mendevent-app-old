import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventParticipant.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;

class EventParticipantDetailsPage extends StatefulWidget {
  static const routeName = '/eventParticipantDetailsPage';
  final Event event;
  final User user;
  final EventParticipant participant;
  EventParticipantDetailsPage({Key key, @required this.event, @required this.user, @required this.participant})
      : super(key: key);
  @override
  EventParticipantDetailsPageState createState() {
    return EventParticipantDetailsPageState(event, user, participant);
  }
}

class EventParticipantDetailsPageState extends State<EventParticipantDetailsPage> with SingleTickerProviderStateMixin {
  Event event;
  User user;
  EventParticipant participant;
  EventParticipantDetailsPageState(this.event, this.user, this.participant);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
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
            "${participant.name}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
//            "Оролцогч",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color(0xff021863),
        ),
        body: drawBody(),
      ),
    );
  }

  String hasLink(String text) {
    String result = "";
    if (text.indexOf('http:') > -1) {
      result = text.substring(text.indexOf('http:')).trim();
    } else if (text.indexOf('https:') > -1) {
      result = text.substring(text.indexOf('https:')).trim();
    }
    return result;
  }

  Container drawBody() {
    List<Widget> lst = List<Widget>();
    lst.add(Container(
      height: 20,
    ));

    final TextStyle aboutTextStyle =
        TextStyle(fontSize: 18, color: sData.StaticData.blueLogo, fontWeight: FontWeight.w900);
    String link = hasLink(participant.description);
    String description = participant.description;
    if (link != "") {
      description = description.substring(0, participant.description.indexOf(link));
    }
    return Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Container(
//         padding: EdgeInsets.only(bottom: 30),
        child: ListView(
          children: <Widget>[
            Container(
              child: Center(
                child: Container(
                    padding: EdgeInsets.only(top: 0),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.7,
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(100)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(const Radius.circular(100)),
                      child: participant.hasPic()
                          ? CachedNetworkImage(
                              imageUrl: '${StaticUrl.getDomainPort()}${participant.bannerUrl}',
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
                          : Image.asset('assets/default_speaker.png'),
                    )),
              ),
            ),
            Container(
                margin: EdgeInsets.only(
                  top: 30,
                ),
                child: Center(
                  child: Text(
                    participant.name,
                    maxLines: 4,
                    style: TextStyle(fontSize: 18, color: sData.StaticData.blueLogo, fontWeight: FontWeight.w900),
                  ),
                )),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Center(
                    child: Text(
                  participant.meta,
                  style: TextStyle(fontSize: 16, color: Color(0xAA000000), fontWeight: FontWeight.w700),
                ))),
            Container(
              height: 20,
            ),
            Container(
                child: Linkify(
              onOpen: _onOpen,
              text: participant.description,
              style: TextStyle(fontSize: 14, color: Color(0xAA000000), fontWeight: FontWeight.w700),
            ))
          ],
        ),
      ),
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }
}
