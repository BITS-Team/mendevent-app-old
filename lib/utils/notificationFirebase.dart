import 'package:flutter/material.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:mend_doctor/utils/staticData.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:sqflite/sqflite.dart';

class NotificationFirebase {
  NotificationFirebase(this.context, this.title, this.body, {this.imgUrl = ''});

  final BuildContext context;
  final String title;
  final String body;
  String imgUrl;

  void showNotification() async {
    Database db = await SQLiteHelper.instance.getDb();
    DateTime today = DateTime.now();
    int milliSeconds = today.millisecondsSinceEpoch;
    print('milli = $milliSeconds');
    try {
      db.insert('notifications', {"title": this.title, "message": this.body, "is_read": 0, "type": 1, "date": milliSeconds}); /// type is message type, if needed use
      /// it :)
    } catch (e, s) {
      toast.show('Warning! Notification could not save');
    }
    _showDialog(title: title, msg: body);
  }
  /// TODO: add image to UI
  void _showDialog({String title = 'Мэнд Эвэнт', String msg = '', String imgUrl = ''}) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: new Container(
                    // height: 100,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.purple,
                    decoration: BoxDecoration(
                      color: StaticData.blueLogo,
                      border: Border.all(
                        width: 0.2,
                        color: Color(0x66FFFFFF),
                      ),
                      borderRadius: BorderRadius.all(const Radius.circular(16)),
                    ),
                    child: new Column(

                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top:5),
                          child: Text(
                            title,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            msg,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
        );
  }
}
