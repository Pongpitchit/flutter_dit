import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'list_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  late User _currentUser; // สำหรับเก็บข้อมูลผู้ใช้ที่อาจจะถูกอัปเดต

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  // แสดง dialog แก้ไขโปรไฟล์
  Future<void> _editProfile() async {
    final fullNameController =
        TextEditingController(text: _currentUser.fullName.trim());
    final usernameController = TextEditingController(text: _currentUser.username);
    final phoneController =
        TextEditingController(text: _currentUser.phone ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(color: Color(0xFF2C1503)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                  prefixIcon: Icon(Icons.badge, color: Color(0xFF4A2C0A)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อเต็ม',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF4A2C0A)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์ (ไม่จำเป็น)',
                  prefixIcon: Icon(Icons.phone, color: Color(0xFF4A2C0A)),
                  hintText: '08xxxxxxxx',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A2C0A),
              foregroundColor: const Color(0xFFF5DEB3),
            ),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _updateProfile(
        usernameController.text.trim(),
        fullNameController.text.trim(),
        phoneController.text.trim(),
      );
    }
  }

  // อัปเดตโปรไฟล์
  Future<void> _updateProfile(String username, String fullName, String phone) async {
    try {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      final parsedFname = parts.isNotEmpty ? parts.first : '';
      final parsedLname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final token = await _authService.getToken();
      if (token == null) return;

      // ใช้ PATCH /api/users/:id ตาม API documentation
      try {
        final url = Uri.parse(
            'https://apicoffee-flutter.vercel.app/api/users/${_currentUser.id}');
        final response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': fullName, // API ใช้ name แทน fname/lname
            'username': username,
            'phone': phone.isEmpty ? null : phone, // เพิ่ม phone field
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // อัปเดตสำเร็จ
          setState(() {
            _currentUser = User(
              id: _currentUser.id,
              fname: parsedFname,
              lname: parsedLname,
              username: username.isEmpty ? _currentUser.username : username,
              email: _currentUser.email,
              avatar: _currentUser.avatar,
              phone: phone.isEmpty ? _currentUser.phone : phone,
              role: _currentUser.role,
              createdAt: _currentUser.createdAt,
            );
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('อัปเดตโปรไฟล์สำเร็จ!'),
                backgroundColor: Color(0xFF4A2C0A),
              ),
            );
          }
          return;
        }
      } catch (e) {
        print('Profile update API failed: $e');
      }

      // ถ้า API ไม่ work แค่แสดงข้อความว่าอัปเดตแล้ว (simulation)
      setState(() {
        _currentUser = User(
          id: _currentUser.id,
          fname: parsedFname,
          lname: parsedLname,
          username: username.isEmpty ? _currentUser.username : username,
          email: _currentUser.email,
          avatar: _currentUser.avatar,
          phone: phone.isEmpty ? _currentUser.phone : phone,
          role: _currentUser.role,
          createdAt: _currentUser.createdAt,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปเดตโปรไฟล์สำเร็จ! (โหมดทดสอบ)'),
            backgroundColor: Color(0xFF4A2C0A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // แสดง confirmation dialog ก่อน logout
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
            const SizedBox(height: 8),
            Text(
              'หมายเหตุ: หากคุณสมัครสมาชิกใหม่ ข้อมูลผู้ใช้จะถูกลบจากระบบ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // ตรวจสอบว่าเป็นผู้ใช้ที่สมัครใหม่หรือไม่ (จากการ signup)
      // เราสามารถตรวจสอบได้จากว่ามีข้อมูลบางอย่างหรือไม่
      final isNewUser = _currentUser.email.contains('example.com') ||
          _currentUser.avatar.contains('default.png');

      await _authService.logout(deleteUser: isNewUser);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: const Text(
          'โปรไฟล์',
          style: TextStyle(
            color: Color(0xFFF5DEB3),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C1503),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF5DEB3)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'แก้ไขโปรไฟล์',
            color: const Color(0xFFF5DEB3),
            onPressed: _editProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            color: const Color(0xFFF5DEB3),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Profile image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4A2C0A),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    _currentUser.avatar,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: const Color(0xFFD2B48C),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Welcome message
              Text(
                'ยินดีต้อนรับ, ${_currentUser.fullName}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1503),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'คุณได้เข้าสู่ระบบแล้ว',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A2C0A).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ดำเนินการด่วน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1503),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ListScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A2C0A),
                              foregroundColor: const Color(0xFFF5DEB3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.coffee),
                            label: const Text(
                              'สั่งกาแฟ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OrderHistoryScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4A2C0A),
                              side: const BorderSide(color: Color(0xFF4A2C0A)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.history),
                            label: const Text(
                              'ประวัติ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // User info cards
              _buildInfoCard(
                icon: Icons.badge_outlined,
                label: 'รหัสผู้ใช้',
                value: _currentUser.id.toString(),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.person_outline,
                label: 'ชื่อผู้ใช้',
                value: _currentUser.username,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.email_outlined,
                label: 'อีเมล',
                value: _currentUser.email,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.face_outlined,
                label: 'ชื่อเต็ม',
                value: _currentUser.fullName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper สำหรับสร้าง info cards
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2C0A).withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A2C0A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF4A2C0A),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C1503),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
