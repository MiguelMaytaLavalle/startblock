import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/livedata.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExportToExcel{

  /// Rename function
  Future<List<ExcelDataRow>> _buildCustomersDataRowsIH(List<LiveData> list) async {
    List<ExcelDataRow> excelDataRows = <ExcelDataRow>[];
    final Future<List<LiveData>> reports = _getCustomersImageHyperlink(list);
    List<LiveData> reports_1 = await Future.value(reports);
    excelDataRows = reports_1.map<ExcelDataRow>((LiveData dataRow) {
      return ExcelDataRow(cells: <ExcelDataCell>[
        ExcelDataCell(columnHeader: 'Time', value: dataRow.time),
        ExcelDataCell(columnHeader: 'Force', value: dataRow.force)
      ]);
    }).toList();
    return excelDataRows;
  }

  /// rename function
  Future<List<LiveData>> _getCustomersImageHyperlink(List<LiveData> list) async {
    final List<LiveData> reports = list;
    return reports;
  }


  Future<void> exportToExcel(List<LiveData> leftList, List<LiveData> rightList) async {
    //Create a Excel document.
    //Creating a workbook.
    print('Excel');
    final Workbook workbook = Workbook();

    //Accessing via index
    final Worksheet sheet = workbook.worksheets[0];

    //List of data to import data.
    final Future<List<ExcelDataRow>> dataRowsLeft = _buildCustomersDataRowsIH(leftList);
    final Future<List<ExcelDataRow>> dataRowsRight = _buildCustomersDataRowsIH(rightList);
    List<ExcelDataRow> dataRows_Left = await Future.value(dataRowsLeft);
    List<ExcelDataRow> dataRows_Right = await Future.value(dataRowsRight);

    //Import the list to Sheet.
    sheet.importData(dataRows_Left, 1, 1);
    sheet.importData(dataRows_Right, 1, 4);

    //Auto-Fit columns.
    sheet.getRangeByName('A1:B1').autoFitColumns();
    sheet.getRangeByName('D1:E1').autoFitColumns();

    //Save and launch the excel.
    final List<int> bytes = workbook.saveAsStream();

    //Dispose the document.
    workbook.dispose();

    //Get the storage folder location using path_provider package.
    final Directory? directory = await getExternalStorageDirectory();
//Get the directory path
    final String? path = directory?.path;
//Create an empty file to write the Excel data
    final File file = File('$path/ImportData.xlsx');
    //Write Excel data
    await file.writeAsBytes(bytes, flush: true);
    //Launch the file (used open_file package)
    //await OpenFile.open('$path/ImportData.xlsx');
    String excelPath = '$path/output.xlsx';
    // Attach excel file to the email
    //attachments.add(excelPath);
    //sendEmailVM.addAttachment(excelPath);
  }

  String attachExcel(History history){
    exportToExcel(history.leftData, history.rightData);
    return '';
  }


}
