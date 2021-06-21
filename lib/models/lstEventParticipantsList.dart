import 'package:mend_doctor/models/modEventParticipant.dart';

class EventParticipantsList{
  final List<EventParticipant> participants;

  EventParticipantsList({this.participants});

  factory EventParticipantsList.fromJson(List<dynamic> json){
    List<EventParticipant> _participants = new List<EventParticipant>();

    try{
      _participants = json.map((i) => EventParticipant.fromJson(i)).toList();
    } catch(e){
      print(e);
    }
    return new EventParticipantsList(participants: _participants);
  }
  List<EventParticipant> getParticipants(){
    return participants;
  }

  List<EventParticipant> getGoldens(){
    return participants.where((part)=>part.participantType.toLowerCase().contains('алтан')).toList();
  }

  List<EventParticipant> getSilvers(){
    return participants.where((part)=>part.participantType.toLowerCase().contains('мөнгөн')).toList();
  }

  List<EventParticipant> getBronzes(){
    return participants.where((part)=>part.participantType.toLowerCase().contains('хүрэл')).toList();
  }

  List<EventParticipant> getNormals(){
    return participants.where((part)=>part.participantType == 'Ивээн тэтгэгч').toList();
  }

  List<EventParticipant> getMainOrganizers(){
    return participants.where((part)=>part.participantType.toLowerCase().contains('Ерөнхий'.toLowerCase())).toList();
  }

  List<EventParticipant> getNormalOrganizers(){
    return participants.where((part)=>part.participantType.toUpperCase() == 'Зохион байгуулагч'.toUpperCase()).toList();
  }

  List<EventParticipant> getOrderedList(){
    List<EventParticipant> ordered = List<EventParticipant>(getGoldens().length + getSilvers().length + getBronzes().length + getNormals().length);
    int index = 0;
    ordered.setRange(index, index + getGoldens().length, getGoldens());
    index += getGoldens().length ;
    ordered.setRange(index, index + getSilvers().length, getSilvers());
    index += getSilvers().length ;
    ordered.setRange(index, index + getBronzes().length, getBronzes());
    index += getBronzes().length ;
    ordered.setRange(index, index + getNormals().length, getNormals());

    return ordered;
  }
}