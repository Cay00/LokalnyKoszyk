import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/app_bottom_navigation_bar.dart';
import 'package:lokalny_koszyk/screens/checkout/order_checkout_screen.dart';
import 'package:lokalny_koszyk/screens/checkout/order_history_detail_screen.dart';
import 'package:lokalny_koszyk/screens/checkout/orders_screen.dart';
import 'package:lokalny_koszyk/screens/discover_screen.dart';
import 'package:lokalny_koszyk/screens/home_screen.dart';
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
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _discoverNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _ordersNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

  // lista navigatorów dla łatwego dostępu po indeksie
  List<GlobalKey<NavigatorState>> get _navigatorKeys => [
    _homeNavigatorKey,
    _discoverNavigatorKey,
    _ordersNavigatorKey,
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
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
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
          body: Column(
            children: <Widget>[
              // manualne ustawienie koloru pod status barem
              Container(
                height: MediaQuery.paddingOf(context).top,
                color: AppColors.primary,
              ),
              Expanded(
                // IndexedStack zachowuje stan każdego taba
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    HomeTab(navigatorKey: _homeNavigatorKey),
                    DiscoverTab(navigatorKey: _discoverNavigatorKey),
                    OrdersTab(navigatorKey: _ordersNavigatorKey),
                    ProfileTab(navigatorKey: _profileNavigatorKey),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
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

// ------------------ HOME TAB ------------------
// wrapper dla Navigatora w tabie Home
class HomeTab extends StatelessWidget {
  const HomeTab({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
        builder: (_) => const _HomeNavigator(),
      ),
    );
  }
}

// root navigator dla taba Home
// zawiera logikę przejść z HomeScreen
class _HomeNavigator extends StatelessWidget {
  const _HomeNavigator();

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      onOpenProductDetails: (product) {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => ProductDetailsScreen(
              product: product,
              onBack: () => Navigator.pop(context),
              // zagnieżdżona nawigacja: Product -> Producer
              onOpenProducerDetails: () {
                Navigator.push(
                  context,
                  _NoAnimationPageRoute<void>(
                    builder: (_) => ProducerDetailsScreen(
                      onBack: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      onOpenProducerDetails: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => ProducerDetailsScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }
}

// ------------------ DISCOVER TAB ------------------
class DiscoverTab extends StatelessWidget {
  const DiscoverTab({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
        builder: (_) => const _DiscoverNavigator(),
      ),
    );
  }
}

// root navigator dla Discover
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
              onOpenProducerDetails: () {
                Navigator.push(
                  context,
                  _NoAnimationPageRoute<void>(
                    builder: (_) => ProducerDetailsScreen(
                      onBack: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ------------------ ORDERS TAB ------------------
class OrdersTab extends StatelessWidget {
  const OrdersTab({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => _NoAnimationPageRoute<void>(
        builder: (_) => const _OrdersNavigator(),
      ),
    );
  }
}

// root navigator dla Orders
class _OrdersNavigator extends StatelessWidget {
  const _OrdersNavigator();

  @override
  Widget build(BuildContext context) {
    return OrdersScreen(
      onOpenCheckout: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => OrderCheckoutScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
      onOpenOrderDetails: (String id) {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => OrderHistoryDetailScreen(
              orderId: id,
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
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
      onOpenFavorites: () {
        Navigator.push(
          context,
          _NoAnimationPageRoute<void>(
            builder: (_) => FavoritesScreen(
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
