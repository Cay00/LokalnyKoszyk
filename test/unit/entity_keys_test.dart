import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';

void main() {
  test('normalizeUuidKey trims and lowercases', () {
    expect(
      normalizeUuidKey('  AbCDef12-3456-7890  '),
      'abcdef12-3456-7890',
    );
  });
}
