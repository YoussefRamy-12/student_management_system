import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/excel_helper.dart';
import '../providers/student_provider.dart';

class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('استيراد وتصدير البيانات')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionCard(
              context,
              title: 'استيراد من Excel',
              subtitle: 'إضافة مجموعة طلاب من ملف خارجي',
              icon: Icons.upload_file_rounded,
              color: Colors.green,
              onTap: () {
                // TODO: Implement Excel Import
              },
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              title: 'تصدير إلى Excel',
              subtitle: 'حفظ قائمة الطلاب والغياب في ملف',
              icon: Icons.download_for_offline_rounded,
              color: Colors.blue,
              onTap: () => _showRenameDialog(context, ref),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              title: 'نسخة احتياطية',
              subtitle: 'رفع نسخة احتياطية للسحابة',
              icon: Icons.cloud_upload_rounded,
              color: Colors.orange,
              onTap: () {
                // TODO: Implement Backup
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: 'students_list');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'تسمية الملف',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أدخل اسم ملف Excel المراد تصديره',
                style: TextStyle(color: AppTheme.textLightColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller,
                textAlign: TextAlign.center,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال اسم الملف';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'اسم الملف',
                  suffixText: '.xlsx',
                  filled: true,
                  fillColor: AppTheme.primaryColor.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(fontSize: 12),
                ),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textLightColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    final isEnabled = value.text.trim().isNotEmpty;
                    return ElevatedButton(
                      onPressed: isEnabled
                          ? () {
                              if (formKey.currentState!.validate()) {
                                final name = controller.text.trim();
                                Navigator.pop(context);
                                _exportData(context, ref, name);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('تصدير'),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref, String fileName) async {
    try {
      // 1. Show loading state
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('جاري تحضير ملف Excel...')),
        );
      }

      // 2. Fetch students data (await if loading)
      final students = await ref.read(studentsListProvider.future);

      if (students.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يوجد طلاب لتصديرهم')),
          );
        }
        return;
      }

      // 3. Export
      await ExcelHelper.exportStudentsToExcel(students, fileName: fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تصدير الملف بنجاح! ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
