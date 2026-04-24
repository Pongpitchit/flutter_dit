class Coffee {
  final int id; // API คืน int (AUTO_INCREMENT)
  final String name;
  final double price; // API คืน DECIMAL → double
  final String category;
  final String description;
  final String image;
  final String? createdAt;

  Coffee({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.image,
    this.createdAt,
  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      // id จาก Express API เป็น int เสมอ
      id: (json['id'] as num).toInt(),
      name: json['name'] ?? '',
      // price จาก TiDB DECIMAL อาจมาเป็น String "45.00" หรือ num
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      image: (json['image_url'] ?? json['image'] ?? '').toString(),
      createdAt: json['created_at'],
    );
  }

  // แสดงราคาแบบไม่มีทศนิยมถ้าเป็นจำนวนเต็ม
  String get priceDisplay => price == price.truncateToDouble()
      ? price.toInt().toString()
      : price.toStringAsFixed(2);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'image': image,
      'image_url': image,
      'created_at': createdAt,
    };
  }
}
