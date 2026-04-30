import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/screens/discover_screen.dart';
import 'package:lokalny_koszyk/screens/home_screen.dart';
import 'package:lokalny_koszyk/screens/checkout/order_checkout_screen.dart';
import 'package:lokalny_koszyk/screens/checkout/order_history_detail_screen.dart';
import 'package:lokalny_koszyk/screens/checkout/orders_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/profile/addresses_screen.dart';
import 'package:lokalny_koszyk/screens/profile/become_seller_screen.dart';
import 'package:lokalny_koszyk/screens/profile/favorites_screen.dart';
import 'package:lokalny_koszyk/screens/profile/help_screen.dart';
import 'package:lokalny_koszyk/screens/profile/messages_screen.dart';
import 'package:lokalny_koszyk/screens/profile/notifications_screen.dart';
import 'package:lokalny_koszyk/screens/profile/payments_screen.dart';
import 'package:lokalny_koszyk/screens/profile/preferences_screen.dart';
import 'package:lokalny_koszyk/screens/profile/profile_screen.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.primary,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: AppColors.primary,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MyHomePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Root – tylko BottomNavigationBar + IndexedStack
// ---------------------------------------------------------------------------

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<({String assetPath, String label})> _navItems = [
    (assetPath: 'assets/icons/barn.svg',    label: 'Ekran główny'),
    (assetPath: 'assets/icons/compass.svg', label: 'Odkrywaj'),
    (assetPath: 'assets/icons/basket.svg',  label: 'Zamówienia'),
    (assetPath: 'assets/icons/user.svg',    label: 'Profil'),
  ];

  // Klucze zachowują stan każdej zakładki niezależnie przy przełączaniu.
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _discoverNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _ordersNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

  List<GlobalKey<NavigatorState>> get _navigatorKeys => [
    _homeNavigatorKey,
    _discoverNavigatorKey,
    _ordersNavigatorKey,
    _profileNavigatorKey,
  ];

  Future<bool> _onWillPop() async {
    final navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.paddingOf(context).top,
                color: AppColors.primary,
              ),
              Expanded(
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
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (int index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: _navItems
                .map(
                  (item) => BottomNavigationBarItem(
                icon: _BottomNavItemVisual(
                  assetPath: item.assetPath,
                  label: item.label,
                  isActive: false,
                ),
                activeIcon: _BottomNavItemVisual(
                  assetPath: item.assetPath,
                  label: item.label,
                  isActive: true,
                ),
                label: '',
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  _NoAnimationPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
}

// ---------------------------------------------------------------------------
// HomeTab
// ---------------------------------------------------------------------------

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

class _HomeNavigator extends StatefulWidget {
  const _HomeNavigator();

  @override
  State<_HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<_HomeNavigator> {
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

// ---------------------------------------------------------------------------
// DiscoverTab – ta sama struktura co HomeTab
// ---------------------------------------------------------------------------

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

class _DiscoverNavigator extends StatefulWidget {
  const _DiscoverNavigator();

  @override
  State<_DiscoverNavigator> createState() => _DiscoverNavigatorState();
}

class _DiscoverNavigatorState extends State<_DiscoverNavigator> {
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

// ---------------------------------------------------------------------------
// OrdersTab
// ---------------------------------------------------------------------------

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

class _OrdersNavigator extends StatefulWidget {
  const _OrdersNavigator();

  @override
  State<_OrdersNavigator> createState() => _OrdersNavigatorState();
}

class _OrdersNavigatorState extends State<_OrdersNavigator> {
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

// ---------------------------------------------------------------------------
// ProfileTab
// ---------------------------------------------------------------------------

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

class _ProfileNavigator extends StatefulWidget {
  const _ProfileNavigator();

  @override
  State<_ProfileNavigator> createState() => _ProfileNavigatorState();
}

class _ProfileNavigatorState extends State<_ProfileNavigator> {
  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
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

// ---------------------------------------------------------------------------
// BottomNavItemVisual – bez zmian funkcjonalnych
// ---------------------------------------------------------------------------

class _BottomNavItemVisual extends StatelessWidget {
  const _BottomNavItemVisual({
    required this.assetPath,
    required this.label,
    required this.isActive,
  });

  final String assetPath;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isActive ? AppColors.white : AppColors.textOnDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        SvgPicture.asset(
          assetPath,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: itemColor,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 4),
          child: Container(
            height: 2,
            width: 16,
            color: isActive ? AppColors.white : Colors.transparent,
          ),
        ),
      ],
    );
  }
}