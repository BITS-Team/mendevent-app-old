import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'dart:convert';

class EventSpeakersList {
  final List<EventSpeaker> speakers;

  EventSpeakersList({this.speakers});

  factory EventSpeakersList.fromJson(List<dynamic> json){
    List<EventSpeaker> _speakers = new List<EventSpeaker>();
//    print('json: $json');
    try{
      _speakers = json.map((i) => EventSpeaker.fromJson(i)).toList();
//      _speakers = json.map((i) => print(i)).toList();
    } catch(e){
      print(e);
    }

    return new EventSpeakersList(speakers: _speakers);
  }
  int getLength(){
    int l = 0;
    if(speakers == null){
      return 0;
    }
    return speakers.length;
  }
}