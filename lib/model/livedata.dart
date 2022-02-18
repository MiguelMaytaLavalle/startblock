class LiveData {

  LiveData({
    required this.time,
    required this.force
}); //Constructor

  int time = 0;
  double force = 0;

  Map<String, Object?> toJson() => {
    'time': time,
    'speed': force,
  };

  factory LiveData.fromJson(Map<String, dynamic> json) => LiveData(
    time: json['time'],
    force: json['speed'],
  );

}
