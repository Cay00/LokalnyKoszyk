import 'package:lokalny_koszyk/domain/models/seller.dart';

abstract class HomeRepository {
  Future<List<Seller>> getNearbySellers();
}
