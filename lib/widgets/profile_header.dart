import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:mend_doctor/utils/staticData.dart';

class Profile extends StatelessWidget {
  final String lastName;
  final String firstName;
  final String description;
  final String avatarUrl;

  const Profile({
    this.lastName,
    this.firstName,
    this.description,
    this.avatarUrl
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 4, bottom: 10, left: 20, right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 0),
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: Color(0xaa021863),
                border: Border.all(
                  width: 0.7,
                  color: Color(0x33000000),
                ),
                borderRadius: BorderRadius.all(const Radius.circular(42.5)),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(const Radius.circular(42.5)),
                  child: Center(
                      child: avatarUrl != '' ? CachedNetworkImage(
                        imageUrl: avatarUrl,
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
                        errorWidget: (context, url, error) => Center(
                            child: Text(firstName.substring(0, 1).toUpperCase() ?? "U",
                                style: TextStyle(color: StaticData.yellowLogo, fontWeight: FontWeight.w700, fontSize: 40))),
                      ) :  Center(child: Text(lastName != 'Operator' ? "ME" : "O", style: TextStyle(color: StaticData.yellowLogo, fontWeight:
                      FontWeight.w700, fontSize: 40)))
                  )
              ),
            ),
            Container(width: 20),
            Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(lastName, style: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w300, fontSize: 12)),
                    Text(firstName, style: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w700, fontSize: 16)),
                    Container(
                      height: 10,
                    ),
                    Text(description, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF000000), fontSize: 14))
                  ],
                ))
          ],
        ));
  }
}