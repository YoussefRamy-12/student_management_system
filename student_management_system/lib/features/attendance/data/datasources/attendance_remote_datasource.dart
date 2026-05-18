import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/entities/student_entity.dart';
import '../../../../core/models/student.dart';
import '../../../analytics/data/models/analytics_model.dart';

abstract class IAttendanceRemoteDataSource {
  Future<List<StudentModel>> getStudents();
  Future<bool> submitAttendance({
    required String id,
    required String name,
    required String type,
    required DateTime date,
    String? exception,
    String? note,
  });
  Future<bool> registerStudent(StudentEntity student);
  Future<bool> bulkRegisterStudents(List<StudentEntity> students);
  Future<bool> clearAllStudents();
  Future<List<AttendanceRecord>> getAttendanceByDate(String date);
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
    required DateTime date,
    String? exception,
    String? note,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          "action": "SUBMIT_ATTENDANCE",
          "data": {
            "date": date.toIso8601String().substring(0, 10),
            "id": id,
            "name": name,
            "type": type,
            "exception": exception,
            "note": note,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
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

  @override
  Future<bool> registerStudent(StudentEntity student) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'text/plain'},
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

      debugPrint("Register Response: ${response.statusCode}");
      debugPrint("Register Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 302) {
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

  @override
  Future<bool> bulkRegisterStudents(List<StudentEntity> students) async {
    try {
      debugPrint(
        "Bulk Registering ${students.length} students in small batches...",
      );

      const int batchSize = 15;
      for (var i = 0; i < students.length; i += batchSize) {
        final end = (i + batchSize < students.length)
            ? i + batchSize
            : students.length;
        final batch = students.sublist(i, end);

        debugPrint(
          "Sending batch ${i ~/ batchSize + 1} (${batch.length} students)...",
        );

        final response = await http.post(
          Uri.parse(_url),
          headers: {'Content-Type': 'text/plain'},
          body: jsonEncode({
            "action": "BULK_REGISTER",
            "data": batch
                .map(
                  (s) => {
                    "id": s.id,
                    "name": s.name,
                    "grade": s.grade,
                    "address": s.address,
                    "diacon": s.diacon,
                    "whatsapp": s.whatsapp,
                    "phone": s.phone,
                    "notes": s.notes,
                  },
                )
                .toList(),
          }),
        );

        debugPrint("Batch Response Code: ${response.statusCode}");

        if (response.statusCode != 200 && response.statusCode != 302) {
          debugPrint("Batch failed with code ${response.statusCode}");
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint("Bulk Register Error: $e");
      return false;
    }
  }

  @override
  Future<bool> clearAllStudents() async {
    try {
      debugPrint("Clearing all students...");
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({"action": "CLEAR_ALL_STUDENTS"}),
      );

      debugPrint("Clear Response Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 302) {
        if (response.statusCode == 302 || response.body.isEmpty) return true;
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Clear Error: $e");
      return false;
    }
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceByDate(String date) async {
    try {
      debugPrint("Fetching analytics for date: $date");

      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          "action": "GET_ANALYTICS",
          "data": {"date": date},
        }),
      );

      debugPrint("Analytics Response Code: ${response.statusCode}");
      debugPrint("Analytics Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          final List<dynamic> recordsJson = result['data']['records'] ?? [];
          debugPrint("Analytics Records Count: ${recordsJson.length}");
          return recordsJson
              .map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
              .toList();
        } else {
          debugPrint("Analytics status not success: ${result['status']}");
        }
      } else if (response.statusCode == 302) {
        // Fallback for environments where automatic redirect following is disabled
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectResponse = await http.get(Uri.parse(redirectUrl));
          if (redirectResponse.statusCode == 200) {
            final result = jsonDecode(redirectResponse.body);
            if (result['status'] == 'success') {
              final List<dynamic> recordsJson = result['data']['records'] ?? [];
              return recordsJson
                  .map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
                  .toList();
            }
          }
        }
      }

      return [];
    } catch (e) {
      debugPrint("Analytics Error: $e");
      return [];
    }
  }
}
