import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/core/formatting/distance_label.dart';
import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/formatting/product_price_per_label.dart';

/// Proste testy wydajnościowe logiki czystej (bez UI / sieci).
/// Próg jest celowo luźny — chroni przed regresją rzędu wielkości.
void main() {
  test('formatowanie 10 000 etykiet ceny kończy się poniżej 500 ms', () {
    final sw = Stopwatch()..start();
    for (var i = 0; i < 10000; i++) {
      buildProductPricePerLabel(
        priceFormatted: plnCommaStringFromPennies(100 + i),
        unit: ProductUnit.kilogram,
        quantity: i.isEven ? 1.0 : 0.25,
      );
    }
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(500));
  });

  test('formatowanie 10 000 etykiet dystansu kończy się poniżej 100 ms', () {
    final sw = Stopwatch()..start();
    for (var i = 0; i < 10000; i++) {
      formatDistanceLabelFromMeters(i * 123.4);
    }
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(100));
  });
}
