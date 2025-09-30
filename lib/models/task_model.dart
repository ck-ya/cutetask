class TaskModel {
  String id;
  String text;
  bool done;
  int timestamp;

  TaskModel({
    required this.id,
    required this.text,
    required this.done,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'done': done,
        'timestamp': timestamp,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        text: json['text'],
        done: json['done'],
        timestamp: json['timestamp'],
      );
}
