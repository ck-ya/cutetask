class TimerModel {
  String id;
  String name;
  int duration;

  TimerModel({
    required this.id,
    required this.name,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'duration': duration,
      };

  factory TimerModel.fromJson(Map<String, dynamic> json) => TimerModel(
        id: json['id'],
        name: json['name'],
        duration: json['duration'],
      );
}
