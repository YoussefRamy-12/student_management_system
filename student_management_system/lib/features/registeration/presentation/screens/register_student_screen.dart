import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/entities/student_entity.dart';
import '../providers/registration_provider.dart';
import '../../../../features/students/presentation/providers/student_provider.dart';

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
  String _grade = '4';
  String? _address;
  String _diacon = 'لا';
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
      appBar: AppBar(title: const Text("تسجيل طالب جديد")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Full Name
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "الاسم بالكامل",
                  prefixIcon: Icon(Icons.person),
                ),
                onSaved: (val) => _name = val!,
                validator: (val) => val!.isEmpty ? "برجاء ادخال الاسم" : null,
              ),
              const SizedBox(height: 15),

              // 2. Grade Dropdown (4, 5, 6)
              DropdownButtonFormField<String>(
                value: _grade,
                decoration: const InputDecoration(labelText: "المرحلة"),
                items: ['4', '5', '6']
                    .map(
                      (g) => DropdownMenuItem(value: g, child: Text("صف $g")),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _grade = val!),
                validator: (val) => val == null ? "مطلوب" : null,
              ),
              const SizedBox(height: 15),

              // 5. Address
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "العنوان",
                  prefixIcon: Icon(Icons.location_on),
                ),
                onSaved: (val) => _address = val!,
              ),
              const SizedBox(height: 15),

              // 6. Diacon Status (Yes / No / Girl)
              DropdownButtonFormField<String>(
                value: _diacon,
                decoration: const InputDecoration(labelText: "الحالة (شماس؟)"),
                items: [
                  const DropdownMenuItem(value: "نعم", child: Text("نعم")),
                  const DropdownMenuItem(value: "لا", child: Text("لا")),
                  const DropdownMenuItem(value: "بنت", child: Text("بنت")),
                ],
                onChanged: (val) => setState(() => _diacon = val!),
                validator: (val) => val == null ? "مطلوب" : null,
              ),
              const SizedBox(height: 15),

              // 4. WhatsApp Number
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "رقم الواتساب",
                  prefixIcon: Icon(Icons.chat),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                onSaved: (val) => _whatsapp = val!,
              ),
              const SizedBox(height: 15),

              // 3. Phone Number
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "رقم التليفون",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                onSaved: (val) => _phone = val!,
              ),
              const SizedBox(height: 15),

              // 7. Notes
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "ملحوظات",
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
                onSaved: (val) => _notes = val!,
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _submit,
                child: const Text(
                  "حفظ البيانات",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
