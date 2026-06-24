import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

class AppError {
  AppError._();

  static String getUserMessage(Object error) {
    developer.log('AppError caught: $error');

    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      if (msg.contains('email already registered')) {
        return 'البريد الإلكتروني مسجل مسبقاً';
      }
      if (msg.contains('email not confirmed')) {
        return 'البريد الإلكتروني بحاجة إلى تأكيد';
      }
      if (msg.contains('user not found')) {
        return 'المستخدم غير موجود';
      }
      if (msg.contains('password')) {
        return 'كلمة المرور غير صحيحة';
      }
      return 'فشل تسجيل الدخول، تحقق من بياناتك';
    }

    if (error is PostgrestException) {
      final code = error.code;
      if (code == '23505') {
        return 'البيانات موجودة مسبقاً';
      }
      if (code == '23503') {
        return 'لا يمكن الحذف، البيانات مرتبطة بعناصر أخرى';
      }
      if (code == '42501' || code == 'P0001') {
        return 'ليس لديك صلاحية للقيام بهذه العملية';
      }
      return 'حدث خطأ في قاعدة البيانات';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال، تحقق من اتصالك بالإنترنت';
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('HandshakeException') ||
        error.toString().contains('Connection refused') ||
        error.toString().contains('No address associated') ||
        error.toString().contains('Network is unreachable')) {
      return 'لا يوجد اتصال بالإنترنت، تحقق من اتصالك ثم حاول مرة أخرى';
    }

    if (error.toString().contains('storage') ||
        error.toString().contains('upload')) {
      return 'فشل رفع الملف، تحقق من الاتصال وحاول مرة أخرى';
    }

    return 'حدث خطأ غير متوقع، حاول مرة أخرى';
  }

  static Future<T> guard<T>(Future<T> Function() fn) async {
    try {
      return await fn().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      developer.log('AppError: Request timed out');
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
