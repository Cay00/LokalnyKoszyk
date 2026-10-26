import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/discover_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_sellers_repository.dart';
import 'package:lokalny_koszyk/presentation/checkout_bloc.dart';
import 'package:lokalny_koszyk/presentation/discover_bloc.dart';
import 'package:lokalny_koszyk/presentation/favorites_bloc.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/my_orders_bloc.dart';
import 'package:lokalny_koszyk/presentation/order_history_detail_bloc.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/widgets/app_bottom_navigation_bar.dart';
import 'package:lokalny_koszyk/screens/checkout/order_checkout_screen.dart';
import 'package:lokalny_koszyk/screens/checkout/orders_screen.dart';
import 'package:lokalny_koszyk/screens/profile/order_history/order_history_detail_screen.dart';
import 'package:lokalny_koszyk/screens/profile/order_history/order_history_screen.dart';
import 'package:lokalny_koszyk/screens/home/discover_screen.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';
import 'package:lokalny_koszyk/screens/profile/addresses_screen.dart';
import 'package:lokalny_koszyk/screens/profile/seller_panel_screen.dart';
import 'package:lokalny_koszyk/screens/profile/favorites_screen.dart';
import 'package:lokalny_koszyk/screens/profile/developer_screen.dart';
import 'package:lokalny_koszyk/screens/profile/help_screen.dart';
import 'package:lokalny_koszyk/screens/profile/my_reviews_screen.dart';
import 'package:lokalny_koszyk/screens/profile/preferences_screen.dart';
import 'package:lokalny_koszyk/screens/profile/profile_screen.dart';

