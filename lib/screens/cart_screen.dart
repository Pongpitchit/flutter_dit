import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });

    await CartService.instance.loadCart();
    setState(() {
      _cartItems = CartService.instance.items;
      _isLoading = false;
    });
  }

  Future<void> _updateQuantity(int coffeeId, int quantity) async {
    await CartService.instance.updateQuantity(coffeeId, quantity);
    setState(() {
      _cartItems = CartService.instance.items;
    });
  }

  Future<void> _removeItem(int coffeeId) async {
    await CartService.instance.removeFromCart(coffeeId);
    setState(() {
      _cartItems = CartService.instance.items;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ลบสินค้าออกจากตะกร้าแล้ว'),
        backgroundColor: const Color(0xFF4A2C0A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _proceedToCheckout() {
    if (_cartItems.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(cartItems: _cartItems),
      ),
    ).then((_) => _loadCart());
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice =
        _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final totalItems = _cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: const Text(
          'ตะกร้าสินค้า',
          style: TextStyle(
            color: Color(0xFFF5DEB3),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C1503),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF5DEB3)),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6B3A1F)),
                  SizedBox(height: 16),
                  Text('กำลังโหลดตะกร้า...',
                      style: TextStyle(color: Color(0xFF6B3A1F))),
                ],
              ),
            )
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ตะกร้าสินค้าว่างเปล่า',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'เพิ่มสินค้าลงในตะกร้าเพื่อเริ่มสั่งซื้อ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2C0A),
                          foregroundColor: const Color(0xFFF5DEB3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('เลือกสินค้าเพิ่ม'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = _cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4A2C0A).withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    cartItem.coffee.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 60,
                                      height: 60,
                                      color: const Color(0xFFD2B48C),
                                      child: const Icon(
                                        Icons.coffee,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.coffee.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C1503),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '฿${cartItem.coffee.priceDisplay}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B3A1F),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A2C0A)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: cartItem.quantity > 1
                                                ? () => _updateQuantity(
                                                      cartItem.coffee.id,
                                                      cartItem.quantity - 1,
                                                    )
                                                : () => _removeItem(
                                                    cartItem.coffee.id),
                                            icon: Icon(
                                              cartItem.quantity > 1
                                                  ? Icons.remove
                                                  : Icons.delete_outline,
                                              color: const Color(0xFF4A2C0A),
                                              size: 20,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                          ),
                                          Container(
                                            width: 40,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${cartItem.quantity}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C1503),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _updateQuantity(
                                              cartItem.coffee.id,
                                              cartItem.quantity + 1,
                                            ),
                                            icon: const Icon(
                                              Icons.add,
                                              color: Color(0xFF4A2C0A),
                                              size: 20,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A2C0A),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รวม ($totalItems รายการ)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2C1503),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '฿${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF2C1503),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _proceedToCheckout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A2C0A),
                                foregroundColor: const Color(0xFFF5DEB3),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'ดำเนินการชำระเงิน',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _tableController = TextEditingController();
  String _orderType = 'delivery'; // 'delivery' or 'dine_in'
  bool _isProcessing = false;

  double get totalPrice =>
      widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalItems =>
      widget.cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Get authentication token
      final token = await AuthService().getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาเข้าสู่ระบบก่อนสั่งซื้อ'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }

      // Prepare order data according to new API schema
      final orderData = {
        'note': _orderType == 'delivery'
            ? 'ส่ง: ${_addressController.text}, เบอร์: ${_phoneController.text}'
            : 'รับที่ร้าน: โต๊ะ ${_tableController.text}',
        'items': widget.cartItems
            .map((item) => {
                  'coffee_id': item.coffee.id,
                  'quantity': item.quantity,
                })
            .toList(),
      };

      // Send to API with authentication
      final response = await http
          .post(
            Uri.parse('https://apicoffee-flutter.vercel.app/api/orders'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(orderData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - clear cart and show success message
        await CartService.instance.clearCart();

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text(
                'การสั่งซื้อสำเร็จ!',
                style: TextStyle(color: Color(0xFF2C1503)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ชื่อ: ${_nameController.text}'),
                  if (_orderType == 'delivery')
                    Text('เบอร์โทร: ${_phoneController.text}'),
                  if (_orderType == 'delivery')
                    Text('ที่อยู่: ${_addressController.text}')
                  else
                    Text('โต๊ะ: ${_tableController.text}'),
                  const SizedBox(height: 8),
                  Text('จำนวน: $totalItems รายการ'),
                  Text('รวม: ฿${totalPrice.toStringAsFixed(2)}'),
                  Text(
                      'ประเภท: ${_orderType == 'delivery' ? 'ส่ง' : 'รับที่ร้าน'}'),
                  const SizedBox(height: 8),
                  Text(
                    'หมายเลขที่การสั่งซื้อ: #${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'ตกลง',
                    style: TextStyle(color: Color(0xFF4A2C0A)),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการส่งออเดอร์: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
          'ชำระเงิน',
          style: TextStyle(
            color: Color(0xFFF5DEB3),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C1503),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF5DEB3)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ข้อมูลการจัดส่ง',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1503),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Order Type Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ประเภทการรับอาหาร',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C1503),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _orderType = 'delivery';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _orderType == 'delivery'
                                        ? const Color(0xFF4A2C0A)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF4A2C0A),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delivery_dining,
                                        color: _orderType == 'delivery'
                                            ? Colors.white
                                            : const Color(0xFF4A2C0A),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ส่ง',
                                        style: TextStyle(
                                          color: _orderType == 'delivery'
                                              ? Colors.white
                                              : const Color(0xFF4A2C0A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _orderType = 'dine_in';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _orderType == 'dine_in'
                                        ? const Color(0xFF4A2C0A)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF4A2C0A),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.store,
                                        color: _orderType == 'dine_in'
                                            ? Colors.white
                                            : const Color(0xFF4A2C0A),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'รับที่ร้าน',
                                        style: TextStyle(
                                          color: _orderType == 'dine_in'
                                              ? Colors.white
                                              : const Color(0xFF4A2C0A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อเล่น',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกชื่อเล่น';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Phone field only for delivery
                    if (_orderType == 'delivery')
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'เบอร์โทรศัพท์',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกเบอร์โทรศัพท์';
                          }
                          if (value.length < 9) {
                            return 'เบอร์โทรศัพท์ต้องมีอย่างน้อย 9 หลัก';
                          }
                          return null;
                        },
                      ),
                    if (_orderType == 'delivery') const SizedBox(height: 16),
                    // Conditional field based on order type
                    if (_orderType == 'delivery')
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'ที่อยู่จัดส่ง',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกที่อยู่จัดส่ง';
                          }
                          return null;
                        },
                      )
                    else
                      TextFormField(
                        controller: _tableController,
                        decoration: const InputDecoration(
                          labelText: 'เลขโต๊ะ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.table_restaurant),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกเลขโต๊ะ';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),
                    const Text(
                      'สรุปคำสั่งซื้อ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1503),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A2C0A).withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ...widget.cartItems.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.coffee.name} x${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2C1503),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '฿${item.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C1503),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'รวมทั้งหมด',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C1503),
                                ),
                              ),
                              Text(
                                '฿${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B3A1F),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2C0A),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C0A),
                    foregroundColor: const Color(0xFFF5DEB3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFF5DEB3),
                            ),
                          ),
                        )
                      : const Text(
                          'ยืนยันการสั่งซื้อ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
