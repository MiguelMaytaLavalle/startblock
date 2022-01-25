String tableHistory = 'test4';

class HistoryFields{
  static final List<String> values = [
    id, dateTime, name, liveData, rightData, leftData,
  ];
  static const String id = '_id';
  static const String dateTime = 'dateTime';
  static const String name = 'name';
  static String liveData = 'liveData';
  static const String rightData = 'rightData';
  static const String leftData = 'leftData';
}
class History{
  final int? id;
  final DateTime dateTime;
  final String name;
  final String liveData;
  final String rightData;
  final String leftData;
  History({
    this.id,
    required this.dateTime,
    required this.name,
    required this.liveData,
    required this.rightData,
    required this.leftData,
  });

  Map<String, dynamic> toJson() =>{
    HistoryFields.id: id,
    HistoryFields.dateTime: dateTime.toIso8601String(),
    HistoryFields.name: name,
    HistoryFields.liveData: liveData,
    HistoryFields.rightData: rightData,
    HistoryFields.leftData: leftData,
  };

  factory History.fromJson(Map<String, dynamic> json) => History(
    id:json[HistoryFields.id] as int?,
    dateTime: DateTime.parse(json[HistoryFields.dateTime] as String),
    name: json[HistoryFields.name] as String,
    liveData: json[HistoryFields.liveData] as String,
    rightData: json[HistoryFields.rightData] as String,
    leftData: json[HistoryFields.leftData] as String,
  );

  History copy({
    int? id,
    DateTime? dateTime,
    String? name,
    String? liveData,
    String? rightData,
    String? leftData,
  }) =>
      History(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        name: name ?? this.name,
        liveData: liveData ?? this.liveData,
        rightData: rightData ?? this.rightData,
        leftData: leftData ?? this.leftData,
      );
}