// GŁÓWNY ROUTER APLIKACJI
// Odpowiada za:
// - zarządzanie bottom navigation
// - utrzymywanie osobnych stacków nawigacji dla każdego taba
// - obsługę przycisku back (Android)
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  // aktualnie wybrany tab
  int _selectedIndex = 0;

  // osobne Navigatory dla każdego taba (klucz do niezależnych stacków)
  final GlobalKey<NavigatorState> _shopNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _cartNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _favoritesNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

  void _onTabStackChanged() {
    if (mounted) setState(() {});
  }

  // Osobny observer na każdy Navigator (Flutter nie pozwala dzielić jednej instancji).
  late final List<NavigatorObserver> _navObservers = List<NavigatorObserver>.generate(
    4,
    (_) => _TabStackObserver(_onTabStackChanged),
  );

  // lista navigatorów dla łatwego dostępu po indeksie
  List<GlobalKey<NavigatorState>> get _navigatorKeys => [
    _shopNavigatorKey,
    _cartNavigatorKey,
    _favoritesNavigatorKey,
    _profileNavigatorKey,
  ];

  bool get _hideBottomNav =>
      _navigatorKeys[_selectedIndex].currentState?.canPop() ?? false;

  // OBSŁUGA BACK BUTTONA
  // kolejność:
  // 1. jeśli można cofnąć w aktualnym tabie → pop
  // 2. jeśli nie i nie jesteśmy na Home → przełącz na Home
  // 3. jeśli Home → blokuj wyjście (tu można dodać double back exit)
  Future<bool> _onWillPop() async {
    final navigator = _navigatorKeys[_selectedIndex].currentState;

    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }

    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool hideBottomNav = _hideBottomNav;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // styl status bara
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        // przechwycenie systemowego back
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _onWillPop();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // manualne ustawienie koloru pod status barem
                  Container(
                    height: MediaQuery.paddingOf(context).top,
                    color: AppColors.background,
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        DiscoverTab(
                          navigatorKey: _shopNavigatorKey,
                          isActive: _selectedIndex == 0,
                          navigatorObserver: _navObservers[0],
                        ),
                        OrdersTab(
                          navigatorKey: _cartNavigatorKey,
                          isActive: _selectedIndex == 1,
                          navigatorObserver: _navObservers[1],
                        ),
                        FavoritesTab(
                          navigatorKey: _favoritesNavigatorKey,
                          isActive: _selectedIndex == 2,
                          navigatorObserver: _navObservers[2],
                        ),
                        ProfileTab(
                          navigatorKey: _profileNavigatorKey,
                          navigatorObserver: _navObservers[3],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!hideBottomNav)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AppBottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: (index) => setState(() => _selectedIndex = index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabStackObserver extends NavigatorObserver {
  _TabStackObserver(this.onStackChanged);

  final VoidCallback onStackChanged;

  void _notify() {
    // Po frame — canPop() jest już aktualne.
    WidgetsBinding.instance.addPostFrameCallback((_) => onStackChanged());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _notify();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _notify();
}

// ROUTE BEZ ANIMACJI
// używany zamiast MaterialPageRoute, żeby uniknąć animacji między ekranami
class _NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  _NoAnimationPageRoute({required WidgetBuilder builder})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

// Pomocnicze: czy produkt ma niepusty sellerId.
bool _hasSellerId(ProductUiModel product) {
  final String? sellerId = product.sellerId;
  return sellerId != null && sellerId.isNotEmpty;
}

// Pomocnicze: push ekranu producenta w aktualnym stacku (taba).
void _pushProducerDetails(BuildContext context, String sellerId) {
  Navigator.push(
    context,
    _NoAnimationPageRoute<void>(
      builder: (_) => ProducerDetailsScreen(
        sellerId: sellerId,
        onBack: () => Navigator.pop(context),
      ),
    ),
  );
}

// ------------------ SHOP TAB (Sklep) ------------------
class DiscoverTab extends StatefulWidget {
  const DiscoverTab({
    required this.navigatorKey,
    required this.isActive,
    required this.navigatorObserver,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final bool isActive;
  final NavigatorObserver navigatorObserver;

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscoverBloc(
        discoverRepository: context.read<DiscoverRepository>(),
        cartRepository: context.read<CartRepository>(),
      )..add(const DiscoverLoadProductsRequested()),
      child: _TabRefreshOnActivate(
        isActive: widget.isActive,
        onActivate: (BuildContext context) {
          context.read<DiscoverBloc>().add(
            const DiscoverLoadProductsRequested(),
          );
        },
        child: Navigator(
          key: widget.navigatorKey,
          observers: <NavigatorObserver>[widget.navigatorObserver],
          onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
            builder: (_) => const _DiscoverNavigator(),
          ),
        ),
      ),
    );
  }
}

// root navigator dla Sklepu
class _DiscoverNavigator extends StatelessWidget {
  const _DiscoverNavigator();

  @override
  Widget build(BuildContext context) {
    return DiscoverScreen(
      onOpenProductDetails: (product) {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => ProductDetailsScreen(
              product: product,
              onBack: () => Navigator.pop(context),
              onOpenProducerDetails: _hasSellerId(product)
                  ? () => _pushProducerDetails(context, product.sellerId!)
                  : null,
            ),
          ),
        );
      },
    );
  }
}

// ------------------ CART TAB (Koszyk) ------------------
class OrdersTab extends StatefulWidget {
  const OrdersTab({
    required this.navigatorKey,
    required this.isActive,
    required this.navigatorObserver,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final bool isActive;
  final NavigatorObserver navigatorObserver;

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return OrdersBloc(
          cartRepository: context.read<CartRepository>(),
        )..add(const OrdersLoadCartRequested());
      },
      child: _TabRefreshOnActivate(
        isActive: widget.isActive,
        onActivate: (BuildContext context) {
          context.read<OrdersBloc>().add(const OrdersLoadCartRequested());
        },
        child: Navigator(
          key: widget.navigatorKey,
          observers: <NavigatorObserver>[widget.navigatorObserver],
          onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
            builder: (_) => const _OrdersNavigator(),
          ),
        ),
      ),
    );
  }
}

// root navigator dla Koszyka
class _OrdersNavigator extends StatelessWidget {
  const _OrdersNavigator();

