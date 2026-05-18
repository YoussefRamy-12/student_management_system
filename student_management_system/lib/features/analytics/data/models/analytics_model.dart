class AttendanceRecord {
  final String id;
  final String name;
  final String type;
  final String notes;

  AttendanceRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }
}
