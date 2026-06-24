import '../models/category.dart';

class CategoryData {
  static const List<Category> categories = [
    Category(id: 1, name: 'الأجهزة الكهربائية', slug: 'electrical'),
    Category(id: 2, name: 'الهواتف', slug: 'phones'),
    Category(id: 3, name: 'الإلكترونيات', slug: 'electronics'),
    Category(id: 4, name: 'الملابس', slug: 'clothes'),
    Category(id: 5, name: 'الكتب', slug: 'books'),
    Category(id: 6, name: 'الرياضة', slug: 'sports'),
  ];
}
