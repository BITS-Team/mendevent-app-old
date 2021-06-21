class EventParticipant {
  final int id;
  final String name;
  final String role;
  final String description;
  final String meta;
  final String bannerUrl;
  final String type;
  final String participantType;
  int eventId;
  EventParticipant({
    this.id,
    this.name,
    this.role,
    this.description,
    this.meta,
    this.bannerUrl,
    this.type,
    this.participantType
});
  factory EventParticipant.fromJson(Map<String, dynamic> json){
    EventParticipant ep = EventParticipant(
        id: json['id'],
        name: json['name'],
        role: json['role'],
        description: json['description'],
        meta: json['meta'],
        bannerUrl: json.containsKey('banner') ? json['banner'] : '',
        type: json.containsKey('type') ? json['type'] : '',
        participantType: json.containsKey('participant_type') ? json['participant_type'] : ''
    );
    ep.setEvent(json.containsKey('event') ? json['event'] : 0);
    return ep;
  }
  bool hasPic(){
    return bannerUrl != '';
  }
  setEvent(int id){
    this.eventId = id;
  }
  int getEvent(){
    return this.eventId;
  }

  /// SQLite
  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'event_id': this.eventId,
      'participant_id': this.id,
      'name' : this.name,
      'description' : this.description,
      'meta' : this.meta,
      'participant_type' : this.participantType
    };
    return map;
  }
  factory EventParticipant.fromMap(Map<String, dynamic> map){
    EventParticipant ep = EventParticipant(
        id: map['participant_id'],
        name: map['name'],
        description: map['description'],
        meta: map['meta'],
        participantType: map['participant_type'],
    );
    ep.setEvent(map['event_id']);
    return ep;
  }
}