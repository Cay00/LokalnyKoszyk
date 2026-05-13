import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokalny_koszyk/core/di/providers.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/discover_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

const _unset = Object();

final discoverViewModelProvider =
    StateNotifierProvider.autoDispose<DiscoverViewModel, DiscoverState>((ref) {
      return DiscoverViewModel(
        discoverRepository: ref.read(discoverRepositoryProvider),
        cartRepository: ref.read(cartRepositoryProvider),
      )..loadProducts();
    });

class DiscoverState {
  const DiscoverState({
    required this.cartCount,
    required this.activeFilter,
    required this.activeCategoryId,
    required this.liked,
    required this.isAddingToCart,
    required this.isLoadingProducts,
    required this.products,
    required this.productsError,
  });

  factory DiscoverState.initial() => const DiscoverState(
    cartCount: 0,
    activeFilter: 'Wszystkie',
    activeCategoryId: null,
    liked: <String>{},
    isAddingToCart: false,
    isLoadingProducts: true,
    products: <ProductUiModel>[],
    productsError: null,
  );

  final int cartCount;
  final String activeFilter;
  final String? activeCategoryId;
  final Set<String> liked;
  final bool isAddingToCart;
  final bool isLoadingProducts;
  final List<ProductUiModel> products;
  final String? productsError;

  List<ProductUiModel> get visibleProducts {
    List<ProductUiModel> list;
    if (activeFilter == 'Wszystkie') {
      list = products;
    } else {
      final needle = activeFilter.toUpperCase();
      list = products
          .where(
            (ProductUiModel p) =>
                p.tag.contains(needle) || p.name.toUpperCase().contains(needle),
          )
          .toList();
    }
    if (activeCategoryId != null) {
      list = list
          .where((ProductUiModel p) => p.categoryId == activeCategoryId)
          .toList();
    }
    return list;
  }

  DiscoverState copyWith({
    int? cartCount,
    String? activeFilter,
    Object? activeCategoryId = _unset,
    Set<String>? liked,
    bool? isAddingToCart,
    bool? isLoadingProducts,
    List<ProductUiModel>? products,
    String? productsError,
  }) {
    return DiscoverState(
      cartCount: cartCount ?? this.cartCount,
      activeFilter: activeFilter ?? this.activeFilter,
      activeCategoryId: identical(activeCategoryId, _unset)
          ? this.activeCategoryId
          : activeCategoryId as String?,
      liked: liked ?? this.liked,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      products: products ?? this.products,
      productsError: productsError,
    );
  }
}

class DiscoverViewModel extends StateNotifier<DiscoverState> {
  DiscoverViewModel({
    required DiscoverRepository discoverRepository,
    required CartRepository cartRepository,
  }) : _discoverRepository = discoverRepository,
       _cartRepository = cartRepository,
       super(DiscoverState.initial());

  final DiscoverRepository _discoverRepository;
  final CartRepository _cartRepository;

  static const List<String> filters = <String>[
    'Wszystkie',
    'BIO',
    'Regionalne',
    'Sezonowe',
  ];

