import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استيراد وتصدير البيانات'),
      ),
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
              onTap: () {
                // TODO: Implement Excel Export
              },
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
            Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}
