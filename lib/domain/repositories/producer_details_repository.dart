import 'package:lokalny_koszyk/domain/models/producer_profile.dart';

abstract class ProducerDetailsRepository {
  Future<ProducerProfileWithProducts> getSellerAndProducts(String sellerId);

  Future<String> buildDistanceLabel(ProducerProfile seller);
}
