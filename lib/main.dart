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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  _HomeView _homeView = _HomeView.main;
  ProductData? _selectedHomeProduct;
  _DiscoverView _discoverView = _DiscoverView.main;
  ProductData? _selectedDiscoverProduct;
  _OrdersView _ordersView = _OrdersView.main;
  String _selectedOrderId = '';
  _ProfileView _profileView = _ProfileView.main;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      _buildHomeContent(),
      _buildDiscoverContent(),
      _buildOrdersContent(),
      _buildProfileContent(),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            if (index != 2) {
              _ordersView = _OrdersView.main;
            }
            if (index != 3) {
              _profileView = _ProfileView.main;
            }
            if (index != 0) {
              _homeView = _HomeView.main;
            }
            if (index != 1) {
              _discoverView = _DiscoverView.main;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _BottomNavItemVisual(
              assetPath: 'assets/icons/barn.svg',
              label: 'Ekran główny',
              isActive: false,
            ),
            activeIcon: _BottomNavItemVisual(
              assetPath: 'assets/icons/barn.svg',
              label: 'Ekran główny',
              isActive: true,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _BottomNavItemVisual(
              assetPath: 'assets/icons/compass.svg',
              label: 'Odkrywaj',
              isActive: false,
            ),
            activeIcon: _BottomNavItemVisual(
              assetPath: 'assets/icons/compass.svg',
              label: 'Odkrywaj',
              isActive: true,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _BottomNavItemVisual(
              assetPath: 'assets/icons/basket.svg',
              label: 'Zamówienia',
              isActive: false,
            ),
            activeIcon: _BottomNavItemVisual(
              assetPath: 'assets/icons/basket.svg',
              label: 'Zamówienia',
              isActive: true,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _BottomNavItemVisual(
              assetPath: 'assets/icons/user.svg',
              label: 'Profil',
              isActive: false,
            ),
            activeIcon: _BottomNavItemVisual(
              assetPath: 'assets/icons/user.svg',
              label: 'Profil',
              isActive: true,
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    switch (_homeView) {
      case _HomeView.main:
        return HomeScreen(
          onOpenProductDetails: (ProductData product) {
            setState(() {
              _selectedHomeProduct = product;
              _homeView = _HomeView.productDetails;
            });
          },
          onOpenProducerDetails: () {
            setState(() {
              _homeView = _HomeView.producerDetails;
            });
          },
        );
      case _HomeView.productDetails:
        return ProductDetailsScreen(
          product: _selectedHomeProduct!,
          onBack: () => setState(() => _homeView = _HomeView.main),
          onOpenProducerDetails: () {
            setState(() {
              _homeView = _HomeView.producerDetails;
            });
          },
        );
      case _HomeView.producerDetails:
        return ProducerDetailsScreen(
          onBack: () => setState(() => _homeView = _HomeView.main),
        );
    }
  }

  Widget _buildDiscoverContent() {
    switch (_discoverView) {
      case _DiscoverView.main:
        return DiscoverScreen(
          onOpenProductDetails: (ProductData product) {
            setState(() {
              _selectedDiscoverProduct = product;
              _discoverView = _DiscoverView.productDetails;
            });
          },
        );
      case _DiscoverView.productDetails:
        return ProductDetailsScreen(
          product: _selectedDiscoverProduct!,
          onBack: () => setState(() => _discoverView = _DiscoverView.main),
          onOpenProducerDetails: () {
            setState(() {
              _discoverView = _DiscoverView.producerDetails;
            });
          },
        );
      case _DiscoverView.producerDetails:
        return ProducerDetailsScreen(
          onBack: () => setState(() => _discoverView = _DiscoverView.main),
        );
    }
  }

  Widget _buildOrdersContent() {
    switch (_ordersView) {
      case _OrdersView.main:
        return OrdersScreen(
          onOpenCheckout: () => setState(() => _ordersView = _OrdersView.checkout),
          onOpenOrderDetails: (String orderId) {
            setState(() {
              _selectedOrderId = orderId;
              _ordersView = _OrdersView.orderDetails;
            });
          },
        );
      case _OrdersView.checkout:
        return OrderCheckoutScreen(
          onBack: () => setState(() => _ordersView = _OrdersView.main),
        );
      case _OrdersView.orderDetails:
        return OrderHistoryDetailScreen(
          orderId: _selectedOrderId,
          onBack: () => setState(() => _ordersView = _OrdersView.main),
        );
    }
  }

  Widget _buildProfileContent() {
    switch (_profileView) {
      case _ProfileView.main:
        return ProfileScreen(
          onOpenFavorites: () => setState(() => _profileView = _ProfileView.favorites),
          onOpenAddresses: () => setState(() => _profileView = _ProfileView.addresses),
          onOpenPayments: () => setState(() => _profileView = _ProfileView.payments),
          onOpenNotifications:
              () => setState(() => _profileView = _ProfileView.notifications),
          onOpenPreferences: () => setState(() => _profileView = _ProfileView.preferences),
          onOpenMessages: () => setState(() => _profileView = _ProfileView.messages),
          onOpenHelp: () => setState(() => _profileView = _ProfileView.help),
          onOpenBecomeSeller: () => setState(() => _profileView = _ProfileView.becomeSeller),
        );
      case _ProfileView.favorites:
        return FavoritesScreen(onBack: () => setState(() => _profileView = _ProfileView.main));
      case _ProfileView.addresses:
        return AddressesScreen(onBack: () => setState(() => _profileView = _ProfileView.main));
      case _ProfileView.payments:
        return PaymentsScreen(onBack: () => setState(() => _profileView = _ProfileView.main));
      case _ProfileView.notifications:
        return NotificationsScreen(
          onBack: () => setState(() => _profileView = _ProfileView.main),
        );
      case _ProfileView.preferences:
        return PreferencesScreen(onBack: () => setState(() => _profileView = _ProfileView.main));
      case _ProfileView.messages:
        return MessagesScreen(onBack: () => setState(() => _profileView = _ProfileView.main));
      case _ProfileView.help:
        return HelpScreen(onBack: () => setState(() => _profileView = _ProfileView.main));
      case _ProfileView.becomeSeller:
        return BecomeSellerScreen(onBack: () => setState(() => _profileView = _ProfileView.main));
    }
  }
}

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
      children: <Widget>[
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
        const SizedBox(height: 0),
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

enum _HomeView {
  main,
  productDetails,
  producerDetails,
}

enum _DiscoverView {
  main,
  productDetails,
  producerDetails,
}

enum _OrdersView {
  main,
  checkout,
  orderDetails,
}
