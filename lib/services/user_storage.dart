import 'dart:io';
import 'dart:convert';
import 'package:flutter_login_screen/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';

// บริการอ่าน/เขียนไฟล์ users.json ใน Application Documents
class UserStorage {
  // ชื่อไฟล์
  static const _fileName = 'users.json';

  // คืนค่าไฟล์ path ในเครื่อง
  static Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // โหลดข้อมูล users ทั้งหมด (คืนค่าเป็น List<UserModel>)
  static Future<List<UserModel>> loadUsers() async {
    try {
      final file = await _localFile();
      if (!await file.exists()) {
        // ถ้าไฟล์ยังไม่มี ให้สร้างโครงสร้างเริ่มต้น
        await file.writeAsString(jsonEncode({'users': []}));
      }
      final contents = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(contents);
      final List users = data['users'] ?? [];
      return users.map((u) => UserModel.fromMap(u)).toList();
    } catch (e) {
      // ถ้าโหลดไม่ได้ ให้คืนค่า empty list
      return [];
    }
  }

  // บันทึกรายชื่อ users ทั้งหมด (รับ List<UserModel>)
  static Future<void> saveUsers(List<UserModel> users) async {
    final file = await _localFile();
    final data = {'users': users.map((u) => u.toMap()).toList()};
    await file.writeAsString(jsonEncode(data));
  }

  // หา user ตาม username
  static Future<UserModel?> getUserByUsername(String username) async {
    final users = await loadUsers();
    try {
      return users.firstWhere((u) => u.username == username);
    } catch (e) {
      return null;
    }
  }

  // เพิ่ม user ใหม่ (ถ้า username ซ้ำ จะคืน false)
  static Future<bool> addUser(UserModel user) async {
    final users = await loadUsers();
    final exists = users.any((u) => u.username == user.username);
    if (exists) return false;
    users.add(user);
    await saveUsers(users);
    return true;
  }

  // อัปเดตรหัสผ่าน (โดยใช้ username)
  static Future<bool> resetPassword(String username, String newHash) async {
    final users = await loadUsers();
    final idx = users.indexWhere((u) => u.username == username);
    if (idx == -1) return false;
    users[idx].passwordHash = newHash;
    await saveUsers(users);
    return true;
  }

  // (ตัวช่วย) สร้างตัวอย่าง user ถ้ายังไม่มี — สำหรับทดสอบ
  static Future<void> ensureSampleUser() async {
    final users = await loadUsers();
    final exists = users.any((u) => u.username == 'admin');
    if (!exists) {
      final sample = UserModel(
        username: 'admin',
        email: 'admin@example.com',
        phone: '0812345678',
        passwordHash: AuthService.hashPassword('1234'), // รหัสตัวอย่าง 1234
      );
      users.add(sample);
      await saveUsers(users);
    }
  }
}
