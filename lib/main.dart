import 'package:flutter/material.dart';
import 'package:flutter_login_screen/Screen/login_screen.dart' show LoginScreen;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(primarySwatch: Colors.teal),
      // เพิ่ม routes อย่างน้อยสำหรับกลับหน้า login แบบล้าง stack
      routes: {'/login': (_) => const LoginScreen()},
      home: const LoginScreen(),
    );
  }
}
