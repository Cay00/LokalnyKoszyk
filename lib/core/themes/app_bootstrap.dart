import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';

class AppBootstrap {
  const AppBootstrap._();

  static void configureSystemUi() {
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
  }
}
