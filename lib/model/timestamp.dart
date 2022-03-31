class Timestamp {

  int time = 0;

  Timestamp({
    required this.time,
  }); //Constructor

  Map<String, Object?> toJson() => {
    'time': time,
  };

  factory Timestamp.fromJson(Map<String, dynamic> json) => Timestamp(
    time: json['time'],
  );

}
