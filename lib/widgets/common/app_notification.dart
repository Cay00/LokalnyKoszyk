import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

void showAppNotification(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
}) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.normal),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.normal,
      ),
    ),
  );
}
