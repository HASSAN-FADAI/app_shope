import 'package:ecommerce_app/core/error/app_error.dart';
import 'package:ecommerce_app/core/supabase/supabase_client.dart';
import 'package:ecommerce_app/features/auth/models/product_model.dart';
import 'package:flutter/foundation.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Product> _items = [];
  final Set<String> _favoriteIds = {};

  List<Product> get items => List.unmodifiable(_items);

  Future<void> fetchFavorites() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await supabase
          .from('favorites')
          .select('*, products(*)')
          .eq('user_id', userId);

      _items = data.map((row) {
        final productJson = row['products'] as Map<String, dynamic>;
        return Product.fromJson(productJson);
      }).toList();

      _favoriteIds.addAll(_items.map((p) => p.id));
    } catch (e) {
      AppError.getUserMessage(e);
    }
    notifyListeners();
  }

  Future<void> toggle(Product product) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (_favoriteIds.contains(product.id)) {
        await supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', int.parse(product.id));

        _items.removeWhere((p) => p.id == product.id);
        _favoriteIds.remove(product.id);
      } else {
        await supabase.from('favorites').insert({
          'user_id': userId,
          'product_id': int.parse(product.id),
        });

        _items.add(product);
        _favoriteIds.add(product.id);
      }
    } catch (e) {
      AppError.getUserMessage(e);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);
}
