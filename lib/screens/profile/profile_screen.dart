import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/menu_action_button.dart';

class ProfileScreen extends StatefulWidget {
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

  final Future<void> Function()? onOpenOrders;
  final Future<void> Function()? onOpenAddresses;
  final Future<void> Function()? onOpenReviews;
  final Future<void> Function()? onOpenSettings;
  final Future<void> Function()? onOpenHelp;
  final Future<void> Function()? onOpenBecomeSeller;
  final Future<void> Function()? onOpenDeveloper;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _displayName = 'Użytkownik';
  String? _phone;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _load();
    _authSub = supabase.auth.onAuthStateChange.listen((AuthState data) {
      if (data.event == AuthChangeEvent.userUpdated ||
          data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.tokenRefreshed) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _displayName = 'Użytkownik';
        _phone = null;
      });
      return;
    }

    String? name;
    String? phone;
    final emailLocal = (user.email ?? '').split('@').first.trim().toLowerCase();

    try {
      final row = await supabase
          .from('profiles')
          .select('full_name, phone')
          .eq('id', user.id)
          .maybeSingle();
      if (row != null) {
        final fullName = (row['full_name'] ?? '').toString().trim();
        final looksLikeEmailLocal = emailLocal.isNotEmpty &&
            fullName.toLowerCase() == emailLocal;
        if (fullName.isNotEmpty &&
            fullName != 'Użytkownik' &&
            !looksLikeEmailLocal) {
          name = fullName;
        }
        final rowPhone = (row['phone'] ?? '').toString().trim();
        if (rowPhone.isNotEmpty) phone = rowPhone;
      }
    } catch (_) {}

    final meta = user.userMetadata ?? <String, dynamic>{};
    final metaName = meta['name'];
    if (metaName is String && metaName.trim().isNotEmpty) {
      // Imię z rejestracji / ustawień — ma pierwszeństwo.
      name = metaName.trim();
    }
    final metaPhone = meta['phone'];
    if (phone == null &&
        metaPhone is String &&
        metaPhone.trim().isNotEmpty) {
      phone = metaPhone.trim();
    }

    if (!mounted) return;
    setState(() {
      _displayName = (name == null || name.isEmpty) ? 'Użytkownik' : name;
      _phone = phone;
    });
  }

  Future<void> _open(Future<void> Function()? action) async {
    await action?.call();
    if (mounted) await _load();
  }

  Future<void> _confirmLogout() async {
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

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Profil',
      body: ListView(
        padding: DefaultScreen.bodyPadding(context),
        children: <Widget>[
          Center(child: _ProfileAvatar(name: _displayName)),
          const SizedBox(height: 16),
          Text(
            _displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_phone != null) ...[
            const SizedBox(height: 4),
            Text(
              _phone!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 32),
          MenuActionButton(
            iconAsset: 'assets/icons/package.svg',
            label: 'Moje zamówienia',
            onTap: () => _open(widget.onOpenOrders),
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/map-pin-area.svg',
            label: 'Adresy dostawy',
            onTap: () => _open(widget.onOpenAddresses),
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/star.svg',
            label: 'Moje opinie',
            onTap: () => _open(widget.onOpenReviews),
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/gear.svg',
            label: 'Ustawienia profilu',
            onTap: () => _open(widget.onOpenSettings),
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/question.svg',
            label: 'Pomoc i FAQ',
            onTap: () => _open(widget.onOpenHelp),
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/sign-out.svg',
            label: 'Wyloguj',
            onTap: _confirmLogout,
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/barn.svg',
            label: 'Panel sprzedawcy',
            backgroundColor: AppColors.accent,
            onTap: () => _open(widget.onOpenBecomeSeller),
          ),
          const SizedBox(height: 8),
          MenuActionButton(
            iconAsset: 'assets/icons/square.svg',
            label: 'Ekran deweloperski',
            onTap: () => _open(widget.onOpenDeveloper),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});

  final String name;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty || name == 'Użytkownik') return '?';
    if (parts.length == 1) {
      final String p = parts.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return ('$a$b').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: AppTypography.header.copyWith(
          fontSize: 28,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
