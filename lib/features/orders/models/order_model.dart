import 'package:ecommerce_app/features/auth/models/product_model.dart';

class Order {
  final String id;
  final List<Product> products;
  final String customerName;
  final String phone;
  final String wilaya;
  final String status;
  final DateTime date;

  Order({
    required this.id,
    required this.products,
    required this.customerName,
    required this.phone,
    required this.wilaya,
    this.status = 'قيد الانتظار',
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final products = itemsJson.map((item) {
      final m = item as Map<String, dynamic>;
      return Product(
        id: m['product_id'].toString(),
        title: m['title'] as String,
        describe: '',
        price: (m['price'] as num).toDouble(),
        images: m['image'] != null ? [m['image'] as String] : <String>[],
      );
    }).toList();

    return Order(
      id: json['id'].toString(),
      products: products,
      customerName: json['customer_name'] as String,
      phone: json['phone'] as String,
      wilaya: json['wilaya'] as String,
      status: json['status'] as String? ?? 'قيد الانتظار',
      date: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'customer_name': customerName,
        'phone': phone,
        'wilaya': wilaya,
        'items': products
            .map((p) => {
                  'product_id': int.tryParse(p.id) ?? 0,
                  'title': p.title,
                  'price': p.price,
                  'image': p.images.isNotEmpty ? p.images.first : null,
                })
            .toList(),
      };
}
