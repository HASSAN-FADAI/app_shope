import 'package:ecommerce_app/core/error/app_error.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../../../core/supabase/supabase_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  String? _error;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        final user = session.user;
        final profile = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();
        _user = AppUser(
          id: user.id,
          email: user.email ?? '',
          role: profile?['role'] as String? ?? 'user',
        );
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;

      if (user != null) {
        final profile = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();
        _user = AppUser(
          id: user.id,
          email: user.email ?? '',
          role: profile?['role'] as String? ?? 'user',
        );
        _status = AuthStatus.authenticated;
        _error = null;
      } else {
        _error = 'البريد الإلكتروني بحاجة إلى تأكيد';
      }
    } on AuthException catch (e) {
      _error = AppError.getUserMessage(e);
    } on PostgrestException catch (e) {
      _error = AppError.getUserMessage(e);
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    try {
      // 1. تسجيل المستخدم والحصول على الرد مباشرة
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // 2. التحقق من أن المستخدم تم إنشاؤه
      if (authResponse.user != null) {
        // 3. يتم إنشاء البروفايل تلقائياً عبر trigger في Supabase
        _error = null;
      }
    } on PostgrestException catch (e) {
      _error = AppError.getUserMessage(e);
    } catch (e) {
      _error = AppError.getUserMessage(e);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {}
    _status = AuthStatus.unauthenticated;
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
