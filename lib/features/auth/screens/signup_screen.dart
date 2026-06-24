import 'package:ecommerce_app/core/widgets/ecommerceappbar.dart';
import 'package:ecommerce_app/core/widgets/newsletter_banner.dart';
import 'package:ecommerce_app/features/auth/providers/auth_provider.dart';
import 'package:ecommerce_app/features/categories/data/categories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  String _selectedCategory = 'جميع الفئات ';
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    await auth.signUp(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (mounted && context.read<AuthProvider>().error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Check your email.')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(105),
        child: EcommerceAppbar(),
      ),

      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 1)),
                  Visibility(
                    visible: MediaQuery.of(context).size.width > 700,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      color: Colors.white,
                      width: double.infinity,
                      height: 80,
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.all(20)),
                          Text('''  :الخط
xxxxxxxxxx'''),
                          Icon(
                            Icons.phone,
                            color: const Color.fromARGB(255, 6, 235, 235),
                          ),
                          const Spacer(),

                          Container(
                            padding: EdgeInsets.all(5),
                            width: 250,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color.fromARGB(255, 6, 235, 235),
                              ),
                            ),
                            child: PopupMenuButton<String>(
                              onSelected: (slug) {
                                setState(() {
                                  _selectedCategory = CategoryData.categories
                                      .firstWhere((c) => c.slug == slug)
                                      .name;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back, size: 15),
                                  const Spacer(),
                                  Text(_selectedCategory),
                                  SizedBox(width: 8),
                                  Icon(Icons.list),
                                ],
                              ),
                              itemBuilder: (_) =>
                                  CategoryData.categories.map((cat) {
                                    return PopupMenuItem<String>(
                                      value: cat.slug,
                                      child: Text(cat.name),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 100,
                    color: const Color.fromARGB(255, 6, 235, 235),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إنشاء حساب ',
                          style: TextStyle(color: Colors.black, fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 40),
                        ),
                      ],
                    ),
                    width: 550,
                    height: 600,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 40,
                          //color: Theme.of(context).colorScheme.primary,
                          color: Colors.lightBlue,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Create Account',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || !v.contains('@')
                              ? 'أدخل إيميل صحيح'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          obscureText: _obscure,
                          validator: (v) => v == null || v.length < 6
                              ? 'يجب ان تكون كلمة المرور اكثر من 6أحرف'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmCtrl,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: _obscure,
                          validator: (v) => v != _passwordCtrl.text
                              ? 'كلمة المرور غير متطابقة'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        if (auth.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              auth.error!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                6,
                                235,
                                235,
                              ),
                            ),
                            child: const Text('Sign Up'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Already have an account? Sign In'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),

                  NewsletterBanner(),

                  SizedBox(height: 100),

                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 30,
                    runSpacing: 20,

                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Talk To Us',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Got Question? Call us'),
                          const Text('XXXXXXXXXX'),
                          const Text('support@ecommerce.com'),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Profile'),
                          const Text('Orders'),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Information',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('About Us'),
                          const Text('Privacy Policy'),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/Pngtree_book_store.png',
                            width: MediaQuery.of(context).size.width * 0.25,

                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
