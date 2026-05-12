import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/entities/student_entity.dart';
import '../providers/student_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We "watch" the provider. Riverpod handles loading/error/data automatically.
    final studentsAsync = ref.watch(studentsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الطلاب')),
      body: studentsAsync.when(
        data: (students) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: students.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final student = students[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      student.name.isNotEmpty ? student.name[0] : "?",
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  student.name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'الصف ${student.grade} • ${student.diacon}',
                  style: GoogleFonts.outfit(fontSize: 13),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                onTap: () => _showAttendanceBottomSheet(context, ref, student),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('حدث خطأ: $err'),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceBottomSheet(
    BuildContext context,
    WidgetRef ref,
    StudentEntity student,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تسجيل حضور',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              student.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: AppTheme.textLightColor,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _AttendanceOption(
                    title: 'حصة',
                    icon: Icons.school_rounded,
                    color: Colors.blue,
                    onTap: () => _sendAttendance(
                      context,
                      ref,
                      student,
                      "حضور حصة السبت",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AttendanceOption(
                    title: 'اعتذار حصة',
                    icon: Icons.event_busy_rounded,
                    color: Colors.orange,
                    onTap: () => _sendAttendance(
                      context,
                      ref,
                      student,
                      "اعتذار عن حصة السبت",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AttendanceOption(
                    title: 'قداس',
                    icon: Icons.church_rounded,
                    color: Colors.purple,
                    onTap: () => _sendAttendance(
                      context,
                      ref,
                      student,
                      "حضور قداس الجمعة",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AttendanceOption(
                    title: 'اعتذار قداس',
                    icon: Icons.cancel_presentation_rounded,
                    color: Colors.red,
                    onTap: () => _sendAttendance(
                      context,
                      ref,
                      student,
                      "اعتذار عن قداس الجمعة",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _sendAttendance(
    BuildContext context,
    WidgetRef ref,
    StudentEntity student,
    String type,
  ) async {
    Navigator.pop(context); // Close dialog

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري التسجيل...')));

    final repository = ref.read(studentRepositoryProvider);
    bool success = await repository.submitAttendance(
      student.id,
      student.name,
      type,
    );

    if (!context.mounted) return;

    if (success) {
      if (context.mounted) Navigator.pop(context); // Close bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التسجيل بنجاح! ✅'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل التسجيل ❌'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _AttendanceOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AttendanceOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
