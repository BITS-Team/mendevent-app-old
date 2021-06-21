import 'package:mend_doctor/models/modEvent.dart';

class EventList {
  final List<Event> events;

  EventList({this.events});

  factory EventList.fromJson(List<dynamic> json){
    List<Event> _events = new List<Event>();
//    print('json: $json');
    try{
      _events = json.map((i) => Event.fromJson(i)).toList();
//      _speakers = json.map((i) => print(i)).toList();
    } catch(e){
      print(e);
    }

    return new EventList(events: _events);
  }
}