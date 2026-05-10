import '../../../../core/entities/student_entity.dart';
import '../../domain/repositories/i_student_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class StudentRepositoryImpl implements IStudentRepository {
  final IAttendanceRemoteDataSource remoteDataSource;

  StudentRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StudentEntity>> fetchAllStudents() async {
    final models = await remoteDataSource.getStudents();
    return models; 
  }

  @override
  Future<bool> submitAttendance(String id, String name, String type) async {
    return await remoteDataSource.submitAttendance(
      id: id,
      name: name,
      type: type,
    );
  }

  @override
  Future<bool> registerStudent(StudentEntity student) async {
    return await remoteDataSource.registerStudent(student);
  }
}
