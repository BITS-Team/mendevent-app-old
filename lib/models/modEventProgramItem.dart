import 'dart:convert';
import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'package:mend_doctor/models/modEventRoom.dart';

/// Event-iin program-iin item
/// room -
/// title
/// topic
class EventProgramItem {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final String roomOld;
  final String title;
  final String topic;
  final int room;
  final String programType;
  final String description;
  int eventId;

  EventProgramItem(
      {this.id,
      this.startTime,
      this.endTime,
      this.roomOld,
      this.title,
      this.topic,
      this.room,
      this.programType,
      this.description});

  factory EventProgramItem.fromJson(Map<String, dynamic> json) {

    EventProgramItem epi = EventProgramItem(
      id: json['id'],
      startTime: DateTime.parse(json['open_time']),
      endTime: DateTime.parse(json['close_time']),
      roomOld: '',
      title: json['title'],
      topic: json['topic'],
      room: (json.containsKey('eventroom') && json['eventroom'] != null) ? json['eventroom'] : 0,
      programType: (json.containsKey('program_type') && json['program_type'] != null) ? json['program_type'] : "",
      description: (json.containsKey('description') && json['description'] != null) ? json['description'] : "",
    );
    epi.setEvent(json.containsKey('event') ? json['event'] : 0);
    return epi;
  }
  setEvent(int id) {
    this.eventId = id;
  }

  int getEvent() {
    return this.eventId;
  }

  String getOpenDateWithString() {
    int month = startTime.month; // < 10 ? '0${startTime.month}' : '${startTime.month}';
    String day = startTime.day < 10 ? '0${startTime.day}' : '${startTime.day}';

    return '$month-p сарын $day';
  }

  String getOpenDate() {
    String month = startTime.month < 10 ? '0${startTime.month}' : '${startTime.month}';
    String day = startTime.day < 10 ? '0${startTime.day}' : '${startTime.day}';
    return '$month.$day';
  }

  String getOpenTime() {
    String time = startTime.hour < 10 ? '0${startTime.hour}' : '${startTime.hour}';
    String minute = startTime.minute < 10 ? '0${startTime.minute}' : '${startTime.minute}';

    return '$time:$minute';
  }

  /// SQLite

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'event_id': this.eventId,
      'program_id': this.id,
      'title': this.title,
      'topic': this.topic,
      'open_time': this.startTime.millisecondsSinceEpoch,
      'close_time': this.endTime.millisecondsSinceEpoch,
      'description': this.description,
      'program_type': this.programType,
      'room_id': this.room
    };
    return map;
  }

  factory EventProgramItem.fromMap(Map<String, dynamic> map) {
    EventProgramItem epi = EventProgramItem(
        id: map['program_id'],
        title: map['title'],
        topic: map['topic'],
        startTime: DateTime.fromMillisecondsSinceEpoch(map['open_time'], isUtc: true),
        endTime: DateTime.fromMillisecondsSinceEpoch(map['close_time'], isUtc: true),
        description: map['description'],
        programType: map['program_type'],
        room: map['room_id']
    );
    epi.setEvent(map['event_id']);
    return epi;
  }
}
