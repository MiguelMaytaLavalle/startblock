import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:startblock/model/history_card.dart';
import 'package:startblock/model/livedata.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../model/timestamp.dart';

/// Using Syncfusion xlsio we can create an excel file
class ExportToExcel{

  Future<List<ExcelDataRow>> _mapExcelData(String colName,List<LiveData> list) async {
    List<ExcelDataRow> excelDataRows = <ExcelDataRow>[];
    final Future<List<LiveData>> reports = _getLivedata(list);
    List<LiveData> reports_1 = await Future.value(reports);
    excelDataRows = reports_1.map<ExcelDataRow>((LiveData dataRow) {
      return ExcelDataRow(cells: <ExcelDataCell>[
        ExcelDataCell(columnHeader: colName, value: dataRow.force)
      ]);
    }).toList();
    return excelDataRows;
  }

  Future<List<ExcelDataRow>> _mapExcelTimestamps(String colName,List<Timestamp> list) async {
    List<ExcelDataRow> excelDataRows = <ExcelDataRow>[];
    final Future<List<Timestamp>> reports = _getTimestamps(list);
    List<Timestamp> reports_1 = await Future.value(reports);
    excelDataRows = reports_1.map<ExcelDataRow>((Timestamp dataRow) {
      return ExcelDataRow(cells: <ExcelDataCell>[
        ExcelDataCell(columnHeader: colName, value: dataRow.time),
      ]);
    }).toList();
    return excelDataRows;
  }

  /// rename function
  Future<List<LiveData>> _getLivedata(List<LiveData> list) async {
    final List<LiveData> reports = list;
    return reports;
  }

  Future<List<Timestamp>> _getTimestamps(List<Timestamp> list) async {
    final List<Timestamp> reports = list;
    return reports;
  }

  Future<String> exportToExcel(HistoryCardModel history) async {
    //Create a Excel document.
    //Creating a workbook.
    print('Excel');
    final String excelName = history.history.name;
    final Workbook workbook = Workbook();

    //Accessing via index
    final Worksheet sheet = workbook.worksheets[0];

    //List of data to import data.
    final Future<List<ExcelDataRow>> dataRowsLeft = _mapExcelData('Left',history.leftData);
    final Future<List<ExcelDataRow>> dataRowsRight = _mapExcelData('Right',history.rightData);
    final Future<List<ExcelDataRow>> dataRowsTimestamp = _mapExcelTimestamps('Time',history.timestamps);
    //print("Arrival time: ${history.timestampArrival.length}");
    //final Future<List<ExcelDataRow>> dataRowsArrivalTimestamp = _mapExcelTimestamps('Arrival Time',history.timestampArrival);


    /// Transmit the converted data into appropriate ExcelDataRow which will be used for setting up the excel to each column.
    List<ExcelDataRow> _dataRowsLeft = await Future.value(dataRowsLeft);
    List<ExcelDataRow> _dataRowsRight = await Future.value(dataRowsRight);
    List<ExcelDataRow> _dataRowTimestamps = await Future.value(dataRowsTimestamp);
    //List<ExcelDataRow> _dataRowsArrivalTimestamp = await Future.value(dataRowsArrivalTimestamp);



    ///Import the lists to a Sheet.
    sheet.importData(_dataRowsLeft, 1, 1);
    sheet.importData(_dataRowsRight, 1, 2);
    sheet.importData(_dataRowTimestamps, 1, 3);
    //sheet.importData(_dataRowsArrivalTimestamp, 1, 12);

    sheet.getRangeByIndex(1, 4).setText('Marzullo Micro:Bit Offset');
    sheet.getRangeByIndex(2, 4).setText(history.marzullo.toString());

    sheet.getRangeByIndex(1, 5).setText('Start Sample Time');
    sheet.getRangeByIndex(2, 5).setText(history.startSampleTime.toString());

    sheet.getRangeByIndex(1, 6).setText('Stop Sample Time');
    sheet.getRangeByIndex(2, 6).setText(history.stopSampleTime.toString());

    sheet.getRangeByIndex(1, 7).setText('Marzullo Micro:Bit Creation Time');
    sheet.getRangeByIndex(2, 7).setText(history.marzulloCreationTime.toString());
    sheet.getRangeByIndex(1, 8).setText('Marzullo Micro:Bit Last Server Time');
    sheet.getRangeByIndex(2, 8).setText(history.lastServerTime.toString());


    try{
      final Future<List<ExcelDataRow>> dataRowsIMUAcc = _mapExcelData('IMU Acc',history.imuData);
      final Future<List<ExcelDataRow>> dataRowsIMUTimestamp = _mapExcelTimestamps('IMU Timestamp',history.imuTimestamps);
      final Future<List<ExcelDataRow>> dataRowsMovesenseArriveTime = _mapExcelTimestamps('Movesense Arrive Time',history.movesenseArriveTime);

      List<ExcelDataRow> _dataRowIMUAcc = await Future.value(dataRowsIMUAcc);
      List<ExcelDataRow> _dataRowIMUTimestamp = await Future.value(dataRowsIMUTimestamp);
      List<ExcelDataRow> _dataRowMovesenseArriveTime = await Future.value(dataRowsMovesenseArriveTime);

      sheet.importData(_dataRowIMUAcc,1,9);
      sheet.importData(_dataRowIMUTimestamp, 1, 10);
      sheet.importData(_dataRowMovesenseArriveTime, 1, 11);

    }catch(error){
      print(error);
    }



    ///Auto-Fit columns.
    sheet.getRangeByName('A1:M1').autoFitColumns();

    ///Save and launch the excel.
    final List<int> bytes = workbook.saveAsStream();

    ///Dispose the document after setting up the sheet.
    workbook.dispose();

    //Get the storage folder location using path_provider package.
    final Directory? directory = await getTemporaryDirectory() ;
    //Get the directory path
    final String? path = directory?.path;
    //Create an empty file to write the Excel data
    final File file = File('$path/$excelName.xlsx');
    //Write Excel data
    await file.writeAsBytes(bytes, flush: true);
    //Get the patch for the excel file
    String excelPath = '$path/$excelName.xlsx';
    return excelPath;
  }

  /// Returns the filepath for the created excel file.
 Future<String> attachExcel(HistoryCardModel hCardModel) async {
    String tmp = await exportToExcel(hCardModel);
   return tmp;
  }

}
