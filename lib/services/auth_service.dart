import 'package:bcrypt/bcrypt.dart';

// บริการสำหรับ hash และตรวจสอบรหัสผ่าน (ใช้ bcrypt)
class AuthService {
  // สร้าง hash ของรหัสผ่าน (ใช้ gensalt ของ bcrypt)
  static String hashPassword(String plain) {
    return BCrypt.hashpw(plain, BCrypt.gensalt());
  }

  // ตรวจสอบรหัสผ่านว่าตรงกับ hash หรือไม่
  static bool verifyPassword(String plain, String hash) {
    try {
      return BCrypt.checkpw(plain, hash);
    } catch (e) {
      return false;
    }
  }
}
