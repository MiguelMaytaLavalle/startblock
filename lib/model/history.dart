String tableHistory = 'test11';

/**
 * test5
 *
 */

class HistoryFields{
  static final List<String> values = [
    id, dateTime, name, rightData, leftData,timestamps, marzullo,
  ];
  static const String id = '_id';
  static const String dateTime = 'dateTime';
  static const String name = 'name';
  static const String rightData = 'rightData';
  static const String leftData = 'leftData';
  static const String timestamps = 'timestamps';
  static const String marzullo = 'marzullo';
}
class History{
  final int? id;
  final DateTime dateTime;
  final String name;
  final String rightData;
  final String leftData;
  final String timestamps;
  final num? marzullo;

  History({
    this.id,
    required this.dateTime,
    required this.name,
    required this.rightData,
    required this.leftData,
    required this.timestamps,
    required this.marzullo,
  });

  Map<String, dynamic> toJson() =>{
    HistoryFields.id: id,
    HistoryFields.dateTime: dateTime.toIso8601String(),
    HistoryFields.name: name,
    HistoryFields.rightData: rightData,
    HistoryFields.leftData: leftData,
    HistoryFields.timestamps: timestamps,
    HistoryFields.marzullo: marzullo,

  };

  factory History.fromJson(Map<String, dynamic> json) => History(
    id:json[HistoryFields.id] as int?,
    dateTime: DateTime.parse(json[HistoryFields.dateTime] as String),
    name: json[HistoryFields.name] as String,
    rightData: json[HistoryFields.rightData] as String,
    leftData: json[HistoryFields.leftData] as String,
    timestamps: json[HistoryFields.timestamps] as String,
    marzullo: json[HistoryFields.marzullo] as num?,
  );

  History copy({
    int? id,
    DateTime? dateTime,
    String? name,
    String? rightData,
    String? leftData,
    String? timestamps,
    num? marzullo,
  }) =>
      History(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        name: name ?? this.name,
        rightData: rightData ?? this.rightData,
        leftData: leftData ?? this.leftData,
        timestamps: timestamps ?? this.timestamps,
        marzullo: marzullo ?? this.marzullo,
      );
}
