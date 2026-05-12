import '../../../../core/entities/student_entity.dart';

abstract class IStudentRepository {
  Future<List<StudentEntity>> fetchAllStudents();
  Future<bool> submitAttendance(String id, String name, String type);
  Future<bool> registerStudent(StudentEntity student);
  Future<bool> bulkRegisterStudents(List<StudentEntity> students);
  Future<bool> clearAllStudents();
}
