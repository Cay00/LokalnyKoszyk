import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import 'screen_header.dart';

class DefaultScreen extends StatelessWidget {
  const DefaultScreen({
    super.key,
    required this.title,
    this.message,
    this.body,
    this.onBack,
  }) : assert(
         message != null || body != null,
         'Provide either message or body for DefaultScreen.',
       );

  final String title;
  final String? message;
  final Widget? body;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: title,
          leading: ScreenHeaderBackButton(onPressed: onBack),
        ),
        Expanded(
          child:
              body ??
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
