import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/core/app_bootstrap.dart';
import 'package:lokalny_koszyk/core/routes/app_router.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';

void main() {
  AppBootstrap.configureSystemUi();
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
      home: const AppRouter(),
    );
  }
}
