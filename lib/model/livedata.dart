class LiveData {

  LiveData({
    required this.time,
    required this.speed
}); //Constructor

  int time = 0;
  num speed = 0;

  Map<String, Object?> toJson() => {
    'time': time,
    'speed': speed,
  };

  factory LiveData.fromJson(Map<String, dynamic> json) => LiveData(
    time: json['time'],
    speed: json['speed'],
  );

}
