import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/core/formatting/product_price_per_label.dart';

void main() {
  group('ProductUnitParsing.fromSlashUnit', () {
    test('parses aliases', () {
      expect(ProductUnitParsing.fromSlashUnit('kg'), ProductUnit.kilogram);
      expect(ProductUnitParsing.fromSlashUnit('/ piece'), ProductUnit.piece);
      expect(ProductUnitParsing.fromSlashUnit('pieces'), ProductUnit.piece);
      expect(ProductUnitParsing.fromSlashUnit('ML'), ProductUnit.milliliter);
      expect(ProductUnitParsing.fromSlashUnit('unknown'), isNull);
      expect(ProductUnitParsing.fromSlashUnit('/ szt.'), isNull);
    });
  });

  group('buildProductSizeLabel', () {
    test('piece and kilogram cases', () {
      expect(
        buildProductSizeLabel(unit: ProductUnit.piece, quantity: 2),
        '2 szt.',
      );
      expect(
        buildProductSizeLabel(unit: ProductUnit.kilogram, quantity: 0.25),
        '250 g',
      );
      expect(
        buildProductSizeLabel(unit: ProductUnit.kilogram, quantity: 1.5),
        '1,5 kg',
      );
    });

    test('null unit uses fallback', () {
      expect(
        buildProductSizeLabel(unit: null, fallback: 'opak.'),
        'opak.',
      );
    });
  });

  group('buildProductPricePerLabel', () {
    test('formats offer labels', () {
      expect(
        buildProductPricePerLabel(
          priceFormatted: '12,99',
          unit: ProductUnit.piece,
          quantity: 1,
        ),
        '12,99 zł/szt.',
      );
      expect(
        buildProductPricePerLabel(
          priceFormatted: '9,99',
          unit: ProductUnit.piece,
          quantity: 2,
        ),
        '9,99 zł/2 szt.',
      );
      expect(
        buildProductPricePerLabel(
          priceFormatted: '3,49',
          unit: ProductUnit.kilogram,
          quantity: 0.25,
        ),
        '3,49 zł/250 g',
      );
      expect(
        buildProductPricePerLabel(
          priceFormatted: '7,99',
          unit: null,
          quantity: null,
        ),
        '7,99 zł',
      );
    });
  });
}
