const String tableHistory = 'history';

class HistoryFields{
  static final List<String> values = [
    id, dateTime, name/*, leftFoot, rightFoot,
    reactionTime, startTime, totalTime*/
  ];

  static const String id = '_id';
  static const String dateTime = 'dateTime';
  static const String name = 'name';
/*  static const String leftFoot = 'leftFoot';
  static const String rightFoot = 'rightFoot';
  static const String reactionTime = 'reactionTime';
  static const String startTime = 'startTime';
  static const String totalTime = 'totalTime';*/

}

class History{
  final int? id;
  final DateTime dateTime;
  final String name;
/*  final int leftFoot;
  final int rightFoot;
  final int reactionTime;
  final int startTime;
  final int totalTime;*/

  const History({
    this.id,
    required this.dateTime,
    required this.name,
/*    required this.leftFoot,
    required this.rightFoot,
    required this.reactionTime,
    required this.startTime,
    required this.totalTime,*/
  });

  Map<String, Object?> toJSON() =>{
    HistoryFields.id: id,
    HistoryFields.dateTime: dateTime.toIso8601String(),
    HistoryFields.name: name,
/*    HistoryFields.leftFoot: leftFoot,
    HistoryFields.rightFoot: rightFoot,
    HistoryFields.reactionTime: reactionTime,
    HistoryFields.startTime: startTime,
    HistoryFields.totalTime: totalTime*/
  };

  static History fromJSON(Map<String,Object?> json) => History(
    id:json[HistoryFields.id] as int?,
    dateTime: DateTime.parse(json[HistoryFields.dateTime] as String),
    name: json[HistoryFields.name] as String,
/*    leftFoot: json[HistoryFields.leftFoot] as int,
    rightFoot: json[HistoryFields.rightFoot] as int,
    reactionTime: json[HistoryFields.reactionTime] as int,
    startTime: json[HistoryFields.startTime] as int,
    totalTime: json[HistoryFields.totalTime] as int,*/

  );

  History copy({
    int? id,
    DateTime? dateTime,
    String? name,
/*    int? leftFoot,
    int? rightFoot,
    int? reactionTime,
    int? startTime,
    int? totalTime,*/

  }) =>
      History(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        name: name ?? this.name,
/*        leftFoot: leftFoot ?? this.leftFoot,
        rightFoot: rightFoot ?? this.rightFoot,
        reactionTime: reactionTime ?? this.reactionTime,
        startTime: startTime ?? this.startTime,
        totalTime: totalTime ?? this.totalTime,*/
      );



}
