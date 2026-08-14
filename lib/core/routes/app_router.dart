import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/discover_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
import 'package:lokalny_koszyk/presentation/checkout_bloc.dart';
import 'package:lokalny_koszyk/presentation/discover_bloc.dart';
import 'package:lokalny_koszyk/presentation/favorites_bloc.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/order_history_detail_bloc.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/widgets/app_bottom_navigation_bar.dart';
import 'package:lokalny_koszyk/screens/checkout/order_checkout_screen.dart';
import 'package:lokalny_koszyk/screens/checkout/order_history_detail_screen.dart';
import 'package:lokalny_koszyk/screens/checkout/orders_screen.dart';
import 'package:lokalny_koszyk/screens/home/discover_screen.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';
import 'package:lokalny_koszyk/screens/profile/addresses_screen.dart';
import 'package:lokalny_koszyk/screens/profile/seller/become_seller_screen.dart';
import 'package:lokalny_koszyk/screens/profile/favorites_screen.dart';
import 'package:lokalny_koszyk/screens/profile/help_screen.dart';
import 'package:lokalny_koszyk/screens/profile/messages_screen.dart';
import 'package:lokalny_koszyk/screens/profile/notifications_screen.dart';
import 'package:lokalny_koszyk/screens/profile/payments_screen.dart';
import 'package:lokalny_koszyk/screens/profile/preferences_screen.dart';
import 'package:lokalny_koszyk/screens/profile/profile_screen.dart';
import 'package:lokalny_koszyk/screens/profile/seller_panel_screen.dart';

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

  // lista navigatorów dla łatwego dostępu po indeksie
  List<GlobalKey<NavigatorState>> get _navigatorKeys => [
    _shopNavigatorKey,
    _cartNavigatorKey,
    _favoritesNavigatorKey,
    _profileNavigatorKey,
  ];

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
                        DiscoverTab(navigatorKey: _shopNavigatorKey),
                        OrdersTab(navigatorKey: _cartNavigatorKey),
                        FavoritesTab(navigatorKey: _favoritesNavigatorKey),
                        ProfileTab(navigatorKey: _profileNavigatorKey),
                      ],
                    ),
                  ),
                ],
              ),
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
class DiscoverTab extends StatelessWidget {
  const DiscoverTab({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscoverBloc(
        discoverRepository: context.read<DiscoverRepository>(),
        cartRepository: context.read<CartRepository>(),
      )..add(const DiscoverLoadProductsRequested()),
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
          builder: (_) => const _DiscoverNavigator(),
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
class OrdersTab extends StatelessWidget {
  const OrdersTab({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc(
        cartRepository: context.read<CartRepository>(),
        ordersRepository: context.read<OrdersRepository>(),
      )..add(const OrdersRefreshAllRequested()),
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
          builder: (_) => const _OrdersNavigator(),
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
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (context) => CheckoutBloc(
                cartRepository: context.read<CartRepository>(),
              )..add(const CheckoutLoadRequested()),
              child: OrderCheckoutScreen(
                onBack: () => Navigator.pop(context),
              ),
            ),
          ),
        );
      },
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
    );
  }
}

// ------------------ FAVORITES TAB (Ulubione) ------------------
class FavoritesTab extends StatelessWidget {
  const FavoritesTab({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesBloc(
        watchedProductsRepository: context.read<WatchedProductsRepository>(),
        cartRepository: context.read<CartRepository>(),
      )..add(const FavoritesLoadRequested()),
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
          builder: (_) => const FavoritesScreen(),
        ),
      ),
    );
  }
}

// ------------------ PROFILE TAB ------------------
class ProfileTab extends StatelessWidget {
  const ProfileTab({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
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
      onOpenSellerPanel: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => SellerPanelScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenAddresses: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => AddressesScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenPayments: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => PaymentsScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenNotifications: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => NotificationsScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenPreferences: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => PreferencesScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenMessages: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => MessagesScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenHelp: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => HelpScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenBecomeSeller: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => BecomeSellerScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }
}
