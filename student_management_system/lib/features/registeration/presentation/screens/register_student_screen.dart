import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/entities/student_entity.dart';
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
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return "مطلوب";
    final regExp = RegExp(r'^01[0125][0-9]{8}$');
    if (!regExp.hasMatch(value)) {
      return "يجب أن يكون 11 رقم ويبدأ بـ 01";
    }
    return null;
  }

  void _submit() async {
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
          const SnackBar(
            content: Text("تم تسجيل الطالب بنجاح ✅"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("حدث خطأ أثناء التسجيل ❌"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text("تسجيل طالب جديد"),
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
                _buildSectionHeader("المعلومات الأساسية"),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "الاسم بالكامل",
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  onSaved: (val) => _name = val!,
                  validator: (val) => val!.isEmpty ? "برجاء ادخال الاسم" : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _grade,
                        decoration: const InputDecoration(
                          labelText: "المرحلة",
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: ['4', '5', '6']
                            .map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text("صف $g"),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _grade = val!),
                        validator: (val) => val == null ? "مطلوب" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _diacon,
                        decoration: const InputDecoration(
                          labelText: "الحالة",
                          prefixIcon: Icon(Icons.auto_awesome_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: "نعم",
                            child: Text("نعم"),
                          ),
                          const DropdownMenuItem(
                            value: "لا",
                            child: Text("لا"),
                          ),
                          const DropdownMenuItem(
                            value: "بنت",
                            child: Text("بنت"),
                          ),
                        ],
                        onChanged: (val) => setState(() => _diacon = val!),
                        validator: (val) => val == null ? "مطلوب" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader("معلومات الاتصال"),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "العنوان",
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  onSaved: (val) => _address = val!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "رقم الواتساب",
                    prefixIcon: Icon(Icons.chat_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  onSaved: (val) => _whatsapp = val!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "رقم التليفون",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  onSaved: (val) => _phone = val!,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader("إضافات"),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "ملحوظات",
                    prefixIcon: Icon(Icons.note_alt_outlined),
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
                    onPressed: _submit,
                    child: const Text("حفظ البيانات"),
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
