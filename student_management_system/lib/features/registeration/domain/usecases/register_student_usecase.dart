import '../../../../core/entities/student_entity.dart';
import '../../../../features/attendance/domain/repositories/i_student_repository.dart';

class RegisterStudentUseCase {
  final IStudentRepository repository;

  RegisterStudentUseCase(this.repository);

  // We pass the entity to be saved
  Future<bool> call(StudentEntity student) async {
    return await repository.registerStudent(student);
  }
}
