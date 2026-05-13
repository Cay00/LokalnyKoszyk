import 'package:lokalny_koszyk/domain/models/product.dart';

abstract class DiscoverRepository {
  Future<List<Product>> getActiveProducts();
}
