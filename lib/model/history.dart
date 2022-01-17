import 'dart:convert';

import 'livedata.dart';

String tableHistory = 'test';

class HistoryFields{
  static final List<String> values = [
    id, dateTime, name, liveData,
  ];
  static const String id = '_id';
  static const String dateTime = 'dateTime';
  static const String name = 'name';
  static String liveData = 'liveData';
}
class History{
  final int? id;
  final DateTime dateTime;
  final String name;
  List<LiveData> liveData = [];
  History({
    this.id,
    required this.dateTime,
    required this.name,
    required this.liveData,
  });

  Map<String, dynamic> toJSON() =>{
    HistoryFields.id: id,
    HistoryFields.dateTime: dateTime.toIso8601String(),
    HistoryFields.name: name,
    HistoryFields.liveData: List<String>.from(liveData.map((x) => x.toJSON())),
    //HistoryFields.liveData: List<dynamic>.from(liveData.map((e) => e)),
    //HistoryFields.liveData: liveData,
  };

  //static History fromJSON(Map<String,dynamic> json) => History(
  factory History.fromJSON(Map<String, dynamic> json) => History(
    id:json[HistoryFields.id] as int?,
    dateTime: DateTime.parse(json[HistoryFields.dateTime] as String),
    name: json[HistoryFields.name] as String,
    liveData: List<LiveData>.from(json[HistoryFields.liveData].map((x) => LiveData.fromJSON(x))),
    //liveData: json[HistoryFields.liveData] as List<LiveData>,
  );

  History copy({
    int? id,
    DateTime? dateTime,
    String? name,
    List<LiveData>? liveData,
  }) =>
      History(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        name: name ?? this.name,
        liveData: liveData ?? this.liveData,
      );
}
