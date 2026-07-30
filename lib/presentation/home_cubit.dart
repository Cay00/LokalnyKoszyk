import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/seller.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/home_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

class HomeState {
  const HomeState({
    required this.isLoadingSellers,
    required this.nearbySellers,
    required this.featuredProducts,
    required this.cartCount,
    required this.liked,
    required this.isAddingToCart,
    this.sellersError,
  });

  factory HomeState.initial() => HomeState(
    isLoadingSellers: true,
    nearbySellers: const <Seller>[],
    featuredProducts: _products,
    cartCount: 0,
    liked: const <String>{},
    isAddingToCart: false,
  );

  final bool isLoadingSellers;
  final List<Seller> nearbySellers;
  final Object? sellersError;
  final List<ProductUiModel> featuredProducts;
  final int cartCount;
  final Set<String> liked;
  final bool isAddingToCart;

  HomeState copyWith({
    bool? isLoadingSellers,
    List<Seller>? nearbySellers,
    Object? sellersError = _unset,
    List<ProductUiModel>? featuredProducts,
    int? cartCount,
    Set<String>? liked,
    bool? isAddingToCart,
  }) {
    return HomeState(
      isLoadingSellers: isLoadingSellers ?? this.isLoadingSellers,
      nearbySellers: nearbySellers ?? this.nearbySellers,
      sellersError: identical(sellersError, _unset)
          ? this.sellersError
          : sellersError,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      cartCount: cartCount ?? this.cartCount,
      liked: liked ?? this.liked,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
    );
  }
}

const _unset = Object();

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required HomeRepository homeRepository,
    required CartRepository cartRepository,
  }) : _homeRepository = homeRepository,
       _cartRepository = cartRepository,
       super(HomeState.initial());

  final HomeRepository _homeRepository;
  final CartRepository _cartRepository;

  Future<void> loadSellers() async {
    emit(state.copyWith(isLoadingSellers: true, sellersError: null));
    try {
      final sellers = await _homeRepository.getNearbySellers();
      emit(
        state.copyWith(
          isLoadingSellers: false,
          nearbySellers: sellers,
          sellersError: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingSellers: false, sellersError: e));
    }
  }

  Future<String?> addToCart(ProductUiModel product) async {
    if (state.isAddingToCart) return null;
    emit(state.copyWith(isAddingToCart: true));
    try {
      await _cartRepository.addToCart(productId: product.id);
      emit(state.copyWith(cartCount: state.cartCount + 1));
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      emit(state.copyWith(isAddingToCart: false));
    }
  }

  void toggleLike(String id) {
    final next = <String>{...state.liked};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    emit(state.copyWith(liked: next));
  }
}

const List<ProductUiModel> _products = <ProductUiModel>[
  ProductUiModel(
    id: 'hp1',
    name: 'Rzodkiewka BIO',
    producer: 'Gospodarstwo Zielone Pole',
    price: '7,90',
    unit: '/ pęczek',
    distance: '3 km',
    season: 'Wiosna',
    rating: '4.9',
    reviews: '64',
    emoji: '🌱',
    tag: 'BIO',
    bgColor: AppColors.lightSage,
    tagColor: AppColors.leafGreen,
  ),
  ProductUiModel(
    id: 'hp2',
    name: 'Jajka od szczęśliwych kur',
    producer: 'Farma Pod Lipą',
    price: '13,50',
    unit: '/ 10 szt.',
    distance: '6 km',
    season: 'Cały rok',
    rating: '4.8',
    reviews: '102',
    emoji: '🥚',
    tag: 'REGIONALNE',
    bgColor: AppColors.background,
    tagColor: AppColors.warmBrown,
  ),
];
