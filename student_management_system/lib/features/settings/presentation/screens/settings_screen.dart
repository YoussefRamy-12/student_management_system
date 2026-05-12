import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingTile(
            title: 'المظهر',
            subtitle: 'تغيير سمة التطبيق',
            icon: Icons.palette_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            title: 'اللغة',
            subtitle: 'العربية',
            icon: Icons.language_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            title: 'الخادم (Server)',
            subtitle: 'إعدادات الاتصال بقاعدة البيانات',
            icon: Icons.dns_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            title: 'عن التطبيق',
            subtitle: 'الإصدار 1.0.0',
            icon: Icons.info_outline_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
