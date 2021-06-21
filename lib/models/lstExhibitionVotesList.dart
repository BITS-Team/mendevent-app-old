import 'package:mend_doctor/models/modExhibitionVote.dart';

class ExhibitionVotesList {
  final List<ExhibitionVote> votes;

  ExhibitionVotesList({this.votes});

  factory ExhibitionVotesList.fromJson(List<dynamic> json) {
//    print('@@@@@@@@@@@@@@@@@ $json');
    List<ExhibitionVote> _votes = new List<ExhibitionVote>();
    try {
      _votes = json.map((i) => ExhibitionVote.fromJson(i)).toList();
//      print('############### $_votes');
    } catch (e){
      print(e);
    }
//    for (int i = 0; i < _appointments.length; i++) {
//      print(_appointments[i].name);
//    }
    return new ExhibitionVotesList(votes: _votes);
  }
}
