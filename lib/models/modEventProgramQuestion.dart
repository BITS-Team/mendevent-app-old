class EventProgramQuestion {
  final int id;
  final int eventId;
  final int programId;
  final int speakerId;
  final String question;
  int voteUp;
  int voteDown;
  bool answered;
  bool is_delete;
  String confirmed;

  EventProgramQuestion(
      {this.id,
        this.eventId,
        this.programId,
        this.speakerId,
        this.question,
        this.voteUp,
        this.voteDown,
        this.answered : false,
        this.is_delete: false,
        this.confirmed
      });
  factory EventProgramQuestion.fromJson(Map<String, dynamic> json) {
    return EventProgramQuestion(
      id: json['id'],
      eventId: json.containsKey('event') && json['event'] != null ? json['event'] : -1,//json['priority'],
      programId: json.containsKey('event_program') && json['event_program'] != null ? json['event_program'] : 0,//json['question'],
      speakerId: json.containsKey('eventspeaker') && json['eventspeaker'] != null ? json['eventspeaker'] : 0,
      question: json.containsKey('question') && json['question'] != null ? json['question'] : '',
      voteUp: json.containsKey('up') && json['up'] != null ? json['up'] : 0,
      voteDown: json.containsKey('down') && json['down'] != null ? json['down'] : 0,
      answered: json['answered'] ?? false,
      is_delete: json['is_delete'] ?? false,
      confirmed: json.containsKey('confirmed') ? json['confirmed'] : ''

    );
  }

  int getRate(){
    return voteDown - voteUp;
  }

  incVoteUp(){
    ++this.voteUp;
  }
  decVoteUp(){
    --this.voteUp;
  }
  incVoteDown(){
    ++this.voteDown;
  }
  decVoteDown(){
    --this.voteDown;
  }
  // setConfirmed(String b){
  //   this.confirmed = b;
  // }
  bool isConfirmed(){
    return this.confirmed == 'confirmed';
  }

  toString() {
    return '{"id": ${this.id}, "eventId":${this.eventId}, "programId":${this.programId}, "speakerId":${this.speakerId}, "question":${this.question}'
        ', "voteUp":${this.voteUp}, "voteDown":${this.voteDown}, "answered":${this.answered}, "is_delete":${this.is_delete}}';
  }
}
