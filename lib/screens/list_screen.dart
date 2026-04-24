import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/coffee.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Coffee> coffees = <Coffee>[];
  bool isLoading = true;
  String? error;
  int _cartItemCount = 0;

  static const String baseUrl = 'https://apicoffee-flutter.vercel.app';
  static const String apiUrl = '$baseUrl/api/coffees';

  @override
  void initState() {
    super.initState();
    fetchCoffees();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    await CartService.instance.loadCart();
    if (!mounted) return;
    setState(() {
      _cartItemCount = CartService.instance.itemCount;
    });
  }

  Future<void> fetchCoffees() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response =
          await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final dynamic data = json.decode(response.body);
      List<dynamic> coffeesData = <dynamic>[];
      if (data is List) {
        coffeesData = data;
      } else if (data is Map<String, dynamic>) {
        if (data['coffees'] is List) {
          coffeesData = data['coffees'] as List<dynamic>;
        } else if (data['data'] is List) {
          coffeesData = data['data'] as List<dynamic>;
        } else if (data['record'] is Map<String, dynamic> &&
            (data['record'] as Map<String, dynamic>)['coffees'] is List) {
          coffeesData =
              (data['record'] as Map<String, dynamic>)['coffees'] as List<dynamic>;
        }
      }

      if (coffeesData.isEmpty) {
        throw Exception('API response format is invalid or empty');
      }

      if (!mounted) return;
      setState(() {
        coffees = coffeesData
            .whereType<Map>()
            .map((e) => Coffee.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        isLoading = false;
      });
      await _loadCartCount();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Classic':
        return const Color(0xFF6B3A1F);
      case 'Latte':
        return const Color(0xFFB5651D);
      case 'Matcha':
        return const Color(0xFF4A7C59);
      case 'Special':
        return const Color(0xFF8B4513);
      case 'Chocolate':
        return const Color(0xFF7B3F00);
      case 'Thai Fusion':
        return const Color(0xFFD2691E);
      default:
        return const Color(0xFF795548);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: const Text(
          'เมนูกาแฟพรีเมียม',
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
            icon: const Icon(Icons.person_outline),
            tooltip: 'โปรไฟล์',
            color: const Color(0xFFF5DEB3),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ไม่พบหน้าโปรไฟล์ก่อนหน้า'),
                  backgroundColor: Color(0xFF4A2C0A),
                ),
              );
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _cartItemCount > 0,
              label: Text('$_cartItemCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            tooltip: 'ตะกร้า',
            color: const Color(0xFFF5DEB3),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
              await _loadCartCount();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchCoffees,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6B3A1F)),
            SizedBox(height: 16),
            Text('กำลังโหลดเมนู...',
              style: TextStyle(color: Color(0xFF6B3A1F))),
          ],
        ),
      );
    }

    if (error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เชื่อมต่อ API ไม่สำเร็จ',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (coffees.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.coffee_outlined, size: 80, color: Color(0xFF6B3A1F)),
                SizedBox(height: 16),
                Text(
                  'ไม่มีข้อมูลกาแฟพรีเมียม',
                  style: TextStyle(color: Color(0xFF6B3A1F)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C1503),
                  Color(0xFF6B3A1F),
                  Color(0xFF4A2C0A),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thai Coffee House',
                    style: TextStyle(
                      color: Color.fromARGB(255, 234, 194, 141),
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  Text(
                    '6607263 | พงศ์พิชิต สิทธิภักดี',
                    style: TextStyle(
                      color: Color(0xFFD2B48C),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final coffee = coffees[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(coffee: coffee),
                      ),
                    );
                  },
                  child: Container(
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
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            coffee.image,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 140,
                              color: const Color(0xFFD2B48C),
                              child: const Icon(Icons.coffee,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _categoryColor(coffee.category)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  coffee.category,
                                  style: TextStyle(
                                    color: _categoryColor(coffee.category),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                coffee.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C1503),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '฿${coffee.priceDisplay}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B3A1F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: coffees.length,
            ),
          ),
        ),
      ],
    );
  }
}
