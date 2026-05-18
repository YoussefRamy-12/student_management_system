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
  final int theDivineLiturgyPresent;
  final int theDivineLiturgyExcuse;
  final double classAttendanceRate;
  final double theDivineLiturgyAttendanceRate;
  final List<StudentEntity> absentTheDivineLiturgyNoExcuse;
  final List<StudentEntity> absentClassNoExcuse;
  final List<AttendanceRecord> theDivineLiturgyExcuseRecords;
  final List<AttendanceRecord> classExcuseRecords;
  final Map<String, int> activityCounts;

  AnalyticsSnapshot({
    required this.totalRegistered,
    required this.classPresent,
    required this.classExcuse,
    required this.theDivineLiturgyPresent,
    required this.theDivineLiturgyExcuse,
    required this.classAttendanceRate,
    required this.theDivineLiturgyAttendanceRate,
    required this.absentTheDivineLiturgyNoExcuse,
    required this.absentClassNoExcuse,
    required this.theDivineLiturgyExcuseRecords,
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
        final theDivineLiturgyPresent = activityCounts['حضور قداس الجمعة'] ?? 0;
        final theDivineLiturgyExcuse =
            activityCounts['اعتذار عن قداس الجمعة'] ?? 0;

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
        final theDivineLiturgyPresentIds = records
            .where((r) => r.type == 'حضور قداس الجمعة')
            .map((r) => r.id)
            .toSet();
        final theDivineLiturgyExcuseIds = records
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
        final absentTheDivineLiturgyNoExcuse = students
            .where(
              (s) =>
                  !theDivineLiturgyPresentIds.contains(s.id) &&
                  !theDivineLiturgyExcuseIds.contains(s.id),
            )
            .toList();

        // Excuse records for detail tables
        final theDivineLiturgyExcuseRecords = records
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
            theDivineLiturgyPresent: theDivineLiturgyPresent,
            theDivineLiturgyExcuse: theDivineLiturgyExcuse,
            classAttendanceRate: total > 0 ? (classPresent / total) * 100 : 0,
            theDivineLiturgyAttendanceRate: total > 0
                ? (theDivineLiturgyPresent / total) * 100
                : 0,
            absentTheDivineLiturgyNoExcuse: absentTheDivineLiturgyNoExcuse,
            absentClassNoExcuse: absentClassNoExcuse,
            theDivineLiturgyExcuseRecords: theDivineLiturgyExcuseRecords,
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
