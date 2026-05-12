import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/student_entity.dart';

class ExcelHelper {
  static Future<void> exportStudentsToExcel(
    List<StudentEntity> students, {
    String fileName = "students_list",
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    excel.delete('Sheet1'); // Remove default sheet

    // Header styling
    CellStyle headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#f0f0f0'),
      fontColorHex: ExcelColor.fromHexString('#000000'),
      fontSize: 14,
      textWrapping: TextWrapping.WrapText,
    );

    // Add Headers
    List<String> headers = [
      'ID',
      'الاسم',
      'المرحلة',
      'العنوان',
      'مرشوم شماس',
      'واتس اب',
      'رقم الهاتف',
      'ملحوظات',
    ];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Add Data
    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(
        student.id,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(
        student.name,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(
        student.grade,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = TextCellValue(
        student.address,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(
        student.diacon,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = TextCellValue(
        student.whatsapp,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
          .value = TextCellValue(
        student.phone,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1))
          .value = TextCellValue(
        student.notes,
      );
    }

    // Save File
    if (kIsWeb) {
      // On Web, excel.save(fileName) automatically triggers a download with the given name
      excel.save(fileName: '$fileName.xlsx');
    } else {
      // On other platforms, we get the bytes and use FileSaver for a native save dialog
      final fileBytes = excel.save();
      if (fileBytes != null) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: Uint8List.fromList(fileBytes),
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
      }
    }
  }
}
