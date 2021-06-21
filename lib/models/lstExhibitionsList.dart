import 'package:mend_doctor/models/modEventExhibition.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';

class ExhibitionList {
  final List<Exhibition> list;

  List<int> programIds;

  ExhibitionList({this.list});

  factory ExhibitionList.fromJson(List<dynamic> json) {
    List<Exhibition> _events = new List<Exhibition>();
//    print('json: $json');
    try {
      _events = json.map((i) => Exhibition.fromJson(i)).toList();
//      _speakers = json.map((i) => print(i)).toList();
    } catch (e) {
      print(e);
    }
    return new ExhibitionList(list: _events);
  }

  int getProgramCount() {
    Map<int, int> _programs = Map<int, int>();
    list.forEach((item) {
       if(item.programId != 0) print('${item.programId}');
      _programs[item.programId] = item.programId ;
    });
    programIds = _programs.values.toList()..sort((id1, id2) => id1 - id2);
    return this.programIds != null ? programIds.length : 0;
  }

//  List<String> getPrograms() {
//    if (this.programs != null)
//      return this.programs;
//    else
//      return [];
//  }
//  List<String> getProgramTopics(){
//    if(this.programTopics != null)
//      return this.programTopics;
//    else
//      return [];
//  }

}
