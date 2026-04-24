import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key สำหรับ validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers สำหรับ input fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Auth service instance
  final AuthService _authService = AuthService();

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    // ล้าง controllers เมื่อ widget ถูกลบ
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // เรียกเมื่อปุ่ม login ถูกกด
  Future<void> _login() async {
    // ขั้นตอนที่ 1: ตรวจสอบฟอร์ม
    if (_formKey.currentState!.validate()) {
      // ขั้นตอนที่ 2: แสดง loading indicator
      setState(() {
        _isLoading = true;
      });

      // ขั้นตอนที่ 3: เรียก auth service
      final response = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // ขั้นตอนที่ 4: ซ่อน loading indicator
      setState(() {
        _isLoading = false;
      });

      // ขั้นตอนที่ 5: จัดการ response
      if (response.isValid) {
        // สำเร็จ! ไปยังหน้า home screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(user: response.user!),
            ),
          );
        }
      } else {
        // ล้มเหลว! แสดง error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: const Text(
          'เข้าสู่ระบบ',
          style: TextStyle(
            color: Color(0xFFF5DEB3),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C1503),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF5DEB3)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Coffee icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2C0A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.coffee,
                      size: 80,
                      color: Color(0xFF4A2C0A),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Welcome text
                  const Text(
                    'Thai Coffee House',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1503),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ยินดีต้อนรับกลับมา',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'เข้าสู่ระบบเพื่อสั่งกาแฟของคุณ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'ชื่อผู้ใช้อีเมล',
                      hintText: 'กรอกชื่อผู้ใช้อีเมลของคุณ',
                      prefixIcon: const Icon(Icons.person_outline,
                          color: Color(0xFF4A2C0A)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A2C0A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF4A2C0A), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกอีเมลหรือชื่อผู้ใช้';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      hintText: 'กรอกรหัสผ่านของคุณ',
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFF4A2C0A)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A2C0A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF4A2C0A), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      if (value.length < 6) {
                        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2C0A),
                        foregroundColor: const Color(0xFFF5DEB3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFF5DEB3),
                              ),
                            )
                          : const Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Demo credentials hint
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2C0A).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4A2C0A).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ข้อมูลสำหรับทดสอบ:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ชื่อผู้ใช้: example@gmail.com \nรหัสผ่าน: password',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Signup link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ยังไม่มีบัญชี?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'สมัครสมาชิก',
                          style: TextStyle(
                            color: Color(0xFF4A2C0A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
