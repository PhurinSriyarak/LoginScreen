import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/user_storage.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initSample(); // สร้าง sample user (admin / 1234) สำหรับทดสอบ
  }

  Future<void> _initSample() async {
    await UserStorage.ensureSampleUser();
    setState(() {
      _loading = false;
    });
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')));
      return;
    }

    final user = await UserStorage.getUserByUsername(username);
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบผู้ใช้งาน')));
      return;
    }

    final ok = AuthService.verifyPassword(password, user.passwordHash);
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เข้าสู่ระบบสำเร็จ ✅')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
      );
      // TODO: ไปหน้า Home
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รหัสผ่านไม่ถูกต้อง ❌')));
    }
  }

  void _goForgot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/blackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: Image.asset("assets/images/logo.jpeg", height: 100),
                ),
                const SizedBox(height: 10),
                Text(
                  "บริษัท แม็กเทคคอโซลูชั่น จำกัด",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 40),

                // ✅ เพิ่มหัวข้อ "ลงชื่อเข้าสู่ระบบ"
                Text(
                  "ลงชื่อเข้าสู่ระบบ",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 11, 207, 177),
                  ),
                ),
                const SizedBox(height: 20),

                // ช่องกรอกชื่อผู้ใช้งาน
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'ชื่อผู้ใช้งาน',
                    filled: true,
                    fillColor: const Color.fromARGB(255, 228, 225, 225),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ช่องกรอกรหัสผ่าน
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'รหัสผ่าน',
                    filled: true,
                    fillColor: const Color.fromARGB(255, 228, 225, 225),
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _goForgot,
                    child: const Text(
                      'ลืมรหัสผ่าน?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 11, 207, 177),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 1, 192, 170),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'เข้าสู่ระบบ',
                      style: GoogleFonts.poppins(
                        fontSize: 14, // 👈 ลดขนาดตัวอักษรให้สมดุล
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
