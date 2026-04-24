import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Map<String, dynamic>> _orders = <Map<String, dynamic>>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบ token การเข้าสู่ระบบ');
      }

      final response = await http.get(
        Uri.parse('https://apicoffee-flutter.vercel.app/api/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('โหลดประวัติไม่สำเร็จ (${response.statusCode})');
      }

      final dynamic payload = jsonDecode(response.body);
      List<dynamic> rawOrders = <dynamic>[];
      if (payload is List) {
        rawOrders = payload;
      } else if (payload is Map<String, dynamic>) {
        if (payload['data'] is List) {
          rawOrders = payload['data'] as List<dynamic>;
        } else if (payload['orders'] is List) {
          rawOrders = payload['orders'] as List<dynamic>;
        }
      }

      final parsed = rawOrders
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (!mounted) return;
      setState(() {
        _orders = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _statusText(dynamic status) {
    final value = status?.toString().toLowerCase() ?? '';
    switch (value) {
      case 'paid':
      case 'completed':
        return 'ชำระแล้ว';
      case 'pending':
        return 'รอดำเนินการ';
      case 'cancelled':
      case 'canceled':
        return 'ยกเลิก';
      default:
        return value.isEmpty ? 'ไม่ระบุสถานะ' : value;
    }
  }

  Color _statusColor(dynamic status) {
    final value = status?.toString().toLowerCase() ?? '';
    switch (value) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  double _asDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  List<dynamic> _extractItems(Map<String, dynamic> order) {
    final candidates = <dynamic>[
      order['items'],
      order['order_items'],
      order['details'],
      order['products'],
    ];
    for (final candidate in candidates) {
      if (candidate is List) return candidate;
    }
    return <dynamic>[];
  }

  double _calculateTotalFromItems(Map<String, dynamic> order) {
    final items = _extractItems(order);
    if (items.isEmpty) return 0.0;

    double sum = 0.0;
    for (final rawItem in items) {
      if (rawItem is! Map) continue;
      final item = Map<String, dynamic>.from(rawItem);
      final quantity = _asDouble(
        item['quantity'] ?? item['qty'] ?? item['count'] ?? item['amount'],
      );
      final unitPrice = _asDouble(
        item['unit_price'] ??
            item['price'] ??
            item['coffee_price'] ??
            item['subtotal'],
      );

      // If backend already gives subtotal per item, use it directly.
      final lineTotal = _asDouble(item['line_total'] ?? item['total'] ?? item['subtotal']);
      if (lineTotal > 0) {
        sum += lineTotal;
      } else {
        sum += unitPrice * (quantity <= 0 ? 1 : quantity);
      }
    }
    return sum;
  }

  String _formatTotal(Map<String, dynamic> order) {
    final directTotal = _asDouble(
      order['total_amount'] ??
          order['grand_total'] ??
          order['total_price'] ??
          order['total'] ??
          order['amount'],
    );
    final value = directTotal > 0 ? directTotal : _calculateTotalFromItems(order);
    return value.toStringAsFixed(2);
  }

  String _orderCode(Map<String, dynamic> order) {
    final id = order['id'] ?? order['order_id'] ?? '-';
    return '#$id';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: const Text(
          'ประวัติการสั่งซื้อ',
          style: TextStyle(
            color: Color(0xFFF5DEB3),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C1503),
        iconTheme: const IconThemeData(color: Color(0xFFF5DEB3)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6B3A1F)),
            SizedBox(height: 16),
            Text(
              'กำลังโหลดประวัติ...',
              style: TextStyle(color: Color(0xFF6B3A1F)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'โหลดประวัติไม่สำเร็จ\n$_error',
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.history, size: 80, color: Color(0xFF6B3A1F)),
          SizedBox(height: 16),
          Center(
            child: Text(
              'ยังไม่มีประวัติการสั่งซื้อ',
              style: TextStyle(color: Color(0xFF6B3A1F), fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final statusColor = _statusColor(order['status']);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _orderCode(order),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1503),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusText(order['status']),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ยอดรวม ฿${_formatTotal(order)}',
                style: const TextStyle(
                  color: Color(0xFF6B3A1F),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (order['note'] != null && order['note'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'หมายเหตุ: ${order['note']}',
                    style: const TextStyle(
                      color: Color(0xFF2C1503),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
