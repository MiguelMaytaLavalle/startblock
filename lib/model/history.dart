import 'package:startblock/constant/constants.dart';
String tableHistory = Constants.HISTORY_TABLE_NAME;

/**
 * The class History contains the parameters for when creating
 * the table in the database.
 */

class HistoryFields{
  static final List<String> values = [
    id, dateTime, name, rightData, leftData,timestamps,
    marzullo, imuData, imuTimestamps, movesenseArriveTime,
    marzulloCreationTime, lastServerTime,
  ];
  static const String id = '_id';
  static const String dateTime = 'dateTime';
  static const String name = 'name';
  static const String rightData = 'rightData';
  static const String leftData = 'leftData';
  static const String timestamps = 'timestamps';
  static const String marzullo = 'marzullo';
  static const String imuData = 'imuData';
  static const String imuTimestamps = 'imuTimestamps';
  static const String movesenseArriveTime = 'movesenseArriveTime';
  static const String marzulloCreationTime = 'marzulloCreationTime';
  static const String lastServerTime = 'lastServerTime';
  static const String startSampleTime = 'startSampleTime';
  static const String stopSampleTime = 'stopSampleTime';

}
class History{
  final int? id;
  final DateTime dateTime;
  final String name;
  final String rightData;
  final String leftData;
  final String timestamps;
  final num? marzullo;
  final String imuData;
  final String imuTimestamps;
  final String movesenseArriveTime;
  final num? marzulloCreationTime;
  final num? lastServerTime;
  final num? startSampleTime;
  final num? stopSampleTime;

  History({
    this.id,
    required this.dateTime,
    required this.name,
    required this.rightData,
    required this.leftData,
    required this.timestamps,
    required this.marzullo,
    required this.imuData,
    required this.imuTimestamps,
    required this.movesenseArriveTime,
    required this.marzulloCreationTime,
    required this.lastServerTime,
    required this.startSampleTime,
    required this.stopSampleTime,
  });

  Map<String, dynamic> toJson() =>{
    HistoryFields.id: id,
    HistoryFields.dateTime: dateTime.toIso8601String(),
    HistoryFields.name: name,
    HistoryFields.rightData: rightData,
    HistoryFields.leftData: leftData,
    HistoryFields.timestamps: timestamps,
    HistoryFields.marzullo: marzullo,
    HistoryFields.imuData: imuData,
    HistoryFields.imuTimestamps: imuTimestamps,
    HistoryFields.movesenseArriveTime: movesenseArriveTime,
    HistoryFields.marzulloCreationTime: marzulloCreationTime,
    HistoryFields.lastServerTime: lastServerTime,
    HistoryFields.startSampleTime: startSampleTime,
    HistoryFields.stopSampleTime: stopSampleTime,


  };

  factory History.fromJson(Map<String, dynamic> json) => History(
    id:json[HistoryFields.id] as int?,
    dateTime: DateTime.parse(json[HistoryFields.dateTime] as String),
    name: json[HistoryFields.name] as String,
    rightData: json[HistoryFields.rightData] as String,
    leftData: json[HistoryFields.leftData] as String,
    timestamps: json[HistoryFields.timestamps] as String,
    marzullo: json[HistoryFields.marzullo] as num?,
    imuData: json[HistoryFields.imuData] as String,
    imuTimestamps: json[HistoryFields.imuTimestamps] as String,
    movesenseArriveTime: json[HistoryFields.movesenseArriveTime] as String,
    marzulloCreationTime: json[HistoryFields.marzulloCreationTime] as num?,
    lastServerTime: json[HistoryFields.lastServerTime] as num?,
    startSampleTime: json[HistoryFields.startSampleTime] as num?,
    stopSampleTime: json[HistoryFields.stopSampleTime] as num?,
  );

  History copy({
    int? id,
    DateTime? dateTime,
    String? name,
    String? rightData,
    String? leftData,
    String? timestamps,
    num? marzullo,
    String? imuData,
    String? imuTimestamps,
    String? movesenseArriveTime,
    num? marzulloCreationTime,
    num? lastServerTime,
    num? startSampleTime,
    num? stopSampleTime,
  }) =>
      History(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        name: name ?? this.name,
        rightData: rightData ?? this.rightData,
        leftData: leftData ?? this.leftData,
        timestamps: timestamps ?? this.timestamps,
        marzullo: marzullo ?? this.marzullo,
        imuData: imuData ?? this.imuData,
        imuTimestamps: imuTimestamps ?? this.imuTimestamps,
        movesenseArriveTime: movesenseArriveTime ?? this.movesenseArriveTime,
        marzulloCreationTime: marzulloCreationTime ?? this.marzulloCreationTime,
        lastServerTime: lastServerTime ?? this.lastServerTime,
        startSampleTime: startSampleTime ?? this.startSampleTime,
        stopSampleTime: stopSampleTime ?? this.stopSampleTime,
      );
}
