import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokalny_koszyk/core/di/providers.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/watched_product.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
import 'package:lokalny_koszyk/presentation/models/favorite_product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

final favoritesViewModelProvider =
    StateNotifierProvider.autoDispose<FavoritesViewModel, FavoritesState>((
      ref,
    ) {
      return FavoritesViewModel(
        watchedProductsRepository: ref.read(watchedProductsRepositoryProvider),
      )..load();
    });

class FavoritesState {
  const FavoritesState({
    required this.isLoading,
    required this.items,
    required this.isSignedIn,
    this.errorText,
  });

  factory FavoritesState.initial() => FavoritesState(
    isLoading: true,
    items: const <FavoriteProductUiModel>[],
    isSignedIn: false,
    errorText: null,
  );

  final bool isLoading;
  final List<FavoriteProductUiModel> items;
  final bool isSignedIn;
  final String? errorText;

  FavoritesState copyWith({
    bool? isLoading,
    List<FavoriteProductUiModel>? items,
    bool? isSignedIn,
    String? errorText,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      errorText: errorText,
    );
  }
}

class FavoritesViewModel extends StateNotifier<FavoritesState> {
  FavoritesViewModel({
    required WatchedProductsRepository watchedProductsRepository,
  }) : _watchedProductsRepository = watchedProductsRepository,
       super(FavoritesState.initial());

  final WatchedProductsRepository _watchedProductsRepository;

  Future<void> load() async {
    if (!_watchedProductsRepository.isUserSignedIn) {
      state = state.copyWith(
        isLoading: false,
        isSignedIn: false,
        items: const <FavoriteProductUiModel>[],
        errorText: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, isSignedIn: true, errorText: null);
    try {
      final list = await _watchedProductsRepository
          .fetchProductsForCurrentUser();
      state = state.copyWith(
        isLoading: false,
        items: list.map(_mapToUi).toList(),
        errorText: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        items: const <FavoriteProductUiModel>[],
        errorText: 'Nie udało się wczytać listy: $e',
      );
    }
  }

  FavoriteProductUiModel _mapToUi(WatchedProduct item) {
    return FavoriteProductUiModel(
      sellerVerified: item.sellerVerified,
      product: ProductUiModel(
        id: item.id,
        name: item.name,
        producer: item.producer,
        price: item.price,
        unit: item.unit,
        distance: item.distance,
        season: item.season,
        rating: item.rating,
        reviews: item.reviews,
        emoji: '🧺',
        tag: 'LOKALNE',
        bgColor: AppColors.background,
        tagColor: AppColors.primaryLight,
        sellerId: item.sellerId,
        unitKey: item.unitKey,
        packageQuantity: item.packageQuantity,
        categoryId: item.categoryId,
      ),
    );
  }
}
