import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/discover_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

sealed class DiscoverEvent {
  const DiscoverEvent();
}

final class DiscoverLoadProductsRequested extends DiscoverEvent {
  const DiscoverLoadProductsRequested();
}

final class DiscoverAddToCartRequested extends DiscoverEvent {
  const DiscoverAddToCartRequested(this.product);

  final ProductUiModel product;
}

final class DiscoverCategoryToggled extends DiscoverEvent {
  const DiscoverCategoryToggled(this.categoryId);

  final String categoryId;
}

const _unset = Object();

class DiscoverState {
  const DiscoverState({
    required this.activeCategoryId,
    required this.isAddingToCart,
    required this.isLoadingProducts,
    required this.products,
    required this.productsError,
    this.feedbackMessage,
  });

  factory DiscoverState.initial() => const DiscoverState(
    activeCategoryId: null,
    isAddingToCart: false,
    isLoadingProducts: true,
    products: <ProductUiModel>[],
    productsError: null,
  );

  final String? activeCategoryId;
  final bool isAddingToCart;
  final bool isLoadingProducts;
  final List<ProductUiModel> products;
  final String? productsError;
  final String? feedbackMessage;

  List<ProductUiModel> get visibleProducts {
    if (activeCategoryId == null) return products;
    return products
        .where((ProductUiModel p) => p.categoryId == activeCategoryId)
        .toList();
  }

  List<DiscoverCategoryItem> get categoryItems => DiscoverBloc.categoryCatalog
      .map(
        (DiscoverCategoryEntry e) => DiscoverCategoryItem(
          id: e.id,
          iconAsset: e.iconAsset,
          name: e.name,
          count: products
              .where((ProductUiModel p) => p.categoryId == e.id)
              .length,
        ),
      )
      .toList();

