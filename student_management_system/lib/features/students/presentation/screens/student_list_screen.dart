import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/entities/student_entity.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/student_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/responsive_layout.dart';

class StudentListScreen extends ConsumerWidget {
  final bool isAttendanceMode;

  const StudentListScreen({super.key, this.isAttendanceMode = true});

  void search(WidgetRef ref, String value) {
    if (value.isEmpty) {
      ref.read(studentSearchQueryProvider.notifier).updateQuery("");
    } else {
      ref.read(studentSearchQueryProvider.notifier).updateQuery(value);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered provider instead of the raw list
    final studentsAsync = ref.watch(filteredStudentsProvider);
    final l10n = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        title: Text(
          isAttendanceMode ? l10n.recordAttendance : l10n.studentDirectory,
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              style: GoogleFonts.outfit(fontSize: 15),
              onChanged: (value) => search(ref, value),
              decoration: InputDecoration(
                hintText: l10n.searchById,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: studentsAsync.when(
        data: (students) => RefreshIndicator(
          onRefresh: () => ref.refresh(studentsListProvider.future),
          child: ResponsiveContainer(
            maxWidth: 800,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = students[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                        '${l10n.grade} ${student.grade} • ID: ${student.id}',
                        style: GoogleFonts.outfit(fontSize: 13),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isAttendanceMode
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isAttendanceMode
                            ? Icon(
                                Icons.fingerprint_rounded,
                                color: Colors.blue,
                              )
                            : InkWell(
                                onTap: () => _shareOnWhatsApp(
                                  student.whatsapp,
                                  student.name,
                                  message: l10n.whatsappMessage(student.name),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Colors.green,
                                  size: 30,
                                ),
                              ),
                      ),
                      onTap: isAttendanceMode
                          ? () => _showAttendanceBottomSheet(
                              context,
                              ref,
                              student,
                              l10n,
                            )
                          : () {
                              _showStudentDetails(context, student, l10n);
                            },
                    ),
                  ),
                );
              },
            ),
          ),
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
              Text(l10n.errorOccurred(err.toString())),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(
    BuildContext context,
    StudentEntity student,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 650),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                l10n.studentDetails,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow(Icons.person, l10n.name, student.name),
              _detailRow(Icons.badge, l10n.id, student.id),
              _detailRow(Icons.school, l10n.grade, student.grade),
              _detailRow(Icons.location_on, l10n.address, student.address),
              _detailRow(Icons.chat, l10n.whatsapp, student.whatsapp),
              _detailRow(Icons.phone, l10n.mobile, student.phone),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => _shareOnWhatsApp(
                      student.whatsapp,
                      student.name,
                      message: l10n.whatsappMessage(student.name),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: AppTheme.presentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.whatsappFollowup,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareOnWhatsApp(
    String phoneNumber,
    String name, {
    String? message,
  }) async {
    // Remove any non-digit characters from phone number for WhatsApp format
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    message ??=
        "سلام ونعمة من حصة صموئيل النبى. كنا مستنينك النهاردة يا " +
        name.split(" ")[0] +
        " افتقدناك النهارده، نتمنى تكون بخير ونشوفك المرة الجاية!🙏";
    // WhatsApp link format
    final url = Uri.parse('https://wa.me/+20$cleanNumber?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Show an error message if WhatsApp is not installed
      debugPrint('Could not launch WhatsApp');
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  void _showAttendanceBottomSheet(
    BuildContext context,
    WidgetRef ref,
    StudentEntity student,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 650),
      builder: (sheetContext) {
        return _AttendanceBottomSheet(
          student: student,
          l10n: l10n,
          onSendAttendance: (type, note, date) {
            _sendAttendance(sheetContext, ref, student, type, note, date, l10n);
          },
        );
      },
    );
  }

  void _sendAttendance(
    BuildContext context,
    WidgetRef ref,
    StudentEntity student,
    String type,
    String? note,
    DateTime? date,
    AppLocalizations l10n,
  ) async {
    Navigator.pop(
      context,
    ); // Close bottom sheet immediately so user isn't stuck

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.recordingAttendance)));

    final repository = ref.read(studentRepositoryProvider);
    bool success = await repository.submitAttendance(
      student.id,
      student.name,
      type,
      note ?? "",
      date ?? DateTime.now(),
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.attendanceRecordedSuccess),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.attendanceRecordedFailed),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _AttendanceBottomSheet extends StatefulWidget {
  final StudentEntity student;
  final AppLocalizations l10n;
  final void Function(String type, String? note, DateTime? date)
  onSendAttendance;

  const _AttendanceBottomSheet({
    required this.student,
    required this.l10n,
    required this.onSendAttendance,
  });

  @override
  State<_AttendanceBottomSheet> createState() => _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<_AttendanceBottomSheet> {
  late final TextEditingController _noteController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final l10n = widget.l10n;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
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
              l10n.recordAttendance,
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
            const SizedBox(height: 24),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppTheme.primaryColor,
                          onPrimary: Colors.white,
                          onSurface: AppTheme.textDarkColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.attendanceDate,
                  labelStyle: GoogleFonts.outfit(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                      style: GoogleFonts.outfit(fontSize: 16),
                    ),
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.notesOptional,
                labelStyle: GoogleFonts.outfit(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _AttendanceOption(
                    title: l10n.classLabel,
                    icon: Icons.school_rounded,
                    color: Colors.blue,
                    isDisabled: _selectedDate.weekday != DateTime.saturday,
                    onTap: () => widget.onSendAttendance(
                      "حضور حصة السبت",
                      _noteController.text,
                      _selectedDate,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AttendanceOption(
                    title: l10n.classExcuse,
                    icon: Icons.event_busy_rounded,
                    color: Colors.orange,
                    onTap: () => widget.onSendAttendance(
                      "اعتذار عن حصة السبت",
                      _noteController.text,
                      _selectedDate,
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
                    title: l10n.theDivineLiturgyLabel,
                    icon: Icons.church_rounded,
                    color: Colors.purple,
                    isDisabled: _selectedDate.weekday != DateTime.friday,
                    onTap: () => widget.onSendAttendance(
                      "حضور قداس الجمعة",
                      _noteController.text,
                      _selectedDate,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AttendanceOption(
                    title: l10n.theDivineLiturgyExcuse,
                    icon: Icons.cancel_presentation_rounded,
                    color: Colors.red,
                    onTap: () => widget.onSendAttendance(
                      "اعتذار عن قداس الجمعة",
                      _noteController.text,
                      _selectedDate,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDisabled;

  const _AttendanceOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isDisabled ? Colors.grey : color;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: displayColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: displayColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: displayColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: displayColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
