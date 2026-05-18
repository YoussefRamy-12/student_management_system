import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/entities/student_entity.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/registration_provider.dart';
import '../../../../features/students/presentation/providers/student_provider.dart';
import '../../../../core/widgets/responsive_layout.dart';

class RegisterStudentScreen extends ConsumerStatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  ConsumerState<RegisterStudentScreen> createState() =>
      _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends ConsumerState<RegisterStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  // State variables for form fields
  String? _name;
  String? _grade;
  String? _address;
  String? _diacon;
  String? _whatsapp;
  String? _phone;
  String? _notes;

  // Validation Logic
  String? _validatePhone(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.required;
    final regExp = RegExp(r'^01[0125][0-9]{8}$');
    if (!regExp.hasMatch(value)) {
      return l10n.phoneValidationMatch;
    }
    return null;
  }

  void _submit(AppLocalizations l10n) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newStudent = StudentEntity(
        id: "0",
        name: _name!,
        grade: _grade!,
        address: _address!,
        diacon: _diacon!,
        whatsapp: _whatsapp!,
        phone: _phone ?? "",
        notes: _notes ?? "",
      );

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await ref.read(registerStudentUseCaseProvider)(
        newStudent,
      );

      Navigator.pop(context); // Remove loading

      if (success) {
        // Refresh the student list so the new student appears
        ref.invalidate(studentsListProvider);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.registerSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.registerFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(l10n.registerNewStudent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ResponsiveContainer(
          maxWidth: 700,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(l10n.basicInfo),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  onSaved: (val) => _name = val!,
                  validator: (val) =>
                      val!.isEmpty ? l10n.enterNamePrompt : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        initialValue: _grade,
                        decoration: InputDecoration(
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          labelText: l10n.gradeSelect,
                          prefixIcon: const Icon(Icons.school_outlined),
                        ),
                        items: ['4', '5', '6']
                            .map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text(l10n.gradeItem(g)),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _grade = val!),
                        validator: (val) => val == null ? l10n.required : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _diacon,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.status,
                          prefixIcon: const Icon(Icons.auto_awesome_outlined),
                        ),
                        items: [
                          DropdownMenuItem(value: "نعم", child: Text(l10n.yes)),
                          DropdownMenuItem(value: "لا", child: Text(l10n.no)),
                          DropdownMenuItem(
                            value: "بنت",
                            child: Text(l10n.girl),
                          ),
                        ],
                        onChanged: (val) => setState(() => _diacon = val!),
                        validator: (val) => val == null ? l10n.required : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.contactInfo),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.address,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  onSaved: (val) => _address = val!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.whatsapp,
                    prefixIcon: const Icon(Icons.chat_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) => _validatePhone(val, l10n),
                  onSaved: (val) => _whatsapp = val!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.mobile,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) => _validatePhone(val, l10n),
                  onSaved: (val) => _phone = val!,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.additions),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.notes,
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                  ),
                  maxLines: 3,
                  onSaved: (val) => _notes = val!,
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () => _submit(l10n),
                    child: Text(l10n.saveData),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
