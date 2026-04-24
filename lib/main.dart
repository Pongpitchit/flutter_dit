import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CoffeeApp());
}

class CoffeeApp extends StatelessWidget {
  const CoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thai Coffee House',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A2C0A),
          brightness: Brightness.light,
        ),
        fontFamily: 'Sarabun',
        useMaterial3: true,
      ),
      home: const LoginScreen(), // เริ่มที่หน้า login screen
    );
  }
}
