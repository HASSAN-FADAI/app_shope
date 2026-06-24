import 'package:ecommerce_app/core/error/app_error.dart';
import 'package:ecommerce_app/features/categories/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CategoryProvider>().fetchCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (_nameCtrl.text.trim().isEmpty || _slugCtrl.text.trim().isEmpty) return;
    try {
      await context.read<CategoryProvider>().addCategory(
            _nameCtrl.text.trim(),
            _slugCtrl.text.trim(),
          );
      _nameCtrl.clear();
      _slugCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('! تمت إضافة التصنيف'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.getUserMessage(e))),
        );
      }
    }
  }

  void _deleteCategory(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التصنيف'),
        content: Text('هل أنت متأكد من حذف "$name"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await context.read<CategoryProvider>().deleteCategory(id);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('! تم حذف التصنيف'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(AppError.getUserMessage(e))),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final categories = catProvider.categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التصنيفات'),
        backgroundColor: const Color.fromARGB(255, 6, 235, 235),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم التصنيف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _slugCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Slug',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: catProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                      ? const Center(child: Text('لا توجد تصنيفات'))
                      : ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (_, i) {
                            final cat = categories[i];
                            return ListTile(
                              title: Text(cat.name),
                              subtitle: Text(cat.slug),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCategory(cat.id, cat.name),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
