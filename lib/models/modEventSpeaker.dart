class EventSpeaker {
  final int id;
  final String name;
  final String desc;
  final bool isFeatured;
  final String picUrl;
  final title;
  final String position;
  final String career;
  List<int> programs;
  Map<int, String> programRoles;

  int eventId;

  EventSpeaker({
  this.id,
  this.name,
  this.title,
  this.desc,
  this.isFeatured,
  this.picUrl,
    this.position,
    this.career,
  });
  factory EventSpeaker.fromJson(Map<String, dynamic> json){
    EventSpeaker speaker = EventSpeaker(
      id: json['id'],
      name: json['name'],
      title: 'Ph.D',//json['title'],
      desc: json['description'],
      isFeatured: json['isfeatured'],
      picUrl: json.containsKey('picture') ? json['picture'] ?? '' : '',
      position: json.containsKey('position') ? json['position'] : '',
      career: json.containsKey('career') && json['career'] != null ? json['career'] : '',

    );
    speaker.setEvent(json.containsKey('event') ? json['event'] : 0);
    return speaker;
  }

  setEvent(int id){
    this.eventId = id;
  }
  int getEvent(){
    return this.eventId;
  }

  bool hasPic(){
    return picUrl != '';
  }

  setPrograms(List<int> _programs){
    this.programs = _programs;
  }
  List<int> getPrograms(){
    return this.programs;
  }

  setProgramRoles(Map<int,String> roles){
    this.programRoles = roles;
  }
  Map<int,String> getProgramRoles(){
    return this.programRoles;
  }

  String getCareer(){
    var car = career.split('#');
    return car.length > 1 ? capitalizeString(car[1]) : 'Others';
  }

  String capitalizeString(String str){
    if(str.length>1){
      String first = str.substring(0,1);
      String tail = str.substring(1, str.length);
      return '$first'.toUpperCase() + '$tail';
    } else if( str.length == 1){
      return str.toUpperCase();
    }
    return '';
  }

  /// SQLite

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'event_id': this.eventId,
      'speaker_id': this.id,
      'name': this.name,
      'description' : this.desc,
      'career' : this.career,
      'position' : this.position,
      'is_featured' : this.isFeatured ? 1 : 0
    };
    return map;
  }

  factory EventSpeaker.fromMap(Map<String, dynamic> map){
    EventSpeaker es = EventSpeaker(
        id: map['speaker_id'],
        name: map['name'],
        desc: map['description'],
        career: map['career'],
        position: map['position'],
        isFeatured: map['is_featured'] == 1 ? true : false,
        picUrl: map['picture']
    );
    es.setEvent(map['event_id']);
    return es;
  }
}