import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
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
    items: const <ProductUiModel>[],
    isSignedIn: false,
    errorText: null,
  );

  final bool isLoading;
  final List<ProductUiModel> items;
  final bool isSignedIn;
  final bool isAddingToCart;
  final String? errorText;
  final String? feedbackMessage;

  FavoritesState copyWith({
    bool? isLoading,
    List<ProductUiModel>? items,
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
          items: const <ProductUiModel>[],
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
          items: list.map(ProductUiModel.fromDomain).toList(),
          errorText: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          items: const <ProductUiModel>[],
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
}
