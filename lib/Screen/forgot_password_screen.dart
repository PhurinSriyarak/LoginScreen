import 'dart:math';
import 'package:flutter/material.dart';
import '../services/user_storage.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

  String? _generatedOtp;
  DateTime? _otpIssuedAt;
  bool _otpSent = false;
  bool _showNewPasswordFields = false;
  bool _isPasswordVisible = false; // toggle แสดง/ซ่อนรหัสผ่าน

  // สร้าง OTP จำลอง (ในระบบจริงต้องส่งผ่าน SMS/Email)
  String _generateOtp() {
    final rand = Random.secure(); // ปลอดภัยกว่า Random()
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  bool _isOtpExpired() {
    if (_otpIssuedAt == null) return true;
    final diff = DateTime.now().difference(_otpIssuedAt!);
    return diff.inMinutes >= 5; // หมดอายุใน 5 นาที
  }

  Future<void> _requestOtp() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกชื่อผู้ใช้งาน')));
      return;
    }

    final user = await UserStorage.getUserByUsername(username);
    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบผู้ใช้งาน')));
      return;
    }

    // สร้าง OTP และ "ส่ง" (ตัวอย่าง: แสดงเป็น dialog เพื่อทดลอง)
    _generatedOtp = _generateOtp();
    _otpIssuedAt = DateTime.now();
    _otpSent = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('OTP จำลอง (เพื่อทดสอบ)'),
        content: Text(
          'รหัส OTP ของคุณคือ: $_generatedOtp\n(ในระบบจริงจะส่งทาง SMS หรืออีเมล)\nหมดอายุใน 5 นาที',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showNewPasswordFields = true;
              });
            },
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitNewPassword() async {
    final username = _usernameController.text.trim();
    final otp = _otpController.text.trim();
    final newPass = _newPassController.text;

    if (username.isEmpty || otp.isEmpty || newPass.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')));
      return;
    }

    if (!_otpSent || _generatedOtp == null || _isOtpExpired()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP ไม่ถูกต้องหรือหมดอายุ กรุณาขอใหม่')),
      );
      return;
    }

    if (otp != _generatedOtp) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รหัส OTP ไม่ถูกต้อง')));
      return;
    }

    // OTP ถูกต้อง → hash รหัสผ่านใหม่แล้วบันทึกลง storage
    final newHash = AuthService.hashPassword(newPass);
    final ok = await UserStorage.resetPassword(username, newHash);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')));
      // เคลียร์ OTP ทิ้ง
      setState(() {
        _generatedOtp = null;
        _otpIssuedAt = null;
        _otpSent = false;
        _showNewPasswordFields = false;
        _otpController.clear();
        _newPassController.clear();
      });
      Navigator.pop(context); // กลับหน้า login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _otpController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008080), // สีพื้นหลัง
      appBar: AppBar(
        backgroundColor: Colors.transparent, // โปร่งใส
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.lock_reset,
                  size: 60,
                  color: Color(0xFF008080),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'กู้คืนรหัสผ่าน',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),

              _buildTextField(
                controller: _usernameController,
                label: 'ชื่อผู้ใช้งาน',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF008080),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ขอรหัส OTP',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (_showNewPasswordFields) ...[
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _otpController,
                  label: 'รหัส OTP',
                  prefixIcon: Icons.dialpad,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _newPassController,
                  label: 'รหัสผ่านใหม่',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitNewPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF008080),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ยืนยันเปลี่ยนรหัสผ่าน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper สำหรับสร้าง TextField ที่มีสไตล์
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E8B57),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(prefixIcon, color: Colors.white),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
