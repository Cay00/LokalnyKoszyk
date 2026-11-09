import 'package:lokalny_koszyk/domain/models/review.dart';
import 'package:lokalny_koszyk/domain/repositories/reviews_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseReviewsRepository implements ReviewsRepository {
  const SupabaseReviewsRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<Review>> getMyReviews() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }

    final rows = await _supabase
        .from('reviews')
        .select('id, product_id, order_id, rating, comment, created_at, products(name)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>).map<Review>((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      final product = map['products'] is Map
          ? Map<String, dynamic>.from(map['products'] as Map)
          : const <String, dynamic>{};
      return Review(
        id: (map['id'] ?? '').toString(),
        productId: (map['product_id'] ?? '').toString(),
        productName: (product['name'] ?? 'Produkt').toString(),
        rating: (map['rating'] as num?)?.toInt() ?? 0,
        comment: (map['comment'] ?? '').toString(),
        createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()),
        orderId: map['order_id']?.toString(),
      );
    }).toList();
  }

  @override
  Future<void> submitReview({
    required String productId,
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    await _supabase.rpc(
      'submit_product_review',
      params: <String, dynamic>{
        'p_product_id': productId,
        'p_order_id': orderId,
        'p_rating': rating,
        'p_comment': comment,
      },
    );
  }
}
