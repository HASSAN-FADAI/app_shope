import 'package:ecommerce_app/features/auth/models/product_model.dart';
import 'package:ecommerce_app/features/auth/providers/auth_provider.dart';
import 'package:ecommerce_app/features/auth/providers/product_provider.dart';
import 'package:ecommerce_app/features/auth/screens/customer_main_screen.dart';
import 'package:ecommerce_app/features/auth/screens/login_screen.dart';
import 'package:ecommerce_app/features/auth/screens/product.dart';
import 'package:ecommerce_app/features/auth/screens/product_details_screen.dart';
import 'package:ecommerce_app/features/auth/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const _publicPaths = ['/login', '/signup', '/products'];

bool _isPublicRoute(String location) {
  if (location == '/') return true;
  if (location.startsWith('/product/')) return true;
  return _publicPaths.any((p) => location == p || location.startsWith('$p/'));
}

GoRouter appRouter(AuthProvider auth) {
  return GoRouter(
    refreshListenable: auth,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = auth.isAuthenticated;
      final location = state.matchedLocation;

      if (isLoggedIn && (location == '/login' || location == '/signup')) {
        final redirect = state.uri.queryParameters['redirect'];
        if (redirect != null &&
            redirect.isNotEmpty &&
            redirect != '/login' &&
            redirect != '/signup') {
          return redirect;
        }
        return '/';
      }

      if (!isLoggedIn && !_isPublicRoute(location)) {
        return '/login?redirect=${Uri.encodeComponent(location)}';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const CustomerMainScreen()),
      GoRoute(
        path: '/login',
        builder: (_, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginScreen(redirect: redirect);
        },
      ),
      GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
      GoRoute(path: '/products', builder: (_, _) => const ProductScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final product = context.read<ProductProvider>().products.firstWhere(
            (p) => p.id == id,
            orElse: () =>
                Product(id: id, title: '', price: 0, images: [], describe: ''),
          );
          return ProductDetailsScreen(product: product);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: const Center(child: Text('الصفحة غير موجودة')),
    ),
  );
}
