import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mend_doctor/models/modImage.dart';

class Event {
  final String name;
  final String generalInfo;
  final int id;
  final String location;
  final DateTime openDate;
  final DateTime closeDate;

  String locationUrl;
  List<String> bannerUrls;
  List<String> buildingUrls;

  String baUrl;
  String buUrl;

  int tableId;
//  final List<dynamic> eventSchedules;

  Event(
      {this.name,
        this.generalInfo,
        this.id,
        this.locationUrl,
        this.location,
        this.openDate,
        this.closeDate,
        this.bannerUrls,
        this.buildingUrls,
      });

  factory Event.fromJson(Map<String, dynamic> json) {

    List _banners = List<String>();
    List _buildings = List<String>();
    if(json.containsKey('banner') && json['banner'] != null){
      for(Map<String, dynamic> banner in json['banner']){
        _banners.add(banner['url']);
      }
    }
    if(json.containsKey('building') && json['building'] != null){
      for(Map<String, dynamic> building in json['building']){
        _buildings.add(building['url']);
      }
    }
    return Event(
        name: json['name'],
        generalInfo: json['general_info'] ?? '',
        id: json['id'],
        locationUrl: (json.containsKey('location') && json['location']!= null) ? json['location']['url'] : '',
        openDate: DateTime.parse(json['open_time']),
        closeDate: DateTime.parse(json['close_time']),
        bannerUrls: _banners,
        buildingUrls: _buildings,

        location: json['location_desc']
    );
  }



  String getOpenMonth(){
    if(openDate.month < 10)
      return '0${openDate.month}';
    return '${openDate.month}';
  }

  String getOpenDay(){
    if(openDate.day < 10)
      return '0${openDate.day}';
    return openDate.day.toString();
  }

  String getOpenHour(){
    if(openDate.hour < 10)
      return '0${openDate.hour}';
    return '${openDate.hour}';
  }
  String getOpenMinute(){
    if(openDate.minute < 10)
      return '0${openDate.minute}';
    return '${openDate.minute}';
}

  String getOpenDate(){
    return '${openDate.year}.${getOpenMonth()}.${getOpenDay()} - ${getOpenHour()}:${getOpenMinute()}';
  }


  int getHowManyDays(){
    return closeDate.difference(openDate).inDays + 1;
  }

  List<int> getDays(){
    List<int> days = [];
    for(int i = openDate.day; i <= closeDate.day; i++){
      days.add(i);
    }

    return days;
  }

  /// SQLite

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'event_id': this.id,
      'name': this.name,
      'open_time' : this.openDate.millisecondsSinceEpoch,
      'close_time' : this.closeDate.millisecondsSinceEpoch,
      'general_info' : this.generalInfo,
      'location_desc' : this.location
    };
//    if(tableId != null){
//      map['_id'] = tableId;
//    }
    return map;
  }

  /// TODO: Admin dashboard deer event uusgej db-d hadgalahdaa UTC + TimeZone baigaag, UTC bolgoh
  /// End UTC tsagaar awahgui bol +TimeZone orj ireed bgaa
  factory Event.fromMap(Map<String, dynamic> map){
    return Event(
        id: map['event_id'],
        name: map['name'],
        openDate: DateTime.fromMillisecondsSinceEpoch(map['open_time'], isUtc: true),
        // openDate: DateTime.fromMillisecondsSinceEpoch(map['open_time']),
        closeDate: DateTime.fromMillisecondsSinceEpoch(map['close_time'], isUtc: true),
        generalInfo: map['general_info'],
        location: map['location_desc'],
        bannerUrls: [map['banner_url'] ?? ''],
        locationUrl: map['location_url'] ?? ''
    );
  }

  Future<Event> insert(Event event) async {
    Database db = await SQLiteHelper.instance.getDb();
    event.tableId = await db.insert('events', event.toMap());
    return event;
  }

  Future<Event> getEvent(int eventId) async {
    Database db = await SQLiteHelper.instance.getDb();
    List<Map> maps = await db.query('events',
      columns: ['event_id','name','open_time','close_time','general_info','location_desc'],
      where: 'event_id = ?',
      whereArgs: [eventId]
    );
    if(maps.length > 0){
      return Event.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Event>> getEventList(int page, int max) async {

    Database db = await SQLiteHelper.instance.getDb();
    // List<Map<String, dynamic>> records = await db.query('events', orderBy: 'open_time DESC');
   List<Map<String, dynamic>> records = await db.rawQuery('SELECT ev.*, banner.img_path banner_url, location.img_path location_url '
       'FROM events as ev '
       'LEFT JOIN images as banner ON banner.related_type = \'event\' and banner.related_id = ev.event_id and banner.field = \'bannerUrl\' '
       'LEFT JOIN images as location ON location.related_type = \'event\' and location.related_id = ev.event_id and banner.field = \'locationUrl\' '
       'ORDER BY ev.open_time DESC '
       'LIMIT ? OFFSET ? ', [max, (page - 1) * max]);

    List<Event> events = List();
    records.forEach((item) {
      Event event = Event.fromMap(item);
      events.add(event);
    });
    return events;
  }

  ///deprecated : using join query [bannerUrl]
  Future<List<ImageMorph>> getEventBanners() async {
    Database db = await SQLiteHelper.instance.getDb();
    List<Map<String, dynamic>> imgs = await db.query(
        'images',
        columns: ['related_type', 'related_id', 'field', 'img_path'],
        where: '"related_type" = ? and "field" = ?',
        whereArgs: ['event', 'bannerUrl']);
    List<ImageMorph> banners = List();
    imgs.forEach((img) {
      banners.add(ImageMorph.fromMap(img));
    });
    return banners;
  }
  ///deprecated : using join query
  Future<List<ImageMorph>> getEventLocationImgs() async {
    Database db = await SQLiteHelper.instance.getDb();
    List<Map<String, dynamic>> imgs = await db.query(
        'images', columns: ['related_type', 'related_id', 'field', 'img_path'],
        where: '"related_type" = ? and "field" = ? ', whereArgs: ['event', 'locationUrl']);
    List<ImageMorph> locationUrls = List();
    imgs.forEach((img){
      locationUrls.add(ImageMorph.fromMap(img));
    });

    return locationUrls;
  }

}