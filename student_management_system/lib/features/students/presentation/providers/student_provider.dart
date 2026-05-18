import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_system/core/entities/student_entity.dart';
import 'package:student_management_system/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:student_management_system/features/attendance/data/repositories/student_repository_impl.dart';
import 'package:student_management_system/features/attendance/domain/repositories/i_student_repository.dart';
import 'package:student_management_system/features/attendance/domain/usecases/get_all_students_usecase.dart';
import 'package:student_management_system/features/settings/presentation/providers/settings_provider.dart';

// 1. Provide the Remote Data Source
final remoteDataSourceProvider = Provider<IAttendanceRemoteDataSource>((ref) {
  final settings = ref.watch(settingsProvider);
  return AttendanceRemoteDataSourceImpl(settings.serverUrl);
});

// 2. Provide the Repository Implementation
final studentRepositoryProvider = Provider<IStudentRepository>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  return StudentRepositoryImpl(remoteDataSource);
});

// 3. Provide the Use Case
final getAllStudentsUseCaseProvider = Provider<GetAllStudentsUseCase>((ref) {
  final repository = ref.watch(studentRepositoryProvider);
  return GetAllStudentsUseCase(repository);
});

// 4. The State Provider: This is what the UI "listens" to
final studentsListProvider = FutureProvider<List<StudentEntity>>((ref) {
  final useCase = ref.watch(getAllStudentsUseCaseProvider);
  return useCase.execute();
});

// --- Search Implementation ---

class StudentSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

/// Provider to hold the current search query
final studentSearchQueryProvider =
    NotifierProvider.autoDispose<StudentSearchQueryNotifier, String>(
  StudentSearchQueryNotifier.new,
);

/// Provider to return filtered students based on ID
final filteredStudentsProvider =
    Provider.autoDispose<AsyncValue<List<StudentEntity>>>((ref) {
      final studentsAsync = ref.watch(studentsListProvider);
      final query = ref.watch(studentSearchQueryProvider).trim();

      return studentsAsync.whenData((students) {
        if (query.isEmpty) return students;
        // Filter by student ID
        return students
            .where(
              (student) =>
                  student.id.contains(query) || student.name.contains(query),
            )
            .toList();
      });
    });
