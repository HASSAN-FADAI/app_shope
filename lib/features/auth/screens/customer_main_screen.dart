import 'package:ecommerce_app/features/auth/providers/auth_provider.dart';
import 'package:ecommerce_app/features/auth/screens/product.dart';
import 'package:ecommerce_app/features/favorites/screens/favorites_screen.dart';
import 'package:ecommerce_app/features/orders/screens/orders_screen.dart';
import 'package:ecommerce_app/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _currentIndex = 0;
  int _orderRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ProductScreen(),
      const FavoritesScreen(),
      OrdersScreen(key: ValueKey('orders_$_orderRefreshKey')),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i >= 1 &&
              !context.read<AuthProvider>().isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يرجى تسجيل الدخول أولاً'),
                duration: Duration(seconds: 2),
              ),
            );
            context.push('/login?redirect=/');
            return;
          }
          setState(() {
            _currentIndex = i;
            if (i == 2) _orderRefreshKey++;
          });
        },
        selectedItemColor: const Color.fromARGB(255, 6, 235, 235),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'طلباتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}
