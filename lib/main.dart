import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/di/repositories.dart';
import 'package:lokalny_koszyk/core/themes/app_bootstrap.dart';
import 'package:lokalny_koszyk/core/routes/app_router.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_config.dart';
import 'package:lokalny_koszyk/screens/auth/auth_gate.dart';

Future<void> main() async {
  AppBootstrap.configureSystemUi();
  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(
    AppRepositories(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(
        signedInChild: AppRouter(),
      ),
    );
  }
}
