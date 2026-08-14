import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/watched_product.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
import 'package:lokalny_koszyk/presentation/models/favorite_product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

sealed class FavoritesEvent {
  const FavoritesEvent();
}

final class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested();
}

final class FavoritesAddToCartRequested extends FavoritesEvent {
  const FavoritesAddToCartRequested(this.product);

  final ProductUiModel product;
}

class FavoritesState {
  const FavoritesState({
    required this.isLoading,
    required this.items,
    required this.isSignedIn,
    this.isAddingToCart = false,
    this.errorText,
    this.feedbackMessage,
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
  final bool isAddingToCart;
  final String? errorText;
  final String? feedbackMessage;

  FavoritesState copyWith({
    bool? isLoading,
    List<FavoriteProductUiModel>? items,
    bool? isSignedIn,
    bool? isAddingToCart,
    String? errorText,
    String? feedbackMessage,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      errorText: errorText,
      feedbackMessage: feedbackMessage,
    );
  }
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({
    required WatchedProductsRepository watchedProductsRepository,
    required CartRepository cartRepository,
  }) : _watchedProductsRepository = watchedProductsRepository,
       _cartRepository = cartRepository,
       super(FavoritesState.initial()) {
    on<FavoritesLoadRequested>(_onLoad);
    on<FavoritesAddToCartRequested>(_onAddToCart);
  }

  final WatchedProductsRepository _watchedProductsRepository;
  final CartRepository _cartRepository;

  Future<void> _onLoad(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    if (!_watchedProductsRepository.isUserSignedIn) {
      emit(
        state.copyWith(
          isLoading: false,
          isSignedIn: false,
          items: const <FavoriteProductUiModel>[],
          errorText: null,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, isSignedIn: true, errorText: null));
    try {
      final list = await _watchedProductsRepository
          .fetchProductsForCurrentUser();
      emit(
        state.copyWith(
          isLoading: false,
          items: list.map(_mapToUi).toList(),
          errorText: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          items: const <FavoriteProductUiModel>[],
          errorText: 'Nie udało się wczytać listy: $e',
        ),
      );
    }
  }

  Future<void> _onAddToCart(
    FavoritesAddToCartRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state.isAddingToCart) return;
    emit(state.copyWith(isAddingToCart: true, feedbackMessage: null));
    try {
      await _cartRepository.addToCart(productId: event.product.id);
      emit(
        state.copyWith(
          isAddingToCart: false,
          feedbackMessage: 'Dodano do koszyka: ${event.product.name}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAddingToCart: false,
          feedbackMessage: 'Nie udało się dodać do koszyka: $e',
        ),
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
        tagColor: AppColors.accent,
        sellerId: item.sellerId,
        unitKey: item.unitKey,
        packageQuantity: item.packageQuantity,
        categoryId: item.categoryId,
      ),
    );
  }
}
