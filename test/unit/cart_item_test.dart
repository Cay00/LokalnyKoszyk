import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';

void main() {
  CartItem item({
    String? sellerId,
    String producer = 'Sprzedawca',
    double quantity = 2,
    double price = 10.5,
  }) {
    return CartItem(
      id: 'c1',
      productId: 'p1',
      name: 'Jajka',
      unit: 'szt.',
      currency: 'PLN',
      quantity: quantity,
      price: price,
      sellerId: sellerId,
      producer: producer,
    );
  }

  test('lineTotal multiplies quantity by price', () {
    expect(item().lineTotal, closeTo(21.0, 0.0001));
  });

  test('sellerKey prefers sellerId over producer name', () {
    expect(item(sellerId: 'uuid-1').sellerKey, 'uuid-1');
    expect(item(sellerId: '  ').sellerKey, 'Sprzedawca');
    expect(
      item(sellerId: null, producer: '  Gospodarstwo X  ').sellerKey,
      'Gospodarstwo X',
    );
    expect(
      item(sellerId: null, producer: '   ').sellerKey,
      'Sprzedawca',
    );
  });

  test('sellerDisplayName falls back when empty', () {
    expect(item(producer: '').sellerDisplayName, 'Sprzedawca');
    expect(item(producer: '  Farm  ').sellerDisplayName, 'Farm');
  });
}
