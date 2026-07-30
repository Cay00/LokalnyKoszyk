import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/repositories/product_details_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

class ProductDetailsState {
  const ProductDetailsState({
    required this.isFavorite,
    required this.favoriteBusy,
    required this.isAddingToCart,
    required this.selectedQuantity,
    this.sellerNameFromDb,
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

  ProductDetailsState copyWith({
    bool? isFavorite,
    bool? favoriteBusy,
    bool? isAddingToCart,
    int? selectedQuantity,
    String? sellerNameFromDb,
  }) {
    return ProductDetailsState(
      isFavorite: isFavorite ?? this.isFavorite,
      favoriteBusy: favoriteBusy ?? this.favoriteBusy,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      selectedQuantity: selectedQuantity ?? this.selectedQuantity,
      sellerNameFromDb: sellerNameFromDb ?? this.sellerNameFromDb,
    );
  }
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({
    required ProductDetailsRepository repository,
    required ProductUiModel product,
  }) : _repository = repository,
       _product = product,
       super(ProductDetailsState.initial());

  final ProductDetailsRepository _repository;
  final ProductUiModel _product;

  Future<void> initialize() async {
    await Future.wait(<Future<void>>[
      _loadSellerNameIfNeeded(),
      _loadFavoriteState(),
    ]);
  }

  Future<void> _loadFavoriteState() async {
    final pid = _product.id.trim();
    if (pid.isEmpty) {
      emit(state.copyWith(isFavorite: false));
      return;
    }
    final liked = await _repository.isFavoriteForCurrentUser(pid);
    emit(state.copyWith(isFavorite: liked));
  }

  Future<String?> toggleFavorite() async {
    if (state.favoriteBusy || state.isFavorite == null) return null;
    if (!_repository.isUserSignedIn) {
      return 'Zaloguj się, aby dodać produkt do ulubionych.';
    }
    final pid = _product.id.trim();
    if (pid.isEmpty) return null;

    emit(state.copyWith(favoriteBusy: true));
    try {
      final next = await _repository.toggleFavoriteForCurrentUser(
        productId: pid,
        currentlyFavorite: state.isFavorite == true,
      );
      emit(state.copyWith(isFavorite: next));
      return null;
    } catch (e) {
      return 'Nie udało się zapisać ulubionych: $e';
    } finally {
      emit(state.copyWith(favoriteBusy: false));
    }
  }

  Future<void> _loadSellerNameIfNeeded() async {
    final name = await _repository.resolveSellerName(
      productId: _product.id,
      sellerId: _product.sellerId,
      currentProducerLabel: _product.producer,
    );
    if (name != null && name.trim().isNotEmpty) {
      emit(state.copyWith(sellerNameFromDb: name));
    }
  }

  Future<String?> addToCart() async {
    if (state.isAddingToCart) return null;
    emit(state.copyWith(isAddingToCart: true));
    try {
      await _repository.addToCart(
        productId: _product.id,
        quantityToAdd: state.selectedQuantity,
      );
      return null;
    } catch (e) {
      return 'Nie udało się dodać do koszyka: $e';
    } finally {
      emit(state.copyWith(isAddingToCart: false));
    }
  }

  void increaseQuantity() {
    emit(state.copyWith(selectedQuantity: state.selectedQuantity + 1));
  }

  void decreaseQuantity() {
    if (state.selectedQuantity <= 1) return;
    emit(state.copyWith(selectedQuantity: state.selectedQuantity - 1));
  }
}
