import 'package:flutter/material.dart';
import '../models/coffee.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';

class DetailScreen extends StatefulWidget {
  final Coffee coffee;

  const DetailScreen({super.key, required this.coffee});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    await CartService.instance.loadCart();
    setState(() {
      _cartItemCount = CartService.instance.itemCount;
    });
  }

  Future<void> _addToCart() async {
    await CartService.instance.addToCart(widget.coffee);
    setState(() {
      _cartItemCount = CartService.instance.itemCount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เพิ่ม "${widget.coffee.name}" ลงตะกร้าแล้ว!'),
        backgroundColor: const Color(0xFF4A2C0A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2C1503),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(widget.coffee.category);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF2C1503),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  ).then((_) => _loadCartCount());
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white),
                      if (_cartItemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _cartItemCount > 9 ? '9+' : '$_cartItemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.coffee.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF4A2C0A),
                      child: const Icon(Icons.coffee,
                          size: 100, color: Colors.white30),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  // ID badge
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ID: ${widget.coffee.id}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                widget.coffee.category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.coffee.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C1503),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A2C0A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'ราคา',
                              style: TextStyle(
                                color: Color(0xFFD2B48C),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '฿${widget.coffee.priceDisplay}',
                              style: const TextStyle(
                                color: Color(0xFFF5DEB3),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2C0A).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF4A2C0A).withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.format_quote,
                              color: Color(0xFF6B3A1F),
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'รายละเอียด',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.coffee.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF3D2006),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'ข้อมูลสินค้า',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1503),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 6 Fields info rows
                  _infoRow(Icons.tag, 'รหัสสินค้า (ID)',
                      widget.coffee.id.toString(), const Color(0xFF795548)),
                  _infoRow(Icons.coffee, 'ชื่อเมนู (Name)', widget.coffee.name,
                      const Color(0xFF6B3A1F)),
                  _infoRow(
                      Icons.attach_money,
                      'ราคา (Price)',
                      '฿${widget.coffee.priceDisplay} บาท',
                      const Color(0xFF4A7C59)),
                  _infoRow(Icons.category, 'หมวดหมู่ (Category)',
                      widget.coffee.category, categoryColor),
                  _infoRow(Icons.description, 'คำอธิบาย (Description)',
                      widget.coffee.description, const Color(0xFF8B4513)),
                  _infoRow(
                      Icons.image,
                      'รูปภาพ (Image)',
                      widget.coffee.image.length > 50
                          ? '${widget.coffee.image.substring(0, 50)}...'
                          : widget.coffee.image,
                      const Color(0xFFD2691E)),

                  const SizedBox(height: 30),

                  // Order button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2C0A),
                        foregroundColor: const Color(0xFFF5DEB3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text(
                        'สั่งเมนูนี้',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
