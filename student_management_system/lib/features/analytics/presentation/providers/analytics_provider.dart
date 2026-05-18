import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_system/core/entities/student_entity.dart';
import 'package:student_management_system/features/analytics/data/models/analytics_model.dart';
import 'package:student_management_system/features/students/presentation/providers/student_provider.dart';

class SelectedAnalyticsDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime newDate) {
    state = newDate;
  }
}

/// Selected date for analytics (defaults to today)
final selectedAnalyticsDateProvider =
    NotifierProvider<SelectedAnalyticsDateNotifier, DateTime>(
  SelectedAnalyticsDateNotifier.new,
);

/// Fetches attendance records for the selected date from the backend
final attendanceRecordsProvider = FutureProvider<List<AttendanceRecord>>((
  ref,
) async {
  final date = ref.watch(selectedAnalyticsDateProvider);
  final dateStr =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getAttendanceByDate(dateStr);
});

/// Computed analytics snapshot that combines cached students + attendance records
class AnalyticsSnapshot {
  final int totalRegistered;
  final int classPresent;
  final int classExcuse;
  final int massPresent;
  final int massExcuse;
  final double classAttendanceRate;
  final double massAttendanceRate;
  final List<StudentEntity> absentMassNoExcuse;
  final List<StudentEntity> absentClassNoExcuse;
  final List<AttendanceRecord> massExcuseRecords;
  final List<AttendanceRecord> classExcuseRecords;
  final Map<String, int> activityCounts;

  AnalyticsSnapshot({
    required this.totalRegistered,
    required this.classPresent,
    required this.classExcuse,
    required this.massPresent,
    required this.massExcuse,
    required this.classAttendanceRate,
    required this.massAttendanceRate,
    required this.absentMassNoExcuse,
    required this.absentClassNoExcuse,
    required this.massExcuseRecords,
    required this.classExcuseRecords,
    required this.activityCounts,
  });
}

/// Provider that combines students list (cached) + attendance records to produce analytics
final analyticsSnapshotProvider = Provider<AsyncValue<AnalyticsSnapshot>>((
  ref,
) {
  final studentsAsync = ref.watch(studentsListProvider);
  final recordsAsync = ref.watch(attendanceRecordsProvider);

  return studentsAsync.when(
    data: (students) => recordsAsync.when(
      data: (records) {
        // Count each activity type
        final activityCounts = <String, int>{};
        for (final r in records) {
          activityCounts[r.type] = (activityCounts[r.type] ?? 0) + 1;
        }

        final classPresent = activityCounts['حضور حصة السبت'] ?? 0;
        final classExcuse = activityCounts['اعتذار عن حصة السبت'] ?? 0;
        final massPresent = activityCounts['حضور قداس الجمعة'] ?? 0;
        final massExcuse = activityCounts['اعتذار عن قداس الجمعة'] ?? 0;

        final total = students.length;

        // IDs of students who attended or excused
        final classPresentIds = records
            .where((r) => r.type == 'حضور حصة السبت')
            .map((r) => r.id)
            .toSet();
        final classExcuseIds = records
            .where((r) => r.type == 'اعتذار عن حصة السبت')
            .map((r) => r.id)
            .toSet();
        final massPresentIds = records
            .where((r) => r.type == 'حضور قداس الجمعة')
            .map((r) => r.id)
            .toSet();
        final massExcuseIds = records
            .where((r) => r.type == 'اعتذار عن قداس الجمعة')
            .map((r) => r.id)
            .toSet();

        // Students absent without excuse
        final absentClassNoExcuse = students
            .where(
              (s) =>
                  !classPresentIds.contains(s.id) &&
                  !classExcuseIds.contains(s.id),
            )
            .toList();
        final absentMassNoExcuse = students
            .where(
              (s) =>
                  !massPresentIds.contains(s.id) &&
                  !massExcuseIds.contains(s.id),
            )
            .toList();

        // Excuse records for detail tables
        final massExcuseRecords = records
            .where((r) => r.type == 'اعتذار عن قداس الجمعة')
            .toList();
        final classExcuseRecords = records
            .where((r) => r.type == 'اعتذار عن حصة السبت')
            .toList();

        return AsyncValue.data(
          AnalyticsSnapshot(
            totalRegistered: total,
            classPresent: classPresent,
            classExcuse: classExcuse,
            massPresent: massPresent,
            massExcuse: massExcuse,
            classAttendanceRate: total > 0 ? (classPresent / total) * 100 : 0,
            massAttendanceRate: total > 0 ? (massPresent / total) * 100 : 0,
            absentMassNoExcuse: absentMassNoExcuse,
            absentClassNoExcuse: absentClassNoExcuse,
            massExcuseRecords: massExcuseRecords,
            classExcuseRecords: classExcuseRecords,
            activityCounts: activityCounts,
          ),
        );
      },
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
