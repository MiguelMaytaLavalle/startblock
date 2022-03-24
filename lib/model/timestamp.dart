class Timestamp {

  int time = 0;
  //double force = 0;

  Timestamp({
    required this.time,
    //required this.force
  }); //Constructor

  Map<String, Object?> toJson() => {
    'time': time,
    //'force': force
  };

  factory Timestamp.fromJson(Map<String, dynamic> json) => Timestamp(
    time: json['time'],
    //force: json['force'],
  );



}
