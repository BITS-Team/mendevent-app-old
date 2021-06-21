import 'package:mend_doctor/models/modDoctor.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';

class Exhibition {
  final int id;
  final String title;
  final String description;
  final String imgUrl;
  final Doctor doctor;
  final int programId;

  int countUpVote;
  int countDownVote;

  String vote = "";
  int voteId = 0;

  Exhibition({
    this.id,
    this.title,
    this.description,
    this.imgUrl,
    this.doctor,
    this.programId
  });

  factory Exhibition.fromJson(Map<String, dynamic> json) {
    Doctor _doctor = (json.containsKey('doctor') && json['doctor'] != null) ? Doctor.fromJson(json['doctor']) : null;
    int _item = (json.containsKey('event_program') && json['event_program'] != null )
        ? json['event_program']['id'] : 0;
    return Exhibition(
      id: json.containsKey('id') && json['id'] != null ? json['id'] : 0,
      title: json.containsKey('title') && json['title'] != null ? json['title'] : '',
      description: json.containsKey('description') && json['description'] != null ? json['description'] : '',
      imgUrl: json.containsKey('image') && json['image'] != null ? json['image']['url'] : '',
      doctor: _doctor,
      programId: _item,
    );
  }
  void setVote(String vote){
    this.vote = vote;
  }
  void setVoteId(int id){
    this.voteId = id;
  }

}