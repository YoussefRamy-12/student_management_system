import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_system/features/students/presentation/providers/student_provider.dart';
// import '../../../attendance/presentation/providers/student_provider.dart';
import '../../domain/usecases/register_student_usecase.dart';

// We "borrow" the repository from the attendance feature to save space
final registerStudentUseCaseProvider = Provider((ref) {
  final repository = ref.watch(studentRepositoryProvider);
  return RegisterStudentUseCase(repository);
});
