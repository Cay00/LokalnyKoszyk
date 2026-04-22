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
import 'package:lokalny_koszyk/theme/app_theme.dart';
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
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
        (_) => GlobalKey<NavigatorState>(),
  );

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
                    HomeTab(navigatorKey: _navigatorKeys[0]),
                    DiscoverTab(navigatorKey: _navigatorKeys[1]),
                    OrdersTab(navigatorKey: _navigatorKeys[2]),
                    ProfileTab(navigatorKey: _navigatorKeys[3]),
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

// ---------------------------------------------------------------------------
// Wspólna baza dla zakładek z własnym Navigator
// ---------------------------------------------------------------------------

abstract class _TabBase extends StatelessWidget {
  const _TabBase({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  Route<dynamic> buildInitialRoute(RouteSettings settings);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: buildInitialRoute,
    );
  }
}

// ---------------------------------------------------------------------------
// HomeTab
// ---------------------------------------------------------------------------

enum _HomeView { main, productDetails, producerDetails }

class HomeTab extends _TabBase {
  const HomeTab({required super.navigatorKey});

  @override
  Route<dynamic> buildInitialRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const _HomeNavigator(),
    );
  }
}

class _HomeNavigator extends StatefulWidget {
  const _HomeNavigator();

  @override
  State<_HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<_HomeNavigator> {
  _HomeView _view = _HomeView.main;
  _HomeView? _viewBeforeProducer;
  ProductData? _selectedProduct;

  void _goTo(_HomeView view, {ProductData? product}) {
    setState(() {
      if (view == _HomeView.producerDetails) _viewBeforeProducer = _view;
      if (product != null) _selectedProduct = product;
      _view = view;
    });
  }

  void _goBack() {
    setState(() {
      switch (_view) {
        case _HomeView.producerDetails:
          _view = _viewBeforeProducer ?? _HomeView.main;
          _viewBeforeProducer = null;
        case _HomeView.productDetails:
        case _HomeView.main:
          _view = _HomeView.main;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_view) {
      _HomeView.main => HomeScreen(
        onOpenProductDetails: (p) => _goTo(_HomeView.productDetails, product: p),
        onOpenProducerDetails: () => _goTo(_HomeView.producerDetails),
      ),
      _HomeView.productDetails => ProductDetailsScreen(
        product: _selectedProduct!,
        onBack: _goBack,
        onOpenProducerDetails: () => _goTo(_HomeView.producerDetails),
      ),
      _HomeView.producerDetails => ProducerDetailsScreen(onBack: _goBack),
    };
  }
}

// ---------------------------------------------------------------------------
// DiscoverTab – ta sama struktura co HomeTab
// ---------------------------------------------------------------------------

enum _DiscoverView { main, productDetails, producerDetails }

class DiscoverTab extends _TabBase {
  const DiscoverTab({required super.navigatorKey});

  @override
  Route<dynamic> buildInitialRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const _DiscoverNavigator(),
    );
  }
}

class _DiscoverNavigator extends StatefulWidget {
  const _DiscoverNavigator();

  @override
  State<_DiscoverNavigator> createState() => _DiscoverNavigatorState();
}

class _DiscoverNavigatorState extends State<_DiscoverNavigator> {
  _DiscoverView _view = _DiscoverView.main;
  _DiscoverView? _viewBeforeProducer;
  ProductData? _selectedProduct;

  void _goTo(_DiscoverView view, {ProductData? product}) {
    setState(() {
      if (view == _DiscoverView.producerDetails) _viewBeforeProducer = _view;
      if (product != null) _selectedProduct = product;
      _view = view;
    });
  }

