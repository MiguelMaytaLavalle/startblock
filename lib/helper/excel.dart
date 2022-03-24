import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:startblock/model/history_card.dart';
import 'package:startblock/model/livedata.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../model/timestamp.dart';

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

  Future<num> _getMarzullo(num list) async {
    final num reports = list;
    return reports;
  }


  Future<String> exportToExcel(HistoryCardModel history) async {
    //Create a Excel document.
    //Creating a workbook.
    print('Excel');
    final Workbook workbook = Workbook();

    //Accessing via index
    final Worksheet sheet = workbook.worksheets[0];

    //List of data to import data.
    final Future<List<ExcelDataRow>> dataRowsLeft = _mapExcelData('Left',history.leftData);
    final Future<List<ExcelDataRow>> dataRowsRight = _mapExcelData('Right',history.rightData);
    final Future<List<ExcelDataRow>> dataRowsTimestamp = _mapExcelTimestamps('Time',history.timestamps);
    //final Future<List<ExcelDataRow>> dataRowsMarzullo = _mapExcelMarzullo('Marzullo',history.marzullo);
    List<ExcelDataRow> _dataRowsLeft = await Future.value(dataRowsLeft);
    List<ExcelDataRow> _dataRowsRight = await Future.value(dataRowsRight);
    List<ExcelDataRow> _dataRowTimetamps = await Future.value(dataRowsTimestamp);

    print('Marzullo ${history.marzullo}');


    //Import the list to Sheet.
    sheet.importData(_dataRowsLeft, 1, 1);
    sheet.importData(_dataRowsRight, 1, 2);
    sheet.importData(_dataRowTimetamps, 1, 3);
    sheet.getRangeByIndex(1, 4).setText('Marzullo Micro:Bit Offset');
    sheet.getRangeByIndex(2, 4).setText(history.marzullo.toString());


    //Auto-Fit columns.
    sheet.getRangeByName('A1:B1').autoFitColumns();
    sheet.getRangeByName('D1:E1').autoFitColumns();

    //Save and launch the excel.
    final List<int> bytes = workbook.saveAsStream();

    //Dispose the document.
    workbook.dispose();

    //Get the storage folder location using path_provider package.
    final Directory? directory = await getTemporaryDirectory() ;
//Get the directory path
    final String? path = directory?.path;
//Create an empty file to write the Excel data
    final File file = File('$path/ImportData.xlsx');
    //Write Excel data
    await file.writeAsBytes(bytes, flush: true);

    String excelPath = '$path/ImportData.xlsx';
    return excelPath;

  }

 Future<String> attachExcel(HistoryCardModel hCardModel) async {
    String tmp = await exportToExcel(hCardModel);
   return tmp;
  }


}
