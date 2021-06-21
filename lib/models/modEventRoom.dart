import 'package:sqflite/sqflite.dart';

import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';


class EventRoom {
  final int id;
  final String roomNumber;
  final String roomName;
  final String roomLocation;
  final int eventId;
  final String locationImg;
//  final List<EventSpeaker> speakers;

  EventRoom({
    this.id,
    this.roomNumber,
    this.roomName,
    this.roomLocation,
    this.eventId,
    this.locationImg,
//    this.speakers,
  });
  factory EventRoom.fromJson(Map<String, dynamic> json){
    String imgUrl = (json.containsKey('room_location_img') && json['room_location_img'] != null) ? json['room_location_img'] : '';
//    int _eventId = 0;
//    if(json.containsKey('event')){
//      try{
//        Event evt = Event.fromJson(json['event']);
//        _eventId = evt.id;
//      } catch(e){
//        _eventId = json['event'];
//      }
//    }
    return EventRoom(
      id: json['id'],
      roomNumber: json['room_number'] != null ? json['room_number'] : '',
      roomName: json['roomname'] != null ? json['roomname'] : '',
      roomLocation: json['room_location'] != null ? json['room_location'] : '',
      eventId: json.containsKey('event') ? json['event'] : 0,
      locationImg: imgUrl
    );
  }

  ///SQLite

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'room_id': this.id,
      'event_id': this.eventId,
      'name': this.roomName,
      'location' : this.roomLocation,
      'number' : this.roomNumber
    };
    return map;
  }

  factory EventRoom.fromMap(Map<String, dynamic> map){
    return EventRoom(
        id: map['room_id'],
        eventId: map['event_id'],
        roomName: map['name'],
        roomNumber: map['number'],
        roomLocation: map['location']
    );
  }

}
