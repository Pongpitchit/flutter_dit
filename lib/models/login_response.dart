import 'user.dart';

class LoginResponse {
  final String status; // 'ok' or 'error'
  final String message; // ข้อความสำเร็จ/ข้อความผิดพลาด
  final String? accessToken; // JWT token (nullable = สามารถเป็น null ได้)
  final User? user; // ข้อมูลผู้ใช้ถ้า login สำเร็จ

  LoginResponse({
    required this.status,
    required this.message,
    this.accessToken,
    this.user,
  });

  // แปลง JSON response เป็น LoginResponse object
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
      accessToken: json['accessToken'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  // วิธีรวดเร็วในการตรวจสอบว่า login สำเร็จหรือไม่
  bool get isValid => status == 'ok' && accessToken != null && user != null;
}
