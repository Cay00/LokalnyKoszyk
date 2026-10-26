import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/core/supabase/auth_error_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const fallback = 'Coś poszło nie tak.';

  test('maps AuthException by code', () {
    expect(
      polishAuthError(
        AuthException('x', code: 'invalid_credentials'),
        fallback: fallback,
      ),
      'Nieprawidłowy email lub hasło.',
    );
  });

  test('maps AuthException by known message', () {
    expect(
      polishAuthError(
        AuthException('Invalid login credentials'),
        fallback: fallback,
      ),
      'Nieprawidłowy email lub hasło.',
    );
  });

  test('maps retry-after message', () {
    expect(
      polishAuthError(
        AuthException('You can only request this once every 42 seconds'),
        fallback: fallback,
      ),
      'Ze względów bezpieczeństwa spróbuj ponownie za 42 s.',
    );
  });

  test('unknown errors use fallback', () {
    expect(
      polishAuthError(Exception('boom'), fallback: fallback),
      fallback,
    );
  });
}
