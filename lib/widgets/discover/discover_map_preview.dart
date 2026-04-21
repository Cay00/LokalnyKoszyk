import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class DiscoverMapPreview extends StatelessWidget {
  const DiscoverMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFDCE9D8), Color(0xFFC8E0C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.normal),
        border: Border.all(color: const Color(0xFFC6D8BC)),
      ),
      child: Stack(
        children: <Widget>[
          const _MapDot(leftFactor: 0.30, topFactor: 0.40, isMain: true),
          const _MapDot(leftFactor: 0.70, topFactor: 0.55),
          const _MapDot(leftFactor: 0.50, topFactor: 0.75),
          const _MapDot(leftFactor: 0.80, topFactor: 0.30),
          const _MapDot(leftFactor: 0.20, topFactor: 0.65),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Pokaż na mapie · 23 sprzedawców',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  const _MapDot({
    required this.leftFactor,
    required this.topFactor,
    this.isMain = false,
  });

  final double leftFactor;
  final double topFactor;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    final double size = isMain ? 14 : 10;
    return Positioned(
      left: leftFactor * MediaQuery.of(context).size.width * 0.75,
      top: topFactor * 160,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isMain ? AppColors.accent : AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
