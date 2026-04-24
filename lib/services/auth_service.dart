import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://apicoffee-flutter.vercel.app';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  Future<LoginResponse> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': username, // API ใช้ email แทน username
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        // สร้าง User object จากข้อมูลที่ API ส่งกลับ
        final user = User(
          id: data['user']['id'],
          fname: data['user']['name'].split(' ')[0], // แยก fname จาก name
          lname: data['user']['name'].split(' ').length > 1
              ? data['user']['name'].split(' ').sublist(1).join(' ')
              : '', // แยก lname จาก name
          username: data['user']['email'], // ใช้ email เป็น username
          email: data['user']['email'],
          avatar: data['user']['avatar_url'] ?? '',
          phone: data['user']['phone'],
          role: data['user']['role'],
          createdAt: data['user']['created_at'],
        );

        // บันทึก accessToken และ refreshToken
        await saveToken(data['accessToken']);
        await saveRefreshToken(data['refreshToken']);

        return LoginResponse(
          status: 'ok',
          message: 'Login successful',
          user: user,
          accessToken: data['accessToken'],
        );
      }

      // จัดการ error responses
      final errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? 'Login failed';

      if (response.statusCode == 400) {
        return LoginResponse(
          status: 'error',
          message: 'กรุณากรอกอีเมลและรหัสผ่าน',
        );
      } else if (response.statusCode == 401) {
        return LoginResponse(
          status: 'error',
          message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
        );
      }
      return LoginResponse(status: 'error', message: message);
    } catch (e) {
      return LoginResponse(
        status: 'error',
        message: 'Connection error. Please check your internet',
      );
    }
  }

  // ─── SIGN UP ──────────────────────────────────────────────────────────────
  Future<LoginResponse> signUp({
    required String username,
    required String password,
    required String fname,
    required String lname,
    required String email,
    required String avatar,
  }) async {
    try {
      // ลอง deployed API ก่อน
      try {
        final url = Uri.parse('$baseUrl/api/auth/register');

        final body = jsonEncode({
          'name': '$fname $lname', // API ใช้ name แทน fname/lname
          'email': email, // API ใช้ email ในการสมัคร
          'password': password,
          'avatar_url': avatar.isEmpty ? null : avatar, // API ใช้ avatar_url
        });

        print('Register URL: $url');
        print('Register Body: $body');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        print('Register Response Status: ${response.statusCode}');
        print('Register Response Body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);

          // สร้าง User object จากข้อมูลที่ API ส่งกลับ
          final user = User(
            id: data['user']['id'],
            fname: data['user']['name'].split(' ')[0],
            lname: data['user']['name'].split(' ').length > 1
                ? data['user']['name'].split(' ').sublist(1).join(' ')
                : '',
            username: data['user']['email'],
            email: data['user']['email'],
            avatar: data['user']['avatar_url'] ?? avatar,
            phone: data['user']['phone'],
            role: data['user']['role'],
            createdAt: data['user']['created_at'],
          );

          // บันทึก accessToken และ refreshToken
          if (data.containsKey('accessToken')) {
            await saveToken(data['accessToken']);
            await saveRefreshToken(data['refreshToken']);

            return LoginResponse(
              status: 'ok',
              message: 'Registration successful',
              user: user,
              accessToken: data['accessToken'],
            );
          } else {
            // ถ้าไม่มี token ใน register response ให้ล็อกอินทันที
            return await login(email, password);
          }
        }
      } catch (e) {
        print('Deployed API failed: $e');
      }

      // ถ้า deployed API ไม่ work ให้แสดงข้อความแจ้งว่าต้องแก้ไข server
      return LoginResponse(
        status: 'error',
        message:
            'API server database connection error. Please contact administrator to fix database configuration.',
      );
    } catch (e) {
      return LoginResponse(
        status: 'error',
        message: 'Connection error. Please check your internet',
      );
    }
  }

  // ─── TOKEN HELPERS ────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // ─── DELETE USER FROM API ─────────────────────────────────────────────────
  // ⚠️ ฟังก์ชันนี้ "ลบ user ออกจาก API จริงๆ" (ไม่ใช่แค่ logout)
  // จะเรียกใช้ก็ต่อเมื่อ deleteUser: true เท่านั้น
  Future<bool> _deleteUserFromApi() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/api/users/account');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  // ─── LOGOUT ───────────────────────────────────────────────────────────────
  // logout ปกติ → deleteUser: false  (แค่ลบ token ในเครื่อง, user ยังอยู่ใน API)
  // ลบบัญชี    → deleteUser: true   (ลบ user ออกจาก API ด้วย)
  Future<void> logout({bool deleteUser = false}) async {
    if (deleteUser) {
      await _deleteUserFromApi(); // ลบ user จาก API
    }
    // ลบ token ออกจากเครื่องเสมอ (ทั้ง 2 กรณี)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
