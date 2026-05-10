import '../../../../core/entities/student_entity.dart';
import '../repositories/i_student_repository.dart';

class GetAllStudentsUseCase {
  final IStudentRepository repository;

  GetAllStudentsUseCase(this.repository);

  Future<List<StudentEntity>> execute() async {
    return await repository.fetchAllStudents();
  }
}
