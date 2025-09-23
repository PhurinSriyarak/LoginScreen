// โมเดลข้อมูลผู้ใช้ที่เราจะเก็บลงไฟล์ JSON
class UserModel {
  String username;
  String email;
  String phone;
  String passwordHash; // เก็บเฉพาะ hash เท่านั้น

  UserModel({
    required this.username,
    required this.email,
    required this.phone,
    required this.passwordHash,
  });

  // แปลงเป็น map เพื่อเขียนลง JSON
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
    };
  }

  // สร้างจาก map ที่อ่านมาจาก JSON
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
    );
  }
}
