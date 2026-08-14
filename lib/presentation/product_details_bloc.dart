import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/repositories/product_details_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

sealed class ProductDetailsEvent {
  const ProductDetailsEvent();
}

final class ProductDetailsStarted extends ProductDetailsEvent {
  const ProductDetailsStarted();
}

final class ProductDetailsToggleFavoriteRequested extends ProductDetailsEvent {
  const ProductDetailsToggleFavoriteRequested();
}

final class ProductDetailsAddToCartRequested extends ProductDetailsEvent {
  const ProductDetailsAddToCartRequested();
}

final class ProductDetailsIncreaseQuantityRequested
    extends ProductDetailsEvent {
  const ProductDetailsIncreaseQuantityRequested();
}

final class ProductDetailsDecreaseQuantityRequested
    extends ProductDetailsEvent {
  const ProductDetailsDecreaseQuantityRequested();
}

class ProductDetailsState {
  const ProductDetailsState({
    required this.isFavorite,
    required this.favoriteBusy,
    required this.isAddingToCart,
    required this.selectedQuantity,
    this.sellerNameFromDb,
    this.feedbackMessage,
  });

  factory ProductDetailsState.initial() => const ProductDetailsState(
    isFavorite: null,
    favoriteBusy: false,
    isAddingToCart: false,
    selectedQuantity: 1,
  );

  final bool? isFavorite;
  final bool favoriteBusy;
  final bool isAddingToCart;
  final int selectedQuantity;
  final String? sellerNameFromDb;
  final String? feedbackMessage;

  ProductDetailsState copyWith({
    bool? isFavorite,
    bool? favoriteBusy,
    bool? isAddingToCart,
    int? selectedQuantity,
    String? sellerNameFromDb,
    Object? feedbackMessage = _unset,
  }) {
    return ProductDetailsState(
      isFavorite: isFavorite ?? this.isFavorite,
      favoriteBusy: favoriteBusy ?? this.favoriteBusy,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      selectedQuantity: selectedQuantity ?? this.selectedQuantity,
      sellerNameFromDb: sellerNameFromDb ?? this.sellerNameFromDb,
      feedbackMessage: identical(feedbackMessage, _unset)
          ? this.feedbackMessage
          : feedbackMessage as String?,
    );
  }
}

const _unset = Object();

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  ProductDetailsBloc({
    required ProductDetailsRepository repository,
    required ProductUiModel product,
  }) : _repository = repository,
       _product = product,
       super(ProductDetailsState.initial()) {
    on<ProductDetailsStarted>(_onStarted);
    on<ProductDetailsToggleFavoriteRequested>(_onToggleFavorite);
    on<ProductDetailsAddToCartRequested>(_onAddToCart);
    on<ProductDetailsIncreaseQuantityRequested>(_onIncreaseQuantity);
    on<ProductDetailsDecreaseQuantityRequested>(_onDecreaseQuantity);
  }

  final ProductDetailsRepository _repository;
  final ProductUiModel _product;

  Future<void> _onStarted(
    ProductDetailsStarted event,
    Emitter<ProductDetailsState> emit,
  ) async {
    await _loadSellerNameIfNeeded(emit);
    await _loadFavoriteState(emit);
  }

  Future<void> _loadFavoriteState(Emitter<ProductDetailsState> emit) async {
    final pid = _product.id.trim();
    if (pid.isEmpty) {
      emit(state.copyWith(isFavorite: false));
      return;
    }
    final liked = await _repository.isFavoriteForCurrentUser(pid);
    emit(state.copyWith(isFavorite: liked));
  }

  Future<void> _onToggleFavorite(
    ProductDetailsToggleFavoriteRequested event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state.favoriteBusy || state.isFavorite == null) return;
    if (!_repository.isUserSignedIn) {
      emit(
        state.copyWith(
          feedbackMessage: 'Zaloguj się, aby dodać produkt do ulubionych.',
        ),
      );
      return;
    }
    final pid = _product.id.trim();
    if (pid.isEmpty) return;

    emit(state.copyWith(favoriteBusy: true, feedbackMessage: null));
    try {
      final next = await _repository.toggleFavoriteForCurrentUser(
        productId: pid,
        currentlyFavorite: state.isFavorite == true,
      );
      emit(state.copyWith(isFavorite: next, favoriteBusy: false));
    } catch (e) {
      emit(
        state.copyWith(
          favoriteBusy: false,
          feedbackMessage: 'Nie udało się zapisać ulubionych: $e',
        ),
      );
    }
  }

  Future<void> _loadSellerNameIfNeeded(
    Emitter<ProductDetailsState> emit,
  ) async {
    final name = await _repository.resolveSellerName(
      productId: _product.id,
      sellerId: _product.sellerId,
      currentProducerLabel: _product.producer,
    );
    if (name != null && name.trim().isNotEmpty) {
      emit(state.copyWith(sellerNameFromDb: name));
    }
  }

  Future<void> _onAddToCart(
    ProductDetailsAddToCartRequested event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state.isAddingToCart) return;
    emit(state.copyWith(isAddingToCart: true, feedbackMessage: null));
    final qty = state.selectedQuantity;
    try {
      await _repository.addToCart(
        productId: _product.id,
        quantityToAdd: qty,
      );
      emit(
        state.copyWith(
          isAddingToCart: false,
          feedbackMessage: 'Dodano do koszyka: ${_product.name} x$qty',
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

  void _onIncreaseQuantity(
    ProductDetailsIncreaseQuantityRequested event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state.selectedQuantity >= 99) return;
    emit(state.copyWith(selectedQuantity: state.selectedQuantity + 1));
  }

  void _onDecreaseQuantity(
    ProductDetailsDecreaseQuantityRequested event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state.selectedQuantity <= 1) return;
    emit(state.copyWith(selectedQuantity: state.selectedQuantity - 1));
  }
}
