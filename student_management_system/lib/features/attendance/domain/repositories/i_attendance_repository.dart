import '../../../../core/entities/student_entity.dart';

abstract class IAttendanceRepository {
  Future<List<StudentEntity>> getStudents();
  Future<bool> submitAttendance(String id, String type);
}
