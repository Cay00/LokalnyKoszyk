import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/screens/profile/seller/add_product_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.onOpenAddresses,
    this.onOpenPayments,
    this.onOpenNotifications,
    this.onOpenPreferences,
    this.onOpenMessages,
    this.onOpenHelp,
    this.onOpenBecomeSeller,
    this.onOpenSellerPanel,
  });

  final VoidCallback? onOpenAddresses;
  final VoidCallback? onOpenPayments;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenPreferences;
  final VoidCallback? onOpenMessages;
  final VoidCallback? onOpenHelp;
  final VoidCallback? onOpenBecomeSeller;
  final VoidCallback? onOpenSellerPanel;

  static const List<_ProfileMenuItem> _menu = <_ProfileMenuItem>[
    _ProfileMenuItem(iconAsset: 'assets/icons/map-pin-area.svg', label: 'Adresy dostawy'),
    _ProfileMenuItem(iconAsset: 'assets/icons/hand-coins.svg', label: 'Metody płatnosci'),
    _ProfileMenuItem(iconAsset: 'assets/icons/bell.svg', label: 'Powiadomienia'),
    _ProfileMenuItem(iconAsset: 'assets/icons/gear.svg', label: 'Moje preferencje'),
    _ProfileMenuItem(iconAsset: 'assets/icons/chat-circle-dots.svg', label: 'Wiadomości'),
    _ProfileMenuItem(iconAsset: 'assets/icons/question.svg', label: 'Pomoc i FAQ'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final metadataName = user?.userMetadata?['name'];
    final displayName = metadataName is String && metadataName.trim().isNotEmpty
        ? metadataName.trim()
        : 'Użytkownik';

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 48),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[AppColors.accent, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: <Widget>[
              const _ProfileAvatar(),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Wrocław · Członek od 2026',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 16),
              const _ProfileStats(),
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
                    border: Border.all(color: AppColors.background),
                  ),
                  child: Column(
                    children: <Widget>[
                      ..._menu.asMap().entries.map((entry) {
                        final int i = entry.key;
                        final _ProfileMenuItem item = entry.value;
                        return _ProfileMenuTile(
                          iconAsset: item.iconAsset,
                          label: item.label,
                          withDivider: i < _menu.length - 1,
                          onTap: switch (item.label) {
                            'Adresy dostawy' => onOpenAddresses,
                            'Metody płatnosci' => onOpenPayments,
                            'Powiadomienia' => onOpenNotifications,
                            'Moje preferencje' => onOpenPreferences,
                            'Wiadomości' => onOpenMessages,
                            'Pomoc i FAQ' => onOpenHelp,
                            _ => null,
                          },
                        );
                      }),
                      const _LogoutTile(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SellerPanelCard(
                  onTap: onOpenSellerPanel,
                ),
                const SizedBox(height: 12),
                _BecomeProducerCard(
                  onTap: onOpenBecomeSeller,
                ),
                const SizedBox(height: 12),
                const _QuickAddProductCard(),
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
        border: Border.all(color: AppColors.textPrimary, width: 4),
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
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    this.iconAsset,
    required this.label,
    required this.withDivider,
    this.onTap,
  });

  final String? iconAsset;
  final String label;
  final bool withDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: <Widget>[
                if (iconAsset != null)
                  SvgPicture.asset(
                    iconAsset!,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/caret-right.svg',
                  width: 12,
                  height: 12,
                  colorFilter: const ColorFilter.mode(
                    AppColors.accent,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (withDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.background,
            ),
          ),
      ],
    );
  }
}

class _SellerPanelCard extends StatelessWidget {
  const _SellerPanelCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.normal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.normal),
          border: Border.all(color: AppColors.accent, width: 1.5),
        ),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              'assets/icons/package.svg',
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Panel sprzedawcy',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dane konta, weryfikacja i lokalizacje z bazy',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                AppColors.accent,
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
  const _BecomeProducerCard({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.normal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.normal),
          border: Border.all(color: AppColors.accent),
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
                    'Zostań sprzedawcą',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Sprzedawaj swoje produkty lokalnie',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.background,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Potwierdzenie'),
                    content: const Text('Czy na pewno chcesz się wylogować?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Anuluj'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Wyloguj'),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout == true) {
                await supabase.auth.signOut();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/icons/sign-out.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.redAccent,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Wyloguj',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    this.iconAsset,
    required this.label,
  });

  final String? iconAsset;
  final String label;
}

class _QuickAddProductCard extends StatelessWidget {
  const _QuickAddProductCard();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AddProductScreen(),
          ),
        );
      },
      icon: const Icon(Icons.add_box_outlined),
      label: const Text('Tymczasowo: dodaj produkt'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.normal),
        ),
      ),
    );
  }
}
