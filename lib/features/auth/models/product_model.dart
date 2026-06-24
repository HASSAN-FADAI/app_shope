class Product {
  final String id;
  final String title;
  final String describe;
  final double price;
  final int categoryId;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.images,
    required this.describe,
    this.categoryId = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      title: json['title'] as String,
      describe: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      categoryId: json['category_id'] as int? ?? 0,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': describe,
        'price': price,
        'category_id': categoryId,
        'images': images,
      };
}
