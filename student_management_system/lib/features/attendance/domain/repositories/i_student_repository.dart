import '../../../../core/entities/student_entity.dart';
import '../../../analytics/data/models/analytics_model.dart';

abstract class IStudentRepository {
  Future<List<StudentEntity>> fetchAllStudents();
  Future<bool> submitAttendance(
    String id,
    String name,
    String type,
    String note,
    DateTime date,
  );
  Future<bool> registerStudent(StudentEntity student);
  Future<bool> bulkRegisterStudents(List<StudentEntity> students);
  Future<bool> clearAllStudents();
  Future<List<AttendanceRecord>> getAttendanceByDate(String date);
}
