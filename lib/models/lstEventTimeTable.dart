import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modEventRoom.dart';

class EventTimeTable {
  final List<EventProgramItem> items;

  List<EventRoom> rooms;
  List<DateTime> times;

  EventTimeTable({this.items});

  factory EventTimeTable.fromJson(List<dynamic> json) {
    List<EventProgramItem> _items = new List<EventProgramItem>();
    _items = json.map((i) => EventProgramItem.fromJson(i)).toList();
    return new EventTimeTable(items: _items);
  }

  List<EventRoom> getRoomList() {
    if (this.rooms == null) {
      List<EventRoom> _rooms = new List<EventRoom>();
      List<int> roomIds = new List<int>();
//      for (int i = 0; i < items.length; i++) {
//        rooms.add(items[i].room);
//      }
      items.forEach((item) {
//        _rooms.add(item.room);
        if(item.room != null)
          roomIds.add(item.room);
      });
//      roomIds.forEach((item)=>print('room: $item'));
      roomIds = Set.of(roomIds).toList();
//      roomIds.forEach((item)=>print('room: $item'));
      
      roomIds.forEach((id){
        //TODO: fix it
        //_rooms.add(items.firstWhere((item)=>item.room == id).room);
      });
      this.rooms = _rooms;

    }
    return this.rooms;
  }
  List<DateTime> getTimes(){
    if(this.times == null){
      List<DateTime> _times = List<DateTime>();
      items.forEach((item)=>_times.add(item.startTime));
      this.times = _times.toSet().toList();
    }
    this.times.sort((date1, date2)=> date1.compareTo(date2));
    return this.times;
  }
}