  static const List<DiscoverCategoryEntry> categoryCatalog =
      <DiscoverCategoryEntry>[
        DiscoverCategoryEntry(
          id: 'b15939e0-21af-4a14-86fa-d8ee547a07cb',
          icon: '🥕',
          name: 'Warzywa',
        ),
        DiscoverCategoryEntry(
          id: '5a4aaa6c-4e4e-4ac3-9a4a-250f9ce56ebb',
          icon: '🍎',
          name: 'Owoce',
        ),
        DiscoverCategoryEntry(
          id: '411e440c-c826-427b-b6dc-78088aae9da4',
          icon: '🥚',
          name: 'Jaja',
        ),
        DiscoverCategoryEntry(
          id: '0b354b99-6e49-442d-8feb-4f00084f4b7a',
          icon: '🥛',
          name: 'Nabiał',
        ),
        DiscoverCategoryEntry(
          id: '8a2dfe1b-c628-4d26-99fa-94e9db6c90f7',
          icon: '🧀',
          name: 'Sery',
        ),
        DiscoverCategoryEntry(
          id: '8d60ba57-27d0-4311-858f-2bebf56bf3b1',
          icon: '🥩',
          name: 'Mięso',
        ),
        DiscoverCategoryEntry(
          id: '23a2267c-a836-4e6e-b6fa-204583df71c2',
          icon: '🥓',
          name: 'Wędliny',
        ),
        DiscoverCategoryEntry(
          id: '138d5676-9db7-4008-b960-ef69c9d782ac',
          icon: '🍞',
          name: 'Pieczywo',
        ),
        DiscoverCategoryEntry(
          id: 'f3d9f5d1-95c8-4cd3-bcd4-698b4298a22c',
          icon: '🥐',
          name: 'Wypieki',
        ),
        DiscoverCategoryEntry(
          id: '8b65af09-63a9-457f-853b-aa6d523b3085',
          icon: '🌿',
          name: 'Zioła',
        ),
        DiscoverCategoryEntry(
          id: '54c9b906-4298-413f-8feb-1ef722c86f08',
          icon: '🐟',
          name: 'Ryby',
        ),
        DiscoverCategoryEntry(
          id: '1ed9ab83-ba5f-4c34-b553-88f4616c5994',
          icon: '🌾',
          name: 'Mąki i kasze',
        ),
        DiscoverCategoryEntry(
          id: 'd0e76040-0704-43e6-ac87-593e4d3ffa61',
          icon: '🍯',
          name: 'Miody',
        ),
        DiscoverCategoryEntry(
          id: '749b3717-19aa-4deb-baec-624060817ee8',
          icon: '🫒',
          name: 'Oleje i octy',
        ),
        DiscoverCategoryEntry(
          id: 'c0d151a7-c635-4a30-ac02-c2eec2a905a4',
          icon: '🥫',
          name: 'Przetwory',
        ),
        DiscoverCategoryEntry(
          id: 'db3be1cb-1a43-4481-b253-9a0e9ccc3bfb',
          icon: '🥒',
          name: 'Kiszonki',
        ),
        DiscoverCategoryEntry(
          id: '5d538dbd-0d63-4142-b540-6097953d9078',
          icon: '🧃',
          name: 'Soki i napoje',
        ),
        DiscoverCategoryEntry(
          id: 'c39b5581-4ef2-4be9-b42b-6acb6b63ae79',
          icon: '🌶️',
          name: 'Przyprawy',
        ),
        DiscoverCategoryEntry(
          id: 'd4aaac87-9c19-45f7-ac9e-2ba568ca208f',
          icon: '🍱',
          name: 'Dania gotowe',
        ),
        DiscoverCategoryEntry(
          id: '0af8b69d-b4ed-4b3c-8d40-28687e474793',
          icon: '🧺',
          name: 'Rękodzieło',
        ),
        DiscoverCategoryEntry(
          id: 'bb86fb2d-7b8e-4dc4-b22d-0c7dd011a7e4',
          icon: '🪴',
          name: 'Rośliny i ogród',
        ),
      ];

  List<DiscoverCategoryItem> get categoryItems => categoryCatalog
      .map(
        (DiscoverCategoryEntry e) => DiscoverCategoryItem(
          id: e.id,
          icon: e.icon,
          name: e.name,
          count: state.products
              .where((ProductUiModel p) => p.categoryId == e.id)
              .length,
        ),
      )
      .toList();

  Future<void> loadProducts() async {
    state = state.copyWith(isLoadingProducts: true, productsError: null);
    try {
      final products = await _discoverRepository.getActiveProducts();
      state = state.copyWith(
        isLoadingProducts: false,
        products: products.map(_toUi).toList(),
        productsError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProducts: false,
        products: const <ProductUiModel>[],
        productsError: 'Nie udało się wczytać produktów: $e',
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
      return 'Nie udało się dodać do koszyka: $e';
    } finally {
      state = state.copyWith(isAddingToCart: false);
    }
  }

  void setActiveFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void toggleCategory(String categoryId) {
    state = state.copyWith(
      activeCategoryId: state.activeCategoryId == categoryId
          ? null
          : categoryId,
    );
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

  ProductUiModel _toUi(Product product) {
    return ProductUiModel(
      id: product.id,
      name: product.name,
      producer: product.producer,
      price: product.price,
      unit: product.unit,
      distance: product.distance,
      season: product.season,
      rating: product.rating,
      reviews: product.reviews,
      emoji: '🧺',
      tag: 'LOKALNE',
      bgColor: AppColors.background,
      tagColor: AppColors.primaryLight,
      sellerId: product.sellerId,
      unitKey: product.unitKey,
      packageQuantity: product.packageQuantity,
      categoryId: product.categoryId,
    );
  }
}

class DiscoverCategoryEntry {
  const DiscoverCategoryEntry({
    required this.id,
    required this.icon,
    required this.name,
  });

  final String id;
  final String icon;
  final String name;
}

class DiscoverCategoryItem {
  const DiscoverCategoryItem({
    required this.id,
    required this.icon,
    required this.name,
    required this.count,
  });

  final String id;
  final String icon;
  final String name;
  final int count;
}
