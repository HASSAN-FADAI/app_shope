import 'package:ecommerce_app/features/auth/providers/cart_provider.dart';
import 'package:ecommerce_app/features/favorites/screens/favorites_screen.dart';
import 'package:ecommerce_app/features/orders/screens/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EcommerceAppbar extends StatefulWidget {
  final bool showBack;
  const EcommerceAppbar({super.key, this.showBack = false});

  @override
  State<EcommerceAppbar> createState() => _EcommerceAppbarState();
}

class _EcommerceAppbarState extends State<EcommerceAppbar> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return AppBar(
      leading: widget.showBack ? const BackButton() : null,
      centerTitle: true,
      elevation: 0,
      backgroundColor: const Color.fromARGB(255, 255, 253, 253),
      toolbarHeight: 105,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Ecommerce ', style: TextStyle(fontSize: 20)),

          Text(
            'Dz',
            style: TextStyle(color: const Color.fromARGB(255, 30, 167, 35)),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromARGB(255, 6, 235, 235),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.search,
                      color: const Color.fromARGB(255, 6, 235, 235),
                    ),

                    Text(
                      'البحث عن المنتجات ',
                      style: TextStyle(
                        color: const Color.fromARGB(
                          255,
                          199,
                          187,
                          187,
                        ).withValues(alpha: 0.6),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Row(
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.black54),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: const Text('المفضلة'),
                          backgroundColor: const Color.fromARGB(255, 6, 235, 235),
                        ),
                        body: const FavoritesScreen(),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Badge(
                  isLabelVisible: cart.cartCount > 0,
                  label: Text('${cart.cartCount}'),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black54,
                  ),
                ),
                onPressed: () {
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
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          width: double.infinity,
          height: 2,
          color: Colors.black.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