  @override
  Widget build(BuildContext context) {
    return OrdersScreen(
      onOpenCheckout: () {
        final selectedIds = context
            .read<OrdersBloc>()
            .state
            .selectedCartItems
            .map((item) => item.id)
            .toList();
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (context) => CheckoutBloc(
                cartRepository: context.read<CartRepository>(),
              )..add(CheckoutLoadRequested(selectedCartItemIds: selectedIds)),
              child: OrderCheckoutScreen(
                onBack: () => Navigator.pop(context),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Odświeża dane zakładki po każdym wejściu (IndexedStack trzyma stan).
class _TabRefreshOnActivate extends StatefulWidget {
  const _TabRefreshOnActivate({
    required this.isActive,
    required this.onActivate,
    required this.child,
  });

  final bool isActive;
  final void Function(BuildContext context) onActivate;
  final Widget child;

  @override
  State<_TabRefreshOnActivate> createState() => _TabRefreshOnActivateState();
}

class _TabRefreshOnActivateState extends State<_TabRefreshOnActivate> {
  @override
  void didUpdateWidget(covariant _TabRefreshOnActivate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      widget.onActivate(context);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ------------------ FAVORITES TAB (Ulubione) ------------------
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({
    required this.navigatorKey,
    required this.isActive,
    required this.navigatorObserver,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final bool isActive;
  final NavigatorObserver navigatorObserver;

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesBloc(
        watchedProductsRepository: context.read<WatchedProductsRepository>(),
        watchedSellersRepository: context.read<WatchedSellersRepository>(),
        cartRepository: context.read<CartRepository>(),
      )..add(const FavoritesLoadRequested()),
      child: _TabRefreshOnActivate(
        isActive: widget.isActive,
        onActivate: (BuildContext context) {
          context.read<FavoritesBloc>().add(
            const FavoritesLoadRequested(silent: true),
          );
        },
        child: Navigator(
          key: widget.navigatorKey,
          observers: <NavigatorObserver>[widget.navigatorObserver],
          onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
            builder: (_) => const FavoritesScreen(),
          ),
        ),
      ),
    );
  }
}

// ------------------ PROFILE TAB ------------------
class ProfileTab extends StatelessWidget {
  const ProfileTab({
    required this.navigatorKey,
    required this.navigatorObserver,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final NavigatorObserver navigatorObserver;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: <NavigatorObserver>[navigatorObserver],
      onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
        builder: (_) => const _ProfileNavigator(),
      ),
    );
  }
}

// root navigator dla Profile
// zawiera dużą liczbę przejść do ekranów ustawień
class _ProfileNavigator extends StatelessWidget {
  const _ProfileNavigator();

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      onOpenOrders: () {
        return Navigator.push<void>(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (context) => MyOrdersBloc(
                ordersRepository: context.read<OrdersRepository>(),
              )..add(const MyOrdersLoadRequested()),
              child: OrderHistoryScreen(
                onBack: () => Navigator.pop(context),
                onOpenOrderDetails: (String id) {
                  Navigator.push(
                    context,
                    _NoAnimationPageRoute<void>(
                      builder: (_) => BlocProvider(
                        create: (context) => OrderHistoryDetailBloc(
                          ordersRepository: context.read<OrdersRepository>(),
                          orderId: id,
                        )..add(const OrderHistoryDetailLoadRequested()),
                        child: OrderHistoryDetailScreen(
                          orderId: id,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      onOpenAddresses: () {
        return Navigator.push<void>(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => AddressesScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenReviews: () {
        return Navigator.push<void>(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => MyReviewsScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenSettings: () {
        return Navigator.push<void>(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => PreferencesScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenHelp: () {
        return Navigator.push<void>(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => HelpScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenBecomeSeller: () {
        return Navigator.push<void>(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => SellerPanelScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenDeveloper: () {
        return Navigator.push<void>(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => DeveloperScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }
}
