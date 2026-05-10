import 'package:student_management_system/core/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  StudentModel({
    required super.id,
    required super.name,
    required super.grade,
    required super.address,
    required super.diacon,
    required super.whatsapp,
    required super.phone,
    required super.notes,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['ID'].toString(),
      name: json['الاسم'].toString(),
      grade: json['المرحلة'].toString(),
      address: json['العنوان'].toString(),
      diacon: json['مرشوم شماس'].toString(),
      whatsapp: json['رقم تليفون (واتس اب)'].toString(),
      phone: json['رقم تليفون اخر'].toString(),
      notes: json['ملحوظات'].toString(),
    );
  }
}
