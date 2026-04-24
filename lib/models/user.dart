class User {
  final int id;
  final String fname;
  final String lname;
  final String username;
  final String email;
  final String avatar;
  final String? phone;
  final String? role;
  final String? createdAt;

  User({
    required this.id,
    required this.fname,
    required this.lname,
    required this.username,
    required this.email,
    required this.avatar,
    this.phone,
    this.role,
    this.createdAt,
  });

  // แปลง JSON จาก API เป็น User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fname: json['fname'] ?? json['name']?.split(' ')[0] ?? '',
      lname: json['lname'] ??
          (json['name']?.split(' ').length > 1
              ? json['name']?.split(' ').sublist(1).join(' ')
              : '') ??
          '',
      username: json['username'] ?? json['email'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? json['avatar_url'] ?? '',
      phone: json['phone'],
      role: json['role'],
      createdAt: json['created_at'],
    );
  }

  // Helper สำหรับแสดงชื่อเต็มได้ง่ายๆ
  String get fullName => '$fname $lname';

  // Helper สำหรับแสดงข้อมูล role เป็นภาษาไทย
  String get displayRole {
    switch (role) {
      case 'admin':
        return 'ผู้ดูแลระบบ';
      case 'customer':
        return 'ลูกค้า';
      default:
        return role ?? 'ลูกค้า';
    }
  }
}
