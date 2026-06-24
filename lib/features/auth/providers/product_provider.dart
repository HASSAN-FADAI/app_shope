import 'package:ecommerce_app/core/error/app_error.dart';
import 'package:ecommerce_app/core/supabase/supabase_client.dart';
import 'package:ecommerce_app/features/auth/models/product_model.dart';
import 'package:flutter/foundation.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  Future<void> fetchProducts() async {
    try {
      final data = await supabase
          .from('products')
          .select('*')
          .order('id', ascending: false);

      _products = data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      AppError.getUserMessage(e);
    }
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      final data = await supabase
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      _products.insert(0, Product.fromJson(data));
    } catch (e) {
      AppError.getUserMessage(e);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> removeProduct(String id) async {
    try {
      await supabase.from('products').delete().eq('id', int.parse(id));

      _products.removeWhere((p) => p.id == id);
    } catch (e) {
      AppError.getUserMessage(e);
      rethrow;
    }
    notifyListeners();
  }
}
