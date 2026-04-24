import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController(); // ใช้ name เดียวแทน fname/lname
  final _emailController =
      TextEditingController(); // email คือ username ใน API ใหม่
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _avatarController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // ใช้ข้อมูลตาม API ใหม่: name, email, password, avatar_url
    final response = await _authService.signUp(
      username: _emailController.text.trim(), // ใช้ email เป็น username
      password: _passwordController.text,
      fname: _nameController.text.trim(), // ส่ง name เต็มใน fname ชั่วคราว
      lname: '', // ไม่ใช้ lname ใน API ใหม่
      email: _emailController.text.trim(),
      avatar: _avatarController.text.trim().isEmpty
          ? 'https://www.melivecode.com/users/default.png'
          : _avatarController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(user: response.user!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── reusable input field ──────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction inputAction = TextInputAction.next,
    bool obscure = false,
    String? Function(String?)? validator,
    VoidCallback? onSubmit,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF4A2C0A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A2C0A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A2C0A), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      textInputAction: inputAction,
      obscureText: obscure,
      enabled: !_isLoading,
      validator: validator,
      onFieldSubmitted: onSubmit != null ? (_) => onSubmit() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: const Text(
          'สมัครสมาชิก',
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Icon ────────────────────────────────────────────────
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

                  // ── Header ───────────────────────────────────────────────
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
                    'สร้างบัญชีเพื่อสั่งกาแฟของคุณ',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // ── Name ───────────────────────────────────────────────
                  _buildField(
                    controller: _nameController,
                    label: 'ชื่อ-นามสกุล',
                    hint: 'กรอกชื่อและนามสกุลของคุณ',
                    icon: Icons.person_outline,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'กรุณากรอกชื่อ-นามสกุล';
                      if (v.trim().length < 3)
                        return 'ชื่อ-นามสกุลต้องมีอย่างน้อย 3 ตัวอักษร';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Email ────────────────────────────────────────────────
                  _buildField(
                    controller: _emailController,
                    label: 'อีเมล',
                    hint: 'กรอกอีเมลของคุณ',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'กรุณากรอกอีเมล';
                      if (!v.trim().contains('@'))
                        return 'กรุณากรอกอีเมลที่ถูกต้อง';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Avatar (optional) ────────────────────────────────────
                  _buildField(
                    controller: _avatarController,
                    label: 'รูปโปรไฟล์ (URL) - ไม่จำเป็น',
                    hint: 'ปล่อยว่างเพื่อใช้รูป default',
                    icon: Icons.image_outlined,
                  ),
                  const SizedBox(height: 12),

                  // ── Password ─────────────────────────────────────────────
                  _buildField(
                    controller: _passwordController,
                    label: 'รหัสผ่าน',
                    hint: 'กรอกรหัสผ่านของคุณ',
                    icon: Icons.lock_outline,
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                      if (v.length < 6)
                        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Confirm Password ─────────────────────────────────────
                  _buildField(
                    controller: _confirmPasswordController,
                    label: 'ยืนยันรหัสผ่าน',
                    hint: 'กรอกรหัสผ่านอีกครั้ง',
                    icon: Icons.lock_outline,
                    obscure: true,
                    inputAction: TextInputAction.done,
                    onSubmit: _signup,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                      if (v != _passwordController.text)
                        return 'รหัสผ่านไม่ตรงกัน';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Signup button ────────────────────────────────────────
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
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
                              'สมัครสมาชิก',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Login link ───────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'มีบัญชีอยู่แล้ว?',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'เข้าสู่ระบบ',
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
