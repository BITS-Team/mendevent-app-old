class EventFaq {
  final int id;
  final int priority;
  final String question;
  final String answer;
  final String imgUrl;

  EventFaq(
      {this.id,
        this.priority,
        this.question,
        this.answer,
        this.imgUrl
      });
  factory EventFaq.fromJson(Map<String, dynamic> json) {
    String _imgUrl = json.containsKey('answer_image') && json['answer_image'] != null ? json['answer_image']['url'] : '';
    return EventFaq(
      id: json['id'],
      priority: json.containsKey('priority') && json['priority'] != null ? json['priority'] : -1,//json['priority'],
      question: json.containsKey('question') && json['question'] != null ? json['question'] : '',//json['question'],
      answer: json.containsKey('answer_text') && json['answer_text'] != null ? json['answer_text'] : '',
      imgUrl: _imgUrl,
    );
  }
}