  DiscoverState copyWith({
    Object? activeCategoryId = _unset,
    bool? isAddingToCart,
    bool? isLoadingProducts,
    List<ProductUiModel>? products,
    String? productsError,
    Object? feedbackMessage = _unset,
  }) {
    return DiscoverState(
      activeCategoryId: identical(activeCategoryId, _unset)
          ? this.activeCategoryId
          : activeCategoryId as String?,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      products: products ?? this.products,
      productsError: productsError,
      feedbackMessage: identical(feedbackMessage, _unset)
          ? this.feedbackMessage
          : feedbackMessage as String?,
    );
  }
}

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  DiscoverBloc({
    required DiscoverRepository discoverRepository,
    required CartRepository cartRepository,
  }) : _discoverRepository = discoverRepository,
       _cartRepository = cartRepository,
       super(DiscoverState.initial()) {
    on<DiscoverLoadProductsRequested>(_onLoadProducts);
    on<DiscoverAddToCartRequested>(_onAddToCart);
    on<DiscoverCategoryToggled>(_onCategoryToggled);
  }

  final DiscoverRepository _discoverRepository;
  final CartRepository _cartRepository;

  static const List<DiscoverCategoryEntry> categoryCatalog =
      <DiscoverCategoryEntry>[
        DiscoverCategoryEntry(
          id: 'b15939e0-21af-4a14-86fa-d8ee547a07cb',
          iconAsset: 'assets/categories/carrot.svg',
          name: 'Warzywa',
        ),
        DiscoverCategoryEntry(
          id: '5a4aaa6c-4e4e-4ac3-9a4a-250f9ce56ebb',
          iconAsset: 'assets/categories/cherries.svg',
          name: 'Owoce',
        ),
        DiscoverCategoryEntry(
          id: '411e440c-c826-427b-b6dc-78088aae9da4',
          iconAsset: 'assets/categories/egg.svg',
          name: 'Jaja',
        ),
        DiscoverCategoryEntry(
          id: '0b354b99-6e49-442d-8feb-4f00084f4b7a',
          iconAsset: 'assets/categories/cow.svg',
          name: 'Nabiał',
        ),
        DiscoverCategoryEntry(
          id: '8a2dfe1b-c628-4d26-99fa-94e9db6c90f7',
          iconAsset: 'assets/categories/cheese.svg',
          name: 'Sery',
        ),
        DiscoverCategoryEntry(
          id: '8d60ba57-27d0-4311-858f-2bebf56bf3b1',
          iconAsset: 'assets/categories/fork-knife.svg',
          name: 'Mięso',
        ),
        DiscoverCategoryEntry(
          id: '23a2267c-a836-4e6e-b6fa-204583df71c2',
          iconAsset: 'assets/categories/fork-knife.svg',
          name: 'Wędliny',
        ),
        DiscoverCategoryEntry(
          id: '138d5676-9db7-4008-b960-ef69c9d782ac',
          iconAsset: 'assets/categories/bread.svg',
          name: 'Pieczywo',
        ),
        DiscoverCategoryEntry(
          id: 'f3d9f5d1-95c8-4cd3-bcd4-698b4298a22c',
          iconAsset: 'assets/categories/cake.svg',
          name: 'Wypieki',
        ),
        DiscoverCategoryEntry(
          id: '8b65af09-63a9-457f-853b-aa6d523b3085',
          iconAsset: 'assets/categories/pepper.svg',
          name: 'Zioła',
        ),
        DiscoverCategoryEntry(
          id: '54c9b906-4298-413f-8feb-1ef722c86f08',
          iconAsset: 'assets/categories/fish.svg',
          name: 'Ryby',
        ),
        DiscoverCategoryEntry(
          id: '1ed9ab83-ba5f-4c34-b553-88f4616c5994',
          iconAsset: 'assets/categories/feather.svg',
          name: 'Mąki i kasze',
        ),
        DiscoverCategoryEntry(
          id: 'd0e76040-0704-43e6-ac87-593e4d3ffa61',
          iconAsset: 'assets/categories/bug-beetle.svg',
          name: 'Miody',
        ),
        DiscoverCategoryEntry(
          id: '749b3717-19aa-4deb-baec-624060817ee8',
          iconAsset: 'assets/categories/drop.svg',
          name: 'Oleje i octy',
        ),
        DiscoverCategoryEntry(
          id: 'c0d151a7-c635-4a30-ac02-c2eec2a905a4',
          iconAsset: 'assets/categories/jar-label.svg',
          name: 'Przetwory',
        ),
        DiscoverCategoryEntry(
          id: 'db3be1cb-1a43-4481-b253-9a0e9ccc3bfb',
          iconAsset: 'assets/categories/jar-label.svg',
          name: 'Kiszonki',
        ),
        DiscoverCategoryEntry(
          id: '5d538dbd-0d63-4142-b540-6097953d9078',
          iconAsset: 'assets/categories/beer-bottle.svg',
          name: 'Soki i napoje',
        ),
        DiscoverCategoryEntry(
          id: 'c39b5581-4ef2-4be9-b42b-6acb6b63ae79',
          iconAsset: 'assets/categories/pepper.svg',
          name: 'Przyprawy',
        ),
        DiscoverCategoryEntry(
          id: 'd4aaac87-9c19-45f7-ac9e-2ba568ca208f',
          iconAsset: 'assets/categories/oven.svg',
          name: 'Dania gotowe',
        ),
        DiscoverCategoryEntry(
          id: '0af8b69d-b4ed-4b3c-8d40-28687e474793',
          iconAsset: 'assets/categories/paint-brush-household.svg',
          name: 'Rękodzieło',
        ),
        DiscoverCategoryEntry(
          id: 'bb86fb2d-7b8e-4dc4-b22d-0c7dd011a7e4',
          iconAsset: 'assets/categories/potted-plant.svg',
          name: 'Rośliny i ogród',
        ),
      ];

  Future<void> _onLoadProducts(
    DiscoverLoadProductsRequested event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(state.copyWith(isLoadingProducts: true, productsError: null));
    try {
      final products = await _discoverRepository.getActiveProducts();
      emit(
        state.copyWith(
          isLoadingProducts: false,
          products: products.map(ProductUiModel.fromDomain).toList(),
          productsError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingProducts: false,
          products: const <ProductUiModel>[],
          productsError: 'Nie udało się wczytać produktów: $e',
        ),
      );
    }
  }

  Future<void> _onAddToCart(
    DiscoverAddToCartRequested event,
    Emitter<DiscoverState> emit,
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

  void _onCategoryToggled(
    DiscoverCategoryToggled event,
    Emitter<DiscoverState> emit,
  ) {
    emit(
      state.copyWith(
        activeCategoryId: state.activeCategoryId == event.categoryId
            ? null
            : event.categoryId,
      ),
    );
  }
}

class DiscoverCategoryEntry {
  const DiscoverCategoryEntry({
    required this.id,
    required this.iconAsset,
    required this.name,
  });

  final String id;
  final String iconAsset;
  final String name;
}

class DiscoverCategoryItem {
  const DiscoverCategoryItem({
    required this.id,
    required this.iconAsset,
    required this.name,
    required this.count,
  });

  final String id;
  final String iconAsset;
  final String name;
  final int count;
}
