import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/core/formatting/pennies.dart';

void main() {
  group('parsePennies', () {
    test('null returns 0', () {
      expect(parsePennies(null), 0);
    });

    test('int passes through', () {
      expect(parsePennies(1299), 1299);
    });

    test('num is rounded', () {
      expect(parsePennies(12.6), 13);
      expect(parsePennies(12.4), 12);
    });

    test('string is parsed', () {
      expect(parsePennies('250'), 250);
      expect(parsePennies('x'), 0);
    });
  });

  group('plnFromPennies / plnCommaStringFromPennies', () {
    test('converts grosze to PLN', () {
      expect(plnFromPennies(1299), closeTo(12.99, 0.0001));
      expect(plnCommaStringFromPennies(1299), '12,99');
      expect(plnCommaStringFromPennies(100), '1,00');
      expect(plnCommaStringFromPennies(0), '0,00');
    });
  });
}
