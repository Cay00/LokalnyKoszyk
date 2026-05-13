import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokalny_koszyk/core/di/providers.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/seller.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/home_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModel, HomeState>((ref) {
      return HomeViewModel(
        homeRepository: ref.read(homeRepositoryProvider),
        cartRepository: ref.read(cartRepositoryProvider),
      )..loadSellers();
    });

class HomeState {
  const HomeState({
    required this.nearbySellers,
    required this.featuredProducts,
    required this.cartCount,
    required this.liked,
    required this.isAddingToCart,
  });

  factory HomeState.initial() => HomeState(
    nearbySellers: const AsyncValue<List<Seller>>.loading(),
    featuredProducts: _products,
    cartCount: 0,
    liked: const <String>{},
    isAddingToCart: false,
  );

  final AsyncValue<List<Seller>> nearbySellers;
  final List<ProductUiModel> featuredProducts;
  final int cartCount;
  final Set<String> liked;
  final bool isAddingToCart;

  HomeState copyWith({
    AsyncValue<List<Seller>>? nearbySellers,
    List<ProductUiModel>? featuredProducts,
    int? cartCount,
    Set<String>? liked,
    bool? isAddingToCart,
  }) {
    return HomeState(
      nearbySellers: nearbySellers ?? this.nearbySellers,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      cartCount: cartCount ?? this.cartCount,
      liked: liked ?? this.liked,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel({
    required HomeRepository homeRepository,
    required CartRepository cartRepository,
  }) : _homeRepository = homeRepository,
       _cartRepository = cartRepository,
       super(HomeState.initial());

  final HomeRepository _homeRepository;
  final CartRepository _cartRepository;

  Future<void> loadSellers() async {
    state = state.copyWith(
      nearbySellers: const AsyncValue<List<Seller>>.loading(),
    );
    try {
      final sellers = await _homeRepository.getNearbySellers();
      state = state.copyWith(
        nearbySellers: AsyncValue<List<Seller>>.data(sellers),
      );
    } catch (e, st) {
      state = state.copyWith(
        nearbySellers: AsyncValue<List<Seller>>.error(e, st),
      );
    }
  }

  Future<String?> addToCart(ProductUiModel product) async {
    if (state.isAddingToCart) return null;
    state = state.copyWith(isAddingToCart: true);
    try {
      await _cartRepository.addToCart(productId: product.id);
      state = state.copyWith(cartCount: state.cartCount + 1);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      state = state.copyWith(isAddingToCart: false);
    }
  }

  void toggleLike(String id) {
    final next = <String>{...state.liked};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(liked: next);
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
