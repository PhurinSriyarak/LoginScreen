import 'package:bcrypt/bcrypt.dart';

/// บริการสำหรับ hash และตรวจสอบรหัสผ่าน (ใช้ bcrypt)
class AuthService {
  // NOTE: ในโปรดักชัน แนะนำเพิ่ม pepper จาก secure storage มาต่อท้าย plain ก่อน hash/check
  // เช่น final pepper = await Secure.read('pepper'); แล้วใช้ '$plain$pepper'

  /// สร้าง hash ของรหัสผ่าน (ใช้ gensalt ของ bcrypt)
  static String hashPassword(String plain) {
    return BCrypt.hashpw(plain, BCrypt.gensalt());
  }

  /// ตรวจสอบรหัสผ่านว่าตรงกับ hash หรือไม่
  static bool verifyPassword(String plain, String hash) {
    try {
      return BCrypt.checkpw(plain, hash);
    } catch (_) {
      return false;
    }
  }
}
