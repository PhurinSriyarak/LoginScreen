import 'package:flutter/material.dart';
import 'package:flutter_login_screen/Screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ซ่อน Debug Banner
      title: 'Login App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LoginScreen(), // เปิดแอปมาให้ไปที่หน้า Login ก่อน
    );
  }
}
