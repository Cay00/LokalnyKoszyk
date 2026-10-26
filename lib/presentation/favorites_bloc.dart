import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/favorite_seller.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_sellers_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

enum FavoritesTabKind { products, sellers }

sealed class FavoritesEvent {
  const FavoritesEvent();
}

final class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested({this.silent = false});

  /// Bez pełnego spinnera (np. po przełączeniu zakładki).
  final bool silent;
}

final class FavoritesTabChanged extends FavoritesEvent {
  const FavoritesTabChanged(this.tab);

  final FavoritesTabKind tab;
}

final class FavoritesAddToCartRequested extends FavoritesEvent {
  const FavoritesAddToCartRequested(this.product);

  final ProductUiModel product;
}

final class FavoritesRemoveSellerRequested extends FavoritesEvent {
  const FavoritesRemoveSellerRequested(this.sellerId);

  final String sellerId;
}

class FavoritesState {
  const FavoritesState({
    required this.isLoading,
    required this.items,
    required this.sellers,
    required this.isSignedIn,
    required this.activeTab,
    this.refreshGeneration = 0,
    this.isAddingToCart = false,
    this.errorText,
    this.feedbackMessage,
  });

  factory FavoritesState.initial() => const FavoritesState(
    isLoading: true,
    items: <ProductUiModel>[],
    sellers: <FavoriteSeller>[],
    isSignedIn: false,
    activeTab: FavoritesTabKind.products,
    errorText: null,
  );

  final bool isLoading;
  final List<ProductUiModel> items;
  final List<FavoriteSeller> sellers;
  final bool isSignedIn;
  final FavoritesTabKind activeTab;
  final int refreshGeneration;
  final bool isAddingToCart;
  final String? errorText;
  final String? feedbackMessage;

  FavoritesState copyWith({
    bool? isLoading,
    List<ProductUiModel>? items,
    List<FavoriteSeller>? sellers,
    bool? isSignedIn,
    FavoritesTabKind? activeTab,
    int? refreshGeneration,
    bool? isAddingToCart,
    String? errorText,
    String? feedbackMessage,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      sellers: sellers ?? this.sellers,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      activeTab: activeTab ?? this.activeTab,
      refreshGeneration: refreshGeneration ?? this.refreshGeneration,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      errorText: errorText,
      feedbackMessage: feedbackMessage,
    );
  }
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({
    required WatchedProductsRepository watchedProductsRepository,
    required WatchedSellersRepository watchedSellersRepository,
    required CartRepository cartRepository,
  }) : _watchedProductsRepository = watchedProductsRepository,
       _watchedSellersRepository = watchedSellersRepository,
       _cartRepository = cartRepository,
       super(FavoritesState.initial()) {
    on<FavoritesLoadRequested>(_onLoad);
    on<FavoritesTabChanged>(_onTabChanged);
    on<FavoritesAddToCartRequested>(_onAddToCart);
    on<FavoritesRemoveSellerRequested>(_onRemoveSeller);
  }

  final WatchedProductsRepository _watchedProductsRepository;
  final WatchedSellersRepository _watchedSellersRepository;
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
          items: const <ProductUiModel>[],
          sellers: const <FavoriteSeller>[],
          errorText: null,
          refreshGeneration: state.refreshGeneration + 1,
        ),
      );
      return;
    }

    final bool keepExisting =
        event.silent && (state.items.isNotEmpty || state.sellers.isNotEmpty);
    emit(
      state.copyWith(
        isLoading: !keepExisting,
        isSignedIn: true,
        errorText: null,
      ),
    );
    try {
      final products = await _watchedProductsRepository
          .fetchProductsForCurrentUser();
      List<FavoriteSeller> sellers = const <FavoriteSeller>[];
      try {
        sellers = await _watchedSellersRepository.fetchSellersForCurrentUser();
      } catch (_) {
        sellers = const <FavoriteSeller>[];
      }
      emit(
        state.copyWith(
          isLoading: false,
          items: products.map(ProductUiModel.fromDomain).toList(),
          sellers: sellers,
          errorText: null,
          refreshGeneration: state.refreshGeneration + 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          items: keepExisting ? state.items : const <ProductUiModel>[],
          sellers: keepExisting ? state.sellers : const <FavoriteSeller>[],
          errorText: 'Nie udało się wczytać listy: $e',
          refreshGeneration: state.refreshGeneration + 1,
        ),
      );
    }
  }

  void _onTabChanged(
    FavoritesTabChanged event,
    Emitter<FavoritesState> emit,
  ) {
    emit(state.copyWith(activeTab: event.tab));
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

  Future<void> _onRemoveSeller(
    FavoritesRemoveSellerRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _watchedSellersRepository.removeFavoriteForCurrentUser(
        event.sellerId,
      );
      emit(
        state.copyWith(
          sellers: state.sellers
              .where((FavoriteSeller s) => s.id != event.sellerId)
              .toList(),
          feedbackMessage: 'Usunięto sprzedawcę z ulubionych',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          feedbackMessage: 'Nie udało się usunąć sprzedawcy: $e',
        ),
      );
    }
  }
}
