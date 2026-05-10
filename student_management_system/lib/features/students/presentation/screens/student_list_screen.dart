import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/entities/student_entity.dart';
import '../../../registeration/presentation/screens/register_student_screen.dart';
import '../providers/student_provider.dart';

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We "watch" the provider. Riverpod handles loading/error/data automatically.
    final studentsAsync = ref.watch(studentsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام إدارة الطلاب'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterStudentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: studentsAsync.when(
        data: (students) => ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return ListTile(
              title: Text(student.name),
              subtitle: Text('Grade: ${student.grade}'),
              leading: CircleAvatar(child: Text(student.id)),
              trailing: const Icon(Icons.check_circle_outline),
              onTap: () => _showAttendanceDialog(context, ref, student),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAttendanceDialog(
    BuildContext context,
    WidgetRef ref,
    StudentEntity student,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل حضور: ${student.name}'),
        content: const Text('اختر نوع الخدمة:'),
        actions: [
          TextButton(
            onPressed: () =>
                _sendAttendance(context, ref, student, "حضور حصة السبت"),
            child: const Text('حصة'),
          ),
          TextButton(
            onPressed: () =>
                _sendAttendance(context, ref, student, "اعتذار عن حصة السبت"),
            child: const Text('اعتذار حصة'),
          ),
          TextButton(
            onPressed: () =>
                _sendAttendance(context, ref, student, "حضور قداس الجمعة"),
            child: const Text('قداس'),
          ),
          TextButton(
            onPressed: () =>
                _sendAttendance(context, ref, student, "اعتذار عن قداس الجمعة"),
            child: const Text('اعتذار قداس'),
          ),
        ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التسجيل بنجاح! ✅'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل التسجيل ❌'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
