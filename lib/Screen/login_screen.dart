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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initSample(); // dev: สร้าง sample user ทดสอบ
  }

  Future<void> _initSample() async {
    await UserStorage.ensureSampleUser();
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _login() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')));
      setState(() => _isSubmitting = false);
      return;
    }

    final user = await UserStorage.getUserByUsername(username);
    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบผู้ใช้งาน')));
      setState(() => _isSubmitting = false);
      return;
    }

    final ok = AuthService.verifyPassword(password, user.passwordHash);
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เข้าสู่ระบบสำเร็จ ✅')));
      if (!mounted) return;
      // ล้าง stack แล้วไปหน้า Home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รหัสผ่านไม่ถูกต้อง ❌')));
      setState(() => _isSubmitting = false);
    }
  }

  void _goForgot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

                Text(
                  "ลงชื่อเข้าสู่ระบบ",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 11, 207, 177),
                  ),
                ),
                const SizedBox(height: 20),

                // ชื่อผู้ใช้งาน
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

                // รหัสผ่าน
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
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
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
                    onPressed: _isSubmitting ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 1, 192, 170),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isSubmitting ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
