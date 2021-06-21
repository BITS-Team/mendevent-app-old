import 'package:mend_doctor/models/modEventExhibition.dart';
import 'package:mend_doctor/models/modDoctor.dart';


class ExhibitionVote{
  final int id;
  final Exhibition exhibition;
  final Doctor doctor;
  final String vote;

  ExhibitionVote({
    this.id,
    this.exhibition,
    this.doctor,
    this.vote
  });

  factory ExhibitionVote.fromJson(Map<String, dynamic> json){
    Doctor _doctor = (json.containsKey('doctor') && json['doctor'] != null) ? Doctor.fromJson(json['doctor']) : null;
//    print('!!!!!!!!!!!!!!! $_doctor');
    Exhibition _exhibition = (json.containsKey('event_exhibition') && json['event_exhibition'] != null) ? Exhibition.fromJson(json['event_exhibition']) : null;
    return ExhibitionVote(
      id: json.containsKey('id') && json['id'] != null ? json['id'] : 0,
      exhibition: _exhibition,
      doctor: _doctor,
      vote: json.containsKey('vote') && json['vote'] != null ? json['vote'] : 'none',
    );
  }

}