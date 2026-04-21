import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<_ProfileMenuItem> _menu = <_ProfileMenuItem>[
    _ProfileMenuItem(iconAsset: 'assets/icons/heart.svg', label: 'Ulubione produkty'),
    _ProfileMenuItem(iconAsset: 'assets/icons/map-pin-area.svg', label: 'Adresy dostawy'),
    _ProfileMenuItem(iconAsset: 'assets/icons/hand-coins.svg', label: 'Metody płatnosci'),
    _ProfileMenuItem(iconAsset: 'assets/icons/bell.svg', label: 'Powiadomienia'),
    _ProfileMenuItem(iconAsset: 'assets/icons/gear.svg', label: 'Moje preferencje'),
    _ProfileMenuItem(iconAsset: 'assets/icons/chat-circle-dots.svg', label: 'Wiadomości'),
    _ProfileMenuItem(iconAsset: 'assets/icons/question.svg', label: 'Pomoc i FAQ'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 48),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Column(
            children: <Widget>[
              _ProfileAvatar(),
              SizedBox(height: 16),
              Text(
                'Krzysztof Turek',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Wrocław · Członek od 2026',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 16),
              _ProfileStats(),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.normal),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: _menu.asMap().entries.map((entry) {
                      final int i = entry.key;
                      final _ProfileMenuItem item = entry.value;
                      return _ProfileMenuTile(
                        icon: item.icon,
                        iconAsset: item.iconAsset,
                        label: item.label,
                        withDivider: i < _menu.length - 1,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const _BecomeProducerCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textOnDark, width: 4),
      ),
      alignment: Alignment.center,
      child: const Text('🧑', style: TextStyle(fontSize: 36)),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _ProfileStat(number: '8', label: 'Zamówień'),
        SizedBox(width: 32),
        _ProfileStat(number: '3', label: 'Ulubionych'),
        SizedBox(width: 32),
        _ProfileStat(number: '12', label: 'Opinii'),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          number,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textOnDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    this.iconAsset,
    required this.label,
    required this.withDivider,
  });

  final String icon;
  final String? iconAsset;
  final String label;
  final bool withDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: withDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.border),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: <Widget>[
            iconAsset != null
                ? SvgPicture.asset(
                    iconAsset!,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  )
                : Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E3A2F),
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/caret-right.svg',
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BecomeProducerCard extends StatelessWidget {
  const _BecomeProducerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE9D8),
        borderRadius: BorderRadius.circular(AppRadius.normal),
        border: Border.all(color: const Color(0xFFC6D8BC)),
      ),
      child: Row(
        children: <Widget>[
          Text('🌱', style: TextStyle(fontSize: 32)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Zostań producentem',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sprzedawaj swoje produkty lokalnie',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/caret-right.svg',
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    this.icon = '',
    this.iconAsset,
    required this.label,
  });

  final String icon;
  final String? iconAsset;
  final String label;
}
