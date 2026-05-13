import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokalny_koszyk/core/di/providers.dart';
import 'package:lokalny_koszyk/domain/repositories/product_details_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

final productDetailsViewModelProvider = StateNotifierProvider.autoDispose
    .family<ProductDetailsViewModel, ProductDetailsState, ProductUiModel>((
      ref,
      product,
    ) {
      return ProductDetailsViewModel(
        repository: ref.read(productDetailsRepositoryProvider),
        product: product,
      )..initialize();
    });

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

class ProductDetailsViewModel extends StateNotifier<ProductDetailsState> {
  ProductDetailsViewModel({
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
      state = state.copyWith(isFavorite: false);
      return;
    }
    final liked = await _repository.isFavoriteForCurrentUser(pid);
    state = state.copyWith(isFavorite: liked);
  }

  Future<String?> toggleFavorite() async {
    if (state.favoriteBusy || state.isFavorite == null) return null;
    if (!_repository.isUserSignedIn) {
      return 'Zaloguj się, aby dodać produkt do ulubionych.';
    }
    final pid = _product.id.trim();
    if (pid.isEmpty) return null;

    state = state.copyWith(favoriteBusy: true);
    try {
      final next = await _repository.toggleFavoriteForCurrentUser(
        productId: pid,
        currentlyFavorite: state.isFavorite == true,
      );
      state = state.copyWith(isFavorite: next);
      return null;
    } catch (e) {
      return 'Nie udało się zapisać ulubionych: $e';
    } finally {
      state = state.copyWith(favoriteBusy: false);
    }
  }

  Future<void> _loadSellerNameIfNeeded() async {
    final name = await _repository.resolveSellerName(
      productId: _product.id,
      sellerId: _product.sellerId,
      currentProducerLabel: _product.producer,
    );
    if (name != null && name.trim().isNotEmpty) {
      state = state.copyWith(sellerNameFromDb: name);
    }
  }

  Future<String?> addToCart() async {
    if (state.isAddingToCart) return null;
    state = state.copyWith(isAddingToCart: true);
    try {
      await _repository.addToCart(
        productId: _product.id,
        quantityToAdd: state.selectedQuantity,
      );
      return null;
    } catch (e) {
      return 'Nie udało się dodać do koszyka: $e';
    } finally {
      state = state.copyWith(isAddingToCart: false);
    }
  }

  void increaseQuantity() {
    state = state.copyWith(selectedQuantity: state.selectedQuantity + 1);
  }

  void decreaseQuantity() {
    if (state.selectedQuantity <= 1) return;
    state = state.copyWith(selectedQuantity: state.selectedQuantity - 1);
  }
}
