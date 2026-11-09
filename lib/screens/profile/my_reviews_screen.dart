import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/review.dart';
import 'package:lokalny_koszyk/domain/repositories/reviews_repository.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  bool _loading = true;
  String? _error;
  List<Review> _reviews = const <Review>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reviews = await context.read<ReviewsRepository>().getMyReviews();
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Moje opinie',
      onBack: widget.onBack,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: DefaultScreen.bodyPadding(context),
          children: <Widget>[
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Text(_error!, style: AppTypography.normal)
            else if (_reviews.isEmpty)
              Text(
                'Nie masz jeszcze żadnych opinii.\n'
                'Po realizacji zamówienia możesz ocenić produkty w historii zamówień.',
                style: AppTypography.normal,
              )
            else
              for (final Review review in _reviews)
                _ReviewTile(review: review),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.normal),
        border: Border.all(color: AppColors.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(review.productName, style: AppTypography.normalBold),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              ...List<Widget>.generate(5, (int i) {
                final filled = i < review.rating;
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: SvgPicture.asset(
                    filled
                        ? 'assets/icons/star-fill.svg'
                        : 'assets/icons/star.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      filled ? AppColors.accent_2 : AppColors.textTertiary,
                      BlendMode.srcIn,
                    ),
                  ),
                );
              }),
              const Spacer(),
              Text(
                formatOrderDate(review.createdAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(review.comment, style: AppTypography.normal),
          ],
        ],
      ),
    );
  }
}
