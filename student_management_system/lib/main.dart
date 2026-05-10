import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/students/presentation/screens/student_list_screen.dart';

void main() {
  runApp(
    // ProviderScope is required for Riverpod to work
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App - Clean Architecture',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const StudentListScreen(),
    );
  }
}
