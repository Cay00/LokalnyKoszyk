import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/place_order_result.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/discover_repository.dart';
import 'package:lokalny_koszyk/presentation/discover_bloc.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

class _FakeDiscoverRepository implements DiscoverRepository {
  _FakeDiscoverRepository(this.products, {this.error});

  final List<Product> products;
  final Object? error;

  @override
  Future<List<Product>> getActiveProducts() async {
    if (error != null) throw error!;
    return products;
  }
}

class _FakeCartRepository implements CartRepository {
  Object? addError;
  final List<String> addedProductIds = <String>[];

  @override
  Future<void> addToCart({
    required String productId,
    int quantityToAdd = 1,
  }) async {
    if (addError != null) throw addError!;
    addedProductIds.add(productId);
  }

  @override
  Future<List<CartItem>> getCartItemsForCurrentUser() async =>
      const <CartItem>[];

  @override
  Future<void> removeCartItem({required String cartItemId}) async {}

  @override
  Future<PlaceOrderResult> placeOrderFromCurrentCart({
    required String status,
  }) async {
    throw UnimplementedError();
  }
}

Product _product({
  required String id,
  String categoryId = 'cat-a',
  String name = 'Produkt',
  double? distanceMeters,
}) {
  return Product(
    id: id,
    name: name,
    producer: 'Producent',
    price: '10,00',
    unit: '/ szt.',
    distance: '',
    rating: '5.0',
    reviews: '1',
    categoryId: categoryId,
    distanceMeters: distanceMeters,
  );
}

void main() {
  late _FakeCartRepository cart;

  setUp(() {
    cart = _FakeCartRepository();
  });

  test('loads products into state', () async {
    final bloc = DiscoverBloc(
      discoverRepository: _FakeDiscoverRepository(<Product>[
        _product(id: '1'),
        _product(id: '2', categoryId: 'cat-b'),
      ]),
      cartRepository: cart,
    );

    bloc.add(const DiscoverLoadProductsRequested());
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<DiscoverState>(
          (DiscoverState s) =>
              !s.isLoadingProducts &&
              s.products.length == 2 &&
              s.productsError == null,
        ),
      ),
    );
    await bloc.close();
  });

  test('surfaces load error', () async {
    final bloc = DiscoverBloc(
      discoverRepository: _FakeDiscoverRepository(
        const <Product>[],
        error: Exception('offline'),
      ),
      cartRepository: cart,
    );

    bloc.add(const DiscoverLoadProductsRequested());
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<DiscoverState>(
          (DiscoverState s) =>
              !s.isLoadingProducts &&
              s.products.isEmpty &&
              (s.productsError?.contains('Nie udało się wczytać') ?? false),
        ),
      ),
    );
    await bloc.close();
  });

  test('toggles category filter and visibleProducts', () async {
    final products = <Product>[
      _product(id: '1', categoryId: 'cat-a'),
      _product(id: '2', categoryId: 'cat-b'),
    ];
    final bloc = DiscoverBloc(
      discoverRepository: _FakeDiscoverRepository(products),
      cartRepository: cart,
    );

    bloc.add(const DiscoverLoadProductsRequested());
    await bloc.stream.firstWhere((DiscoverState s) => !s.isLoadingProducts);

    bloc.add(const DiscoverCategoryToggled('cat-a'));
    await expectLater(
      bloc.stream,
      emits(
        predicate<DiscoverState>(
          (DiscoverState s) =>
              s.activeCategoryId == 'cat-a' && s.visibleProducts.length == 1,
        ),
      ),
    );

    bloc.add(const DiscoverCategoryToggled('cat-a'));
    await expectLater(
      bloc.stream,
      emits(
        predicate<DiscoverState>(
          (DiscoverState s) =>
              s.activeCategoryId == null && s.visibleProducts.length == 2,
        ),
      ),
    );
    await bloc.close();
  });

  test('filters products by distance', () async {
    final products = <Product>[
      _product(id: 'near', distanceMeters: 5 * 1000),
      _product(id: 'far', distanceMeters: 80 * 1000),
      _product(id: 'unknown'),
    ];
    final bloc = DiscoverBloc(
      discoverRepository: _FakeDiscoverRepository(products),
      cartRepository: cart,
    );

    bloc.add(const DiscoverLoadProductsRequested());
    await bloc.stream.firstWhere((DiscoverState s) => !s.isLoadingProducts);

    bloc.add(
      const DiscoverFiltersApplied(
        priceFilter: DiscoverPriceFilter.all,
        distanceFilter: DiscoverDistanceFilter.upTo25,
        sortOption: DiscoverSortOption.recommended,
      ),
    );
    await expectLater(
      bloc.stream,
      emits(
        predicate<DiscoverState>((DiscoverState s) {
          final ids = s.visibleProducts.map((p) => p.id).toList();
          return s.distanceFilter == DiscoverDistanceFilter.upTo25 &&
              ids.length == 1 &&
              ids.single == 'near';
        }),
      ),
    );
    await bloc.close();
  });

  test('add to cart success sets feedback', () async {
    final bloc = DiscoverBloc(
      discoverRepository: _FakeDiscoverRepository(const <Product>[]),
      cartRepository: cart,
    );
    final ui = ProductUiModel.fromDomain(_product(id: 'p1', name: 'Buraki'));

    bloc.add(DiscoverAddToCartRequested(ui));
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<DiscoverState>(
          (DiscoverState s) =>
              !s.isAddingToCart &&
              s.feedbackMessage == 'Dodano do koszyka: Buraki',
        ),
      ),
    );
    expect(cart.addedProductIds, <String>['p1']);
    await bloc.close();
  });
}
