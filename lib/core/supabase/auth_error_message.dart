import 'package:supabase_flutter/supabase_flutter.dart';

String polishAuthError(
  Object error, {
  required String fallback,
}) {
  if (error is AuthRetryableFetchException) {
    return 'Brak połączenia. Sprawdź internet i spróbuj ponownie.';
  }
  if (error is AuthWeakPasswordException) {
    return _byCode['weak_password']!;
  }
  if (error is AuthSessionMissingException) {
    return 'Sesja wygasła. Zaloguj się ponownie.';
  }
  if (error is AuthException) {
    final String? byCode = error.code == null
        ? null
        : _byCode[error.code!.toLowerCase()];
    if (byCode != null) return byCode;

    final String normalized = error.message.trim().toLowerCase();
    final String? byMessage = _byMessage[normalized];
    if (byMessage != null) return byMessage;

    final Match? retryAfter = _retryAfterPattern.firstMatch(normalized);
    if (retryAfter != null) {
      return 'Ze względów bezpieczeństwa spróbuj ponownie za ${retryAfter.group(1)} s.';
    }
  }
  return fallback;
}

final RegExp _retryAfterPattern = RegExp(
  r'you can only request this (?:once every|after) (\d+) seconds',
);

const Map<String, String> _byCode = <String, String>{
  'invalid_credentials': 'Nieprawidłowy email lub hasło.',
  'email_not_confirmed': 'Potwierdź adres email, aby się zalogować.',
  'phone_not_confirmed': 'Potwierdź numer telefonu, aby się zalogować.',
  'email_exists': 'Konto z tym adresem email już istnieje.',
  'user_already_exists': 'Konto z tym adresem email już istnieje.',
  'weak_password': 'Hasło jest zbyt słabe.',
  'over_email_send_rate_limit': 'Zbyt wiele prób. Spróbuj ponownie za chwilę.',
  'over_request_rate_limit': 'Zbyt wiele prób. Spróbuj ponownie za chwilę.',
  'over_sms_send_rate_limit': 'Zbyt wiele prób. Spróbuj ponownie za chwilę.',
  'user_banned': 'To konto zostało zablokowane.',
  'user_not_found': 'Nie znaleziono konta.',
  'signup_disabled': 'Rejestracja jest obecnie wyłączona.',
  'email_address_invalid': 'Podaj poprawny adres email.',
  'otp_expired': 'Kod wygasł. Poproś o nowy.',
  'otp_disabled': 'Logowanie kodem jest wyłączone.',
  'same_password': 'Nowe hasło musi się różnić od poprzedniego.',
  'session_not_found': 'Sesja wygasła. Zaloguj się ponownie.',
  'refresh_token_not_found': 'Sesja wygasła. Zaloguj się ponownie.',
  'captcha_failed': 'Weryfikacja nie powiodła się. Spróbuj ponownie.',
  'request_timeout': 'Przekroczono czas oczekiwania. Spróbuj ponownie.',
  'validation_failed': 'Nie udało się zweryfikować danych.',
  'unexpected_failure': 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie.',
  'identity_already_exists': 'To konto jest już połączone.',
  'email_provider_disabled': 'Logowanie emailem jest wyłączone.',
  'email_address_not_authorized': 'Ten adres email nie jest uprawniony do rejestracji.',
};

const Map<String, String> _byMessage = <String, String>{
  'invalid login credentials': 'Nieprawidłowy email lub hasło.',
  'invalid email or password': 'Nieprawidłowy email lub hasło.',
  'email not confirmed': 'Potwierdź adres email, aby się zalogować.',
  'user already registered': 'Konto z tym adresem email już istnieje.',
  'user already exists': 'Konto z tym adresem email już istnieje.',
  'a user with this email address has already been registered':
      'Konto z tym adresem email już istnieje.',
  'password should be at least 6 characters':
      'Hasło musi mieć co najmniej 6 znaków.',
  'password should be at least 8 characters':
      'Hasło musi mieć co najmniej 8 znaków.',
  'unable to validate email address: invalid format':
      'Podaj poprawny adres email.',
  'email rate limit exceeded': 'Zbyt wiele prób. Spróbuj ponownie za chwilę.',
  'signup is disabled': 'Rejestracja jest obecnie wyłączona.',
  'user not found': 'Nie znaleziono konta.',
  'token has expired or is invalid': 'Link wygasł lub jest nieprawidłowy.',
  'email link is invalid or has expired': 'Link wygasł lub jest nieprawidłowy.',
  'new password should be different from the old password.':
      'Nowe hasło musi się różnić od poprzedniego.',
  'new password should be different from the old password':
      'Nowe hasło musi się różnić od poprzedniego.',
  'auth session missing!': 'Sesja wygasła. Zaloguj się ponownie.',
  'network request failed':
      'Brak połączenia. Sprawdź internet i spróbuj ponownie.',
  'failed to fetch': 'Brak połączenia. Sprawdź internet i spróbuj ponownie.',
};
