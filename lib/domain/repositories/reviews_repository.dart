import 'package:lokalny_koszyk/domain/models/review.dart';

abstract class ReviewsRepository {
  Future<List<Review>> getMyReviews();

  Future<void> submitReview({
    required String productId,
    required String orderId,
    required int rating,
    String? comment,
  });
}
