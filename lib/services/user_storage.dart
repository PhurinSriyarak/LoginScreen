import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_model.dart';
import 'auth_service.dart';

/// บริการอ่าน/เขียนไฟล์ users.json ใน Application Documents
class UserStorage {
  static const _fileName = 'users.json';

  // path ไฟล์ในเครื่อง
  static Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // โหลด users ทั้งหมด
  static Future<List<UserModel>> loadUsers() async {
    final file = await _localFile();
    try {
      if (!await file.exists()) {
        await file.writeAsString(jsonEncode({'users': []}), flush: true);
      }
      final contents = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(contents);
      final List users = data['users'] ?? [];
      return users
          .map((u) => UserModel.fromMap(u as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // หาก JSON พัง/อ่านไม่ได้: สำรองไฟล์เดิม (ถ้ามี) แล้วรีเซ็ตโครงสร้าง
      try {
        if (await file.exists()) {
          final backup = File(
            '${file.path}.bad_${DateTime.now().millisecondsSinceEpoch}',
          );
          await file.rename(backup.path);
        }
        await file.writeAsString(jsonEncode({'users': []}), flush: true);
      } catch (_) {
        // กลืน error ระดับไฟล์ไว้เพื่อไม่ให้แอปล่ม
      }
      return [];
    }
  }

  // บันทึก users ทั้งหมด (atomic write)
  static Future<void> saveUsers(List<UserModel> users) async {
    final file = await _localFile();
    final tmp = File('${file.path}.tmp');
    final data = {'users': users.map((u) => u.toMap()).toList()};
    try {
      await tmp.writeAsString(jsonEncode(data), flush: true);
      await tmp.rename(file.path);
    } catch (e) {
      // อย่างน้อยบันทึกผิดพลาดจะไม่ทำให้ไฟล์หลักเสีย
      // สามารถโยนหรือ log ได้ตามต้องการ
    }
  }

  // หา user ตาม username
  static Future<UserModel?> getUserByUsername(String username) async {
    final users = await loadUsers();
    try {
      return users.firstWhere((u) => u.username == username);
    } catch (_) {
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

  // dev-only: สร้างตัวอย่าง user ถ้ายังไม่มี — สำหรับทดสอบ
  static Future<void> ensureSampleUser() async {
    if (!kDebugMode) return; // จำกัดเฉพาะ debug
    final users = await loadUsers();
    final exists = users.any((u) => u.username == 'admin');
    if (!exists) {
      final sample = UserModel(
        username: 'admin',
        email: 'admin@example.com',
        phone: '0812345678',
        passwordHash: AuthService.hashPassword('1234'),
      );
      users.add(sample);
      await saveUsers(users);
    }
  }
}
