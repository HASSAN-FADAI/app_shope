import 'package:ecommerce_app/core/error/app_error.dart';
import 'package:ecommerce_app/core/supabase/supabase_client.dart';
import 'package:ecommerce_app/features/categories/models/category.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;

    try {
      final data = await supabase
          .from('categories')
          .select('*')
          .order('id');

      _categories = data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      AppError.getUserMessage(e);
    }

    _isLoading = false;
    if (hasListeners) notifyListeners();
  }

  Future<void> addCategory(String name, String slug) async {
    try {
      final data = await supabase
          .from('categories')
          .insert({'name': name, 'slug': slug})
          .select()
          .single();

      _categories.add(Category.fromJson(data));
      notifyListeners();
    } catch (e) {
      AppError.getUserMessage(e);
      rethrow;
    }
  }

  Future<void> editCategory(int id, String name, String slug) async {
    try {
      await supabase
          .from('categories')
          .update({'name': name, 'slug': slug})
          .eq('id', id);

      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = Category(id: id, name: name, slug: slug);
        notifyListeners();
      }
    } catch (e) {
      AppError.getUserMessage(e);
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await supabase.from('categories').delete().eq('id', id);

      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      AppError.getUserMessage(e);
      rethrow;
    }
  }
}