  void _goBack() {
    setState(() {
      switch (_view) {
        case _DiscoverView.producerDetails:
          _view = _viewBeforeProducer ?? _DiscoverView.main;
          _viewBeforeProducer = null;
        case _DiscoverView.productDetails:
        case _DiscoverView.main:
          _view = _DiscoverView.main;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_view) {
      _DiscoverView.main => DiscoverScreen(
        onOpenProductDetails: (p) => _goTo(_DiscoverView.productDetails, product: p),
      ),
      _DiscoverView.productDetails => ProductDetailsScreen(
        product: _selectedProduct!,
        onBack: _goBack,
        onOpenProducerDetails: () => _goTo(_DiscoverView.producerDetails),
      ),
      _DiscoverView.producerDetails => ProducerDetailsScreen(onBack: _goBack),
    };
  }
}

// ---------------------------------------------------------------------------
// OrdersTab
// ---------------------------------------------------------------------------

enum _OrdersView { main, checkout, orderDetails }

class OrdersTab extends _TabBase {
  const OrdersTab({required super.navigatorKey});

  @override
  Route<dynamic> buildInitialRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const _OrdersNavigator(),
    );
  }
}

class _OrdersNavigator extends StatefulWidget {
  const _OrdersNavigator();

  @override
  State<_OrdersNavigator> createState() => _OrdersNavigatorState();
}

class _OrdersNavigatorState extends State<_OrdersNavigator> {
  _OrdersView _view = _OrdersView.main;
  String? _selectedOrderId;

  @override
  Widget build(BuildContext context) {
    return switch (_view) {
      _OrdersView.main => OrdersScreen(
        onOpenCheckout: () => setState(() => _view = _OrdersView.checkout),
        onOpenOrderDetails: (String id) => setState(() {
          _selectedOrderId = id;
          _view = _OrdersView.orderDetails;
        }),
      ),
      _OrdersView.checkout => OrderCheckoutScreen(
        onBack: () => setState(() => _view = _OrdersView.main),
      ),
      _OrdersView.orderDetails => OrderHistoryDetailScreen(
        orderId: _selectedOrderId!,
        onBack: () => setState(() => _view = _OrdersView.main),
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// ProfileTab
// ---------------------------------------------------------------------------

enum _ProfileView {
  main,
  favorites,
  addresses,
  payments,
  notifications,
  preferences,
  messages,
  help,
  becomeSeller,
}

class ProfileTab extends _TabBase {
  const ProfileTab({required super.navigatorKey});

  @override
  Route<dynamic> buildInitialRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const _ProfileNavigator(),
    );
  }
}

class _ProfileNavigator extends StatefulWidget {
  const _ProfileNavigator();

  @override
  State<_ProfileNavigator> createState() => _ProfileNavigatorState();
}

class _ProfileNavigatorState extends State<_ProfileNavigator> {
  _ProfileView _view = _ProfileView.main;

  void _goTo(_ProfileView view) => setState(() => _view = view);
  void _goBack() => setState(() => _view = _ProfileView.main);

  @override
  Widget build(BuildContext context) {
    return switch (_view) {
      _ProfileView.main => ProfileScreen(
        onOpenFavorites:     () => _goTo(_ProfileView.favorites),
        onOpenAddresses:     () => _goTo(_ProfileView.addresses),
        onOpenPayments:      () => _goTo(_ProfileView.payments),
        onOpenNotifications: () => _goTo(_ProfileView.notifications),
        onOpenPreferences:   () => _goTo(_ProfileView.preferences),
        onOpenMessages:      () => _goTo(_ProfileView.messages),
        onOpenHelp:          () => _goTo(_ProfileView.help),
        onOpenBecomeSeller:  () => _goTo(_ProfileView.becomeSeller),
      ),
      _ProfileView.favorites    => FavoritesScreen(onBack: _goBack),
      _ProfileView.addresses    => AddressesScreen(onBack: _goBack),
      _ProfileView.payments     => PaymentsScreen(onBack: _goBack),
      _ProfileView.notifications => NotificationsScreen(onBack: _goBack),
      _ProfileView.preferences  => PreferencesScreen(onBack: _goBack),
      _ProfileView.messages     => MessagesScreen(onBack: _goBack),
      _ProfileView.help         => HelpScreen(onBack: _goBack),
      _ProfileView.becomeSeller => BecomeSellerScreen(onBack: _goBack),
    };
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