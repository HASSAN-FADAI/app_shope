import 'package:ecommerce_app/core/error/app_error.dart';
import 'package:ecommerce_app/core/supabase/supabase_client.dart';
import 'package:ecommerce_app/features/orders/models/order_model.dart';
import 'package:flutter/foundation.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> fetchOrders() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await supabase
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('id', ascending: false);

      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      AppError.getUserMessage(e);
    }
    notifyListeners();
  }

  Future<void> fetchAllOrders() async {
    try {
      final data = await supabase
          .from('orders')
          .select('*')
          .order('id', ascending: false);

      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      AppError.getUserMessage(e);
    }
    notifyListeners();
  }

  Future<void> addOrder(Order order) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final payload = order.toJson();
      if (userId != null) {
        payload['user_id'] = userId;
      }

      final data = await supabase
          .from('orders')
          .insert(payload)
          .select()
          .single();

      _orders.insert(0, Order.fromJson(data));
    } catch (e) {
      AppError.getUserMessage(e);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', int.parse(orderId));

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = Order(
          id: _orders[index].id,
          products: _orders[index].products,
          customerName: _orders[index].customerName,
          phone: _orders[index].phone,
          wilaya: _orders[index].wilaya,
          status: newStatus,
          date: _orders[index].date,
        );
      }
    } catch (e) {
      AppError.getUserMessage(e);
      rethrow;
    }
    notifyListeners();
  }
}
