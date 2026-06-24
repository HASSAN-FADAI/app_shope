import 'package:ecommerce_app/features/orders/models/order_model.dart';
import 'package:ecommerce_app/features/orders/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderProvider>().fetchAllOrders();
  }

  void _showStatusMenu(Order order) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('تغيير حالة الطلب',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          ...['قيد الانتظار', 'موافقة', 'تم الشحن', 'مكتمل'].map((s) {
            final isSelected = order.status == s;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? Colors.teal : null,
              ),
              title: Text(s, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () {
                Navigator.pop(ctx);
                if (!isSelected) _changeStatus(order, s);
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _changeStatus(Order order, String newStatus) async {
    try {
      await context.read<OrderProvider>().updateOrderStatus(order.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير الحالة إلى "$newStatus"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل تغيير الحالة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات الواردة'),
        backgroundColor: const Color.fromARGB(255, 6, 235, 235),
      ),
      body: orders.isEmpty
          ? const Center(child: Text('لا توجد طلبات بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'طلب #${order.id.length > 6 ? order.id.substring(0, 6) : order.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showStatusMenu(order),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      order.status,
                                      style: TextStyle(
                                        color: Colors.orange[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down,
                                        size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text('الاسم: ${order.customerName}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('الهاتف: ${order.phone}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('الولاية: ${order.wilaya}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                            'التاريخ: ${order.date.toString().substring(0, 16)}',
                            style: const TextStyle(fontSize: 14)),
                        const Divider(),
                        const Text('المنتجات:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: order.products.length,
                            itemBuilder: (_, pi) {
                              final product = order.products[pi];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        product.images.isNotEmpty
                                            ? product.images.first
                                            : '',
                                        width: 80,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image,
                                                size: 50, color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${product.price} DA",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
