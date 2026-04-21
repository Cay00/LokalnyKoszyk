import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/screens/discover_screen.dart';
import 'package:lokalny_koszyk/screens/home_screen.dart';
import 'package:lokalny_koszyk/screens/orders_screen.dart';
import 'package:lokalny_koszyk/screens/profile_screen.dart';
import 'package:lokalny_koszyk/theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      const HomeScreen(),
      const DiscoverScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
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
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 16,
          color: isActive ? AppColors.white : Colors.transparent,
        ),
      ],
    );
  }
}
