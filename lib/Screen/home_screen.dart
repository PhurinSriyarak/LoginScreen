import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "หน้าหลัก",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // ออกจากระบบ → กลับหน้า Login
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "ยินดีต้อนรับคุณ $username 🎉",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
