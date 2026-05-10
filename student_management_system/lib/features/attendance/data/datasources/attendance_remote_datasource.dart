import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/entities/student_entity.dart';
import '../../../../core/models/student.dart';

abstract class IAttendanceRemoteDataSource {
  Future<List<StudentModel>> getStudents();
  Future<bool> submitAttendance({
    required String id,
    required String name,
    required String type,
    String? exception,
    String? note,
  });
  Future<bool> registerStudent(StudentEntity student);
}

class AttendanceRemoteDataSourceImpl implements IAttendanceRemoteDataSource {
  final String _url =
      "https://script.google.com/macros/s/AKfycbyfLQ5RAz9sy2ztz3qOeS21vIrBqpMDfdUt5lhfDygWW8MTjFf7xrwXXf4sdAmNPoK_pg/exec";

  @override
  Future<List<StudentModel>> getStudents() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => StudentModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load students");
      }
    } catch (e) {
      throw Exception("Error connecting to the server: $e");
    }
  }

  @override
  Future<bool> submitAttendance({
    required String id,
    required String name,
    required String type,
    String? exception,
    String? note,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: jsonEncode({
          "action": "SUBMIT_ATTENDANCE",
          "data": {
            "id": id,
            "name": name,
            "type": type,
            "exception": exception,
            "note": note,
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Submit Error: $e");
      return false;
    }
  }

  @override
  Future<bool> registerStudent(StudentEntity student) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: jsonEncode({
          "action": "REGISTER_STUDENT",
          "data": {
            "name": student.name,
            "grade": student.grade,
            "address": student.address,
            "diacon": student.diacon,
            "whatsapp": student.whatsapp,
            "phone": student.phone,
            "notes": student.notes,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        // For Google Apps Script, 302 often means success but redirecting
        if (response.statusCode == 302 || response.body.isEmpty) {
          return true;
        }
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Register Error: $e");
      return false;
    }
  }
}
