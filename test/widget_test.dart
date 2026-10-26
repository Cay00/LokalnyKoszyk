import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/presentation/discover_bloc.dart';

/// Smoke test pakietu — katalog kategorii jest niepusty i spójny.
void main() {
  test('category catalog has unique ids and names', () {
    final catalog = DiscoverBloc.categoryCatalog;
    expect(catalog, isNotEmpty);

    final ids = catalog.map((e) => e.id).toSet();
    final names = catalog.map((e) => e.name).toSet();

    expect(ids.length, catalog.length);
    expect(names.length, catalog.length);
    for (final entry in catalog) {
      expect(entry.iconAsset, startsWith('assets/categories/'));
      expect(entry.iconAsset, endsWith('.svg'));
    }
  });
}
