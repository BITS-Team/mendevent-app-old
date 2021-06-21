import 'package:flutter/material.dart';
import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class NotificationPage extends StatefulWidget {
  static const routeName = '/notificationPage';
  NotificationPage({Key key}) : super(key: key);
  @override
  NotificationPageState createState() {
    // TODO: implement createState
    return NotificationPageState();
  }
}

class NotificationPageState extends State<NotificationPage> {
  Database db;
  List<Notification> notifications;

  @override
  void initState() {
    super.initState();
    notifications = List();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Мэдэгдлүүд',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Color(0xff021863),
        ),
        body: Container(
          child: ListView(
            shrinkWrap: true,
            children: notifications.map((item){
              return notificationItem(item);
            }).toList(),
          )
        ));
  }

  Container notificationItem(item) {
    DateTime _date = item.date;
    String dateSlug ="${_date.year.toString()}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')} ${_date.hour.toString()
        .padLeft(2,'0')}:${_date.minute.toString().padLeft(2,'0')}:${_date.second.toString().padLeft(2,'0')}";
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
          border: Border.all(width: 0.5, color: Colors.grey[300]),borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(item.title, style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w700)),
          Text(dateSlug, style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w400)),
          Text(item.message, style: TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic))
        ],
      )
    );
  }

  init() async {
    db = await SQLiteHelper.instance.getDb();
    List<Map<String, dynamic>> records = await db.rawQuery('SELECT * '
        'FROM notifications '
        'ORDER BY id DESC '
        'LIMIT 20 ');
    List<Notification> _notifications = List();
    records.forEach((item) {
      _notifications.add(Notification.fromMap(item));
    });
    setState(() {
      notifications.addAll(_notifications);
    });
  }
}

class Notification {
  final String title;
  final String message;
  final bool isRead;
  final int type;
  final DateTime date;
  Notification({this.title, this.message, this.isRead, this.type, this.date});

  factory Notification.fromMap(Map<String, dynamic> map) {
    DateTime _date = DateTime.fromMillisecondsSinceEpoch(map['date']);
    return Notification(title: map['title'], message: map['message'], isRead: map['isRead'] == 1 ?? false, type: map['type'], date: _date);
  }
}
