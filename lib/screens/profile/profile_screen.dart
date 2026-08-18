import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/default_screen.dart';
import '../../widgets/common/menu_action_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.onOpenOrders,
    this.onOpenAddresses,
    this.onOpenReviews,
    this.onOpenSettings,
    this.onOpenHelp,
    this.onOpenBecomeSeller,
    this.onOpenDeveloper,
  });

  final VoidCallback? onOpenOrders;
  final VoidCallback? onOpenAddresses;
  final VoidCallback? onOpenReviews;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenHelp;
  final VoidCallback? onOpenBecomeSeller;
  final VoidCallback? onOpenDeveloper;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final metadataName = user?.userMetadata?['name'];
    final displayName = metadataName is String && metadataName.trim().isNotEmpty
        ? metadataName.trim()
        : 'Użytkownik';

    return DefaultScreen(
      title: 'Profil',
      body: ListView(
        padding: DefaultScreen.bodyPadding(context),
        children: <Widget>[
          const Center(child: _ProfileAvatar()),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          MenuActionButton(
            iconAsset: 'assets/icons/package.svg',
            label: 'Moje zamówienia',
            onTap: onOpenOrders,
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/map-pin-area.svg',
            label: 'Adresy dostawy',
            onTap: onOpenAddresses,
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/star.svg',
            label: 'Moje opinie',
            onTap: onOpenReviews,
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/gear.svg',
            label: 'Ustawienia',
            onTap: onOpenSettings,
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/question.svg',
            label: 'Pomoc i FAQ',
            onTap: onOpenHelp,
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/sign-out.svg',
            label: 'Wyloguj',
            onTap: () => _confirmLogout(context),
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/barn.svg',
            label: 'Zostań sprzedawcą',
            backgroundColor: AppColors.accent,
            onTap: onOpenBecomeSeller,
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/square.svg',
            label: 'Ekran deweloperski',
            onTap: onOpenDeveloper,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
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
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: AppColors.textTertiary,
        shape: BoxShape.circle,
      ),
    );
  }
}
