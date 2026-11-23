import 'package:fit_companion/core/services/cloud_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

void main() {
  test('confirmation deep link is recognised (not a "page not found")', () {
    expect(isAuthCallback(Uri.parse('io.fitcompanion://login-callback/?code=16e53181-8944')), isTrue);
    expect(isAuthCallback(Uri.parse('io.fitcompanion://login-callback')), isTrue);
    expect(isAuthCallback(Uri.parse('/settings/cloud')), isFalse);
    expect(isAuthCallback(Uri.parse('/home')), isFalse);
  });

  test('auth errors map to stable codes', () {
    expect(authErrorCode(AuthException('Invalid login credentials', statusCode: '400', code: 'invalid_credentials')), 'invalid_credentials');
    expect(authErrorCode(AuthException('Invalid login credentials')), 'invalid_credentials');
    expect(authErrorCode(AuthException('Email not confirmed')), 'email_not_confirmed');
    expect(authErrorCode(AuthException('email rate limit exceeded')), 'over_email_send_rate_limit');
    expect(authErrorCode(Exception('socket')), 'network');
  });
}
