class LiveData {

  int time = 0;
  double force = 0;

  LiveData({
    required this.time,
    required this.force
}); //Constructor

  Map<String, Object?> toJson() => {
    'time': time,
    'force': force,
  };

  factory LiveData.fromJson(Map<String, dynamic> json) => LiveData(
    time: json['time'],
    force: json['force'],
  );

}
