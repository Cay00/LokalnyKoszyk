import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/data/product_from_row.dart';

void main() {
  test('productFromSupabaseRow maps price, unit and ratings', () {
    final product = productFromSupabaseRow(
      <String, dynamic>{
        'product_id': 'p-1',
        'name': 'Marchew',
        'price_gross_amount': 499,
        'unit': 'kilogram',
        'average_rating': 4.56,
        'reviews_count': 12,
        'package_size': 1.0,
        'category_id': 'cat-1',
        'seller_id': 'seller-1',
      },
      producer: 'Gospodarstwo Zielone',
    );

    expect(product.id, 'p-1');
    expect(product.name, 'Marchew');
    expect(product.producer, 'Gospodarstwo Zielone');
    expect(product.price, '4,99');
    expect(product.unit, '/ kilogram');
    expect(product.unitKey, 'kilogram');
    expect(product.rating, '4.6');
    expect(product.reviews, '12');
    expect(product.packageQuantity, 1.0);
    expect(product.categoryId, 'cat-1');
    expect(product.sellerId, 'seller-1');
  });

  test('missing fields use safe defaults', () {
    final product = productFromSupabaseRow(
      <String, dynamic>{},
      producer: 'X',
    );

    expect(product.name, 'Produkt');
    expect(product.price, '0,00');
    expect(product.rating, '0.0');
    expect(product.reviews, '0');
    expect(product.sellerId, isNull);
    expect(product.categoryId, isNull);
  });
}
