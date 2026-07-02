import 'package:ecommerce_app/core/error/app_error.dart';
import 'package:ecommerce_app/core/supabase/supabase_client.dart';
import 'package:ecommerce_app/features/auth/models/product_model.dart';
import 'package:ecommerce_app/features/auth/providers/auth_provider.dart';
import 'package:ecommerce_app/features/auth/providers/product_provider.dart';
import 'package:ecommerce_app/features/auth/screens/product.dart';
import 'package:ecommerce_app/features/categories/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<String> _selectedImageUrls = [];
  final _titleCtrl = TextEditingController();
  final _describeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int _selectedCategoryId = 0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    context.read<CategoryProvider>().fetchCategories();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _describeCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadImages() async {
    try {
      final picked = await ImagePicker().pickMultiImage();
      if (picked.isEmpty) return;

      setState(() => _isUploading = true);

      final urls = <String>[];

      for (final file in picked) {
        try {
          // فحص حجم الملف
          final bytes = await file.readAsBytes();
          if (bytes.lengthInBytes > 5 * 1024 * 1024) {
            continue;
          }

          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

          //  عملية الرفع
          await supabase.storage
              .from('product_images')
              .uploadBinary(fileName, bytes);

          urls.add(
            supabase.storage.from('product_images').getPublicUrl(fileName),
          );
        } catch (e) {
          AppError.getUserMessage(e);
        }
      }

      if (!mounted) return;
      setState(() {
        _selectedImageUrls.addAll(urls);
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء رفع الصور: $e')));
    }
  }

  Future<void> _addProduct() async {
    if (_selectedImageUrls.isEmpty ||
        _titleCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty ||
        _describeCtrl.text.isEmpty) {
      return;
    }

    try {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        describe: _describeCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        categoryId: _selectedCategoryId,
        images: _selectedImageUrls,
      );

      await context.read<ProductProvider>().addProduct(product);
      _titleCtrl.clear();
      _describeCtrl.clear();
      _priceCtrl.clear();
      setState(() {
        _selectedImageUrls.clear();
        _selectedCategoryId = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('! تمت إضافة المنتج بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppError.getUserMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isAdmin = authProvider.user?.isAdmin ?? false;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 6, 235, 235),
        toolbarHeight: 105,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لوحة التحكم  ',
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blueGrey),
              title: const Text('تفاصيل ', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                // Navigator.push(
                //   context,
                //    MaterialPageRoute(
                //      builder: (_) => ProductDetailsScreen(product: prouduct),
                //   ),
                // );
              },
            ),
            //if (isAdmin)
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
                leading: const Icon(Icons.bar_chart, color: Colors.blueGrey),
                title: const Text(
                  'المبيعات الشهرية',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // سيتم الانتقال لاحقاً لصفحة تتبع المبيعات
                },
              ),

            const Divider(thickness: 1), // خط فاصل أنيق

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey),
              title: const Text('الإعدادات', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().signOut();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'إضافة منتج (للأدمن)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 600,
                  child: TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنتج',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 600,
                  child: TextField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 600,
                  child: TextField(
                    controller: _describeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 600,
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'التصنيف',
                      border: OutlineInputBorder(),
                    ),
                    items: context
                        .watch<CategoryProvider>()
                        .categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategoryId = v ?? 0),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadImages,
                  icon: const Icon(Icons.image),
                  label: Text(
                    _isUploading
                        ? 'جاري الرفع...'
                        : 'إضافة صورة (${_selectedImageUrls.length})',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 235, 235),
                  ),
                  child: const Text('إضافة المنتج'),
                ),
                if (_selectedImageUrls.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImageUrls.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.network(
                          _selectedImageUrls[i],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
