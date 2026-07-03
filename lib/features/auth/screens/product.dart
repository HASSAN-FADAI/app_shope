import 'package:ecommerce_app/core/error/app_error.dart';
import 'package:ecommerce_app/core/widgets/ecommerceappbar.dart';
import 'package:ecommerce_app/features/auth/models/product_model.dart';
import 'package:ecommerce_app/features/auth/providers/auth_provider.dart';
import 'package:ecommerce_app/features/auth/providers/cart_provider.dart';
import 'package:ecommerce_app/features/auth/providers/product_provider.dart';
import 'package:ecommerce_app/features/auth/screens/admin_screen.dart';
import 'package:ecommerce_app/features/auth/screens/product_details_screen.dart';
import 'package:ecommerce_app/features/categories/providers/category_provider.dart';
import 'package:ecommerce_app/features/categories/screens/category_management_screen.dart';
import 'package:ecommerce_app/features/favorites/providers/favorites_provider.dart';
import 'package:ecommerce_app/features/orders/screens/admin_orders_screen.dart';
import 'package:ecommerce_app/features/orders/screens/orders_screen.dart';
import 'package:ecommerce_app/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _selectedCategoryId = 0;

  @override
  void initState() {
    super.initState();
    context.read<CategoryProvider>().fetchCategories();
    context.read<ProductProvider>().fetchProducts();
    context.read<FavoritesProvider>().fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = context.watch<ProductProvider>().products;
    final categories = context.watch<CategoryProvider>().categories;
    final products = _selectedCategoryId == 0
        ? allProducts
        : allProducts
              .where((p) => p.categoryId == _selectedCategoryId)
              .toList();
    final authProvider = context.watch<AuthProvider>();
    final bool isAdmin = authProvider.user?.isAdmin ?? false;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(105),
        child: EcommerceAppbar(),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 6, 235, 235),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isAdmin)
                    Icon(
                      Icons.admin_panel_settings,
                      size: 50,
                      color: Colors.white,
                    ),
                  SizedBox(height: 10),
                  if (isAdmin)
                    Text(
                      'لوحة الإدارة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        'Logo',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. عناصر القائمة الجانبية
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blueGrey),
              title: const Text('الرئيسية', style: TextStyle(fontSize: 16)),
              onTap: () {
                // إغلاق القائمة الجانبية أولاً
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductScreen()),
                );
              },
            ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.inventory, color: Colors.blueGrey),
                title: const Text('إضافة منتج', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminScreen()),
                  );
                },
              ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.category, color: Colors.blueGrey),
                title: const Text(
                  'إدارة التصنيفات',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoryManagementScreen(),
                    ),
                  );
                },
              ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.blueGrey),
                title: const Text(
                  'المبيعات الشهرية',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.blueGrey),
                title: const Text('الطلبات', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminOrdersScreen(),
                    ),
                  );
                },
              ),

            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blueGrey),
              title: const Text('طلباتي', style: TextStyle(fontSize: 16)),
              onTap: () {
                // إغلاق القائمة الجانبية أولاً
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(
                        title: const Text('طلباتي'),
                        backgroundColor: const Color.fromARGB(255, 6, 235, 235),
                      ),
                      body: const OrdersScreen(),
                    ),
                  ),
                );
              },
            ),

            const Divider(thickness: 1),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey),
              title: const Text('الإعدادات', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              onTap: () {
                context.read<AuthProvider>().signOut();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 90,
              color: const Color.fromARGB(255, 6, 235, 235),
              child: const Center(
                child: Text(
                  'Products  |  المنتجات',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterChip(
                    label: const Text('الكل'),
                    selected: _selectedCategoryId == 0,
                    onSelected: (_) => setState(() => _selectedCategoryId = 0),
                  ),
                  const SizedBox(width: 8),
                  ...categories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(c.name),
                        selected: _selectedCategoryId == c.id,
                        onSelected: (_) =>
                            setState(() => _selectedCategoryId = c.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (products.isEmpty)
              const Center(child: Text('لا توجد منتجات بعد'))
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 30,
                runSpacing: 30,
                children: List.generate(products.length, (index) {
                  return ProductCard(
                    product: products[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: products[index]),
                        ),
                      );
                    },
                  );
                }),
              ),
            const SizedBox(height: 30),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 250,
        height: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Stack(
                children: [
                  AnimatedScale(
                    scale: _isHovered ? 1.06 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        widget.product.images.first,
                        width: 250,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  if (_isHovered)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Center(
                          child: Text(
                            'أضف إلى السلة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.product.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.product.price} DA",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          context.read<CartProvider>().addItem(widget.product);
                        },
                      ),
                      SizedBox(width: 6),
                      IconButton(
                        icon: Icon(
                          context.read<FavoritesProvider>().isFavorite(
                                widget.product.id,
                              )
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          try {
                            await context.read<FavoritesProvider>().toggle(
                              widget.product,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppError.getUserMessage(e)),
                                ),
                              );
                            }
                          }
                        },
                      ),

                      SizedBox(width: 6),

                      if (isAdmin)
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                          try {
                            await context.read<ProductProvider>().removeProduct(
                              widget.product.id,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('! تم حذف المنتج'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppError.getUserMessage(e))),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
