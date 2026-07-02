import 'package:ecommerce_app/core/router/app_router.dart';
import 'package:ecommerce_app/features/auth/providers/auth_provider.dart';
import 'package:ecommerce_app/features/auth/providers/cart_provider.dart';
import 'package:ecommerce_app/features/auth/providers/product_provider.dart';
import 'package:ecommerce_app/features/categories/providers/category_provider.dart';
import 'package:ecommerce_app/features/favorites/providers/favorites_provider.dart';
import 'package:ecommerce_app/features/orders/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

late final GoRouter _router;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env غير موجود، نعتمد على --dart-define
  }
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  final url = supabaseUrl.isNotEmpty
      ? supabaseUrl
      : dotenv.env['SUPABASE_URL'] ?? '';
  final anonKey = supabaseAnonKey.isNotEmpty
      ? supabaseAnonKey
      : dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = appRouter(auth);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthProvider>();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
