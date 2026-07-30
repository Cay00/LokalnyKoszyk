import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../app_bottom_navigation_bar.dart';
import 'screen_header.dart';

class DefaultScreen extends StatelessWidget {
  const DefaultScreen({
    super.key,
    required this.title,
    this.message,
    this.body,
    this.onBack,
    this.showBottomNavPadding = true,
  }) : assert(
         message != null || body != null,
         'Provide either message or body for DefaultScreen.',
       );

  final String title;
  final String? message;
  final Widget? body;
  final VoidCallback? onBack;

  /// Gdy `true` (domyślnie) — dolny inset scrolla = clearance wiszącego bottom nav.
  /// Gdy `false` — tylko 16px na dole.
  final bool showBottomNavPadding;

  /// Padding treści scrolla: boki/góra + clearance bottom nav na dole.
  /// Wołaj z dowolnego kontekstu (także przy budowie `body` poza [MediaQuery]).
  static EdgeInsets bodyPadding(
    BuildContext context, {
    double left = 16,
    double top = 16,
    double right = 16,
  }) {
    return EdgeInsets.fromLTRB(
      left,
      top,
      right,
      AppBottomNavigationBar.contentBottomPadding(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = showBottomNavPadding
        ? AppBottomNavigationBar.contentBottomPadding(context)
        : 16;

    final Widget content =
        body ??
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        );

    // Pełna wysokość (treść widoczna za wiszącym barem).
    // Dolny inset idzie do MediaQuery → scroll używa [bodyPadding].
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: title,
          leading: onBack == null
              ? null
              : ScreenHeaderBackButton(onPressed: onBack),
        ),
        Expanded(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: MediaQuery.of(context).padding.copyWith(
                bottom: bottomInset,
              ),
            ),
            child: content,
          ),
        ),
      ],
    );
  }
}
