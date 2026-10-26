import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/domain/models/payment_method.dart';
import 'package:lokalny_koszyk/domain/models/producer_profile.dart';
import 'package:lokalny_koszyk/domain/repositories/producer_details_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_sellers_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/producer_details_bloc.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/app_notification.dart';
import '../../widgets/common/default_screen.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/segmented_toggle.dart';
import '../product/product_details_screen.dart';
import '../product/product_tile_small.dart';

class ProducerDetailsScreen extends StatelessWidget {
  const ProducerDetailsScreen({
    super.key,
    this.sellerId,
    this.onBack,
  });

  final String? sellerId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ProducerDetailsBloc(
        repository: context.read<ProducerDetailsRepository>(),
        watchedSellersRepository: context.read<WatchedSellersRepository>(),
        sellerId: sellerId,
      )..add(const ProducerDetailsLoadRequested()),
      child: _ProducerDetailsBody(
        sellerId: sellerId,
        onBack: onBack,
      ),
    );
  }
}

class _ProducerDetailsBody extends StatefulWidget {
  const _ProducerDetailsBody({
    this.sellerId,
    this.onBack,
  });

  final String? sellerId;
  final VoidCallback? onBack;

  @override
  State<_ProducerDetailsBody> createState() => _ProducerDetailsBodyState();
}

class _ProducerDetailsBodyState extends State<_ProducerDetailsBody> {
  _InfoSection _selectedInfoSection = _InfoSection.address;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProducerDetailsBloc, ProducerDetailsState>(
      listenWhen: (ProducerDetailsState previous, ProducerDetailsState current) =>
          current.feedbackMessage != null &&
          current.feedbackMessage != previous.feedbackMessage,
      listener: (BuildContext context, ProducerDetailsState state) {
        final message = state.feedbackMessage;
        if (message == null) return;
        showAppNotification(context, message);
      },
      child: BlocBuilder<ProducerDetailsBloc, ProducerDetailsState>(
      builder: (BuildContext context, ProducerDetailsState vmState) {
        final seller = vmState.seller;
        return DefaultScreen(
          title: 'Sprzedawca',
          actions: <Widget>[
            ScreenHeaderButton(
              onPressed: null,
              splash: false,
              child: SvgPicture.asset(
                'assets/icons/share-network.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ScreenHeaderButton(
              onPressed: () => context.read<ProducerDetailsBloc>().add(
                const ProducerDetailsToggleLikeRequested(),
              ),
              splash: false,
              child: SvgPicture.asset(
                vmState.isLiked
                    ? 'assets/icons/heart-fill.svg'
                    : 'assets/icons/heart.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  vmState.isLiked ? Colors.redAccent : AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
          body: vmState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vmState.errorText != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          vmState.errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Przy braku danych sprzedawcy sprawdź polityki RLS w Supabase. '
                          'W repozytorium: sql/supabase_sellers_public_read.sql',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.read<ProducerDetailsBloc>().add(
                            const ProducerDetailsLoadRequested(),
                          ),
                          child: const Text('Ponów'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: DefaultScreen.bodyPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.normal),
                          border: Border.all(color: AppColors.background),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Center(
                              child: SvgPicture.asset(
                                'assets/icons/farm.svg',
                                width: 120,
                                height: 120,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.accent,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/farm_bg.png',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                  ) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppRadius.normal,
                              ),
                              border: Border.all(color: AppColors.background),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/farm.svg',
                                    width: 36,
                                    height: 36,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.accent,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/farm_logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (
                                        BuildContext context,
                                        Object error,
                                        StackTrace? stackTrace,
                                      ) => const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        seller?.name ?? 'Sprzedawca',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (seller?.isVerified == true) ...<Widget>[
                                      const SizedBox(width: 8),
                                      SvgPicture.asset(
                                        'assets/icons/seal-check-fill.svg',
                                        width: 18,
                                        height: 18,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.accent,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Odległość: ${vmState.distanceLabel}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/icons/star-fill.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.accent,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'brak ocen',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SegmentedToggle<_InfoSection>(
                        value: _selectedInfoSection,
                        onChanged: (_InfoSection section) {
                          setState(() => _selectedInfoSection = section);
                        },
                        options: const <SegmentedToggleOption<_InfoSection>>[
                          SegmentedToggleOption<_InfoSection>(
                            value: _InfoSection.address,
                            label: 'Adres',
                            iconAsset: 'assets/icons/map-pin-area.svg',
                          ),
                          SegmentedToggleOption<_InfoSection>(
                            value: _InfoSection.contact,
                            label: 'Kontakt',
                            iconAsset: 'assets/icons/chat-circle-dots.svg',
                          ),
                          SegmentedToggleOption<_InfoSection>(
                            value: _InfoSection.payments,
                            label: 'Płatność',
                            iconAsset: 'assets/icons/hand-coins.svg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _selectedInfoSection.title,
                                style: AppTypography.header,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedInfoSection.contentForSeller(seller),
                                style: AppTypography.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      IgnorePointer(
                        child: Container(
                          height: 66,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: <Widget>[
                              const SizedBox(width: 8),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: AppColors.background,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/icons/star-fill.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.textPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Opinie użytkowników: 18',
                                  style: AppTypography.normal,
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/icons/caret-right.svg',
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.textPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Opis',
                        style: AppTypography.header,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (seller?.description ?? '').isEmpty
                            ? 'Ten sprzedawca nie uzupełnił jeszcze opisu.'
                            : seller!.description,
                        style: AppTypography.normal,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Jakość i certyfikaty',
                        style: AppTypography.header,
                      ),
                      const SizedBox(height: 8),
                      ...() {
                        final certs = _qualityAndCertificatesForSeller(seller);
                        return certs.asMap().entries.map((entry) {
                          final bool isLast = entry.key == certs.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '• ',
                                  style: AppTypography.normal,
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: AppTypography.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      }(),
                      const SizedBox(height: 24),
                      Text(
                        'Wszystkie produkty',
                        style: AppTypography.header,
                      ),
                      const SizedBox(height: 12),
                      if (vmState.products.isEmpty)
                        Text(
                          'Ten sprzedawca nie ma aktywnych produktów.',
                          style: AppTypography.normal,
                        )
                      else
                        ...vmState.products.asMap().entries.map((entry) {
                          final bool isLast =
                              entry.key == vmState.products.length - 1;
                          final ProductUiModel product = entry.value;
                          return ProductTileSmall(
                            name: product.name,
                            distance: product.distance,
                            priceWithUnitLabel: product.pricePerOfferLabel,
                            verified: seller?.isVerified == true,
                            margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder<void>(
                                  pageBuilder: (_, _, _) =>
                                      ProductDetailsScreen(
                                        product: product,
                                        onBack: () =>
                                            Navigator.of(context).pop(),
                                        openedFromSeller: true,
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                          );
                        }),
                    ],
                  ),
                ),
          onBack: widget.onBack,
        );
      },
    ),
    );
  }

}

enum _InfoSection {
  address(title: 'Adres'),
  contact(title: 'Kontakt'),
  payments(title: 'Metody płatności');

  const _InfoSection({required this.title});

  final String title;

  String contentForSeller(ProducerProfile? seller) {
    switch (this) {
      case _InfoSection.address:
        final chunks = <String>[
          if (seller != null && seller.address.trim().isNotEmpty)
            seller.address.trim(),
          if (seller != null &&
              (seller.postalCode.trim().isNotEmpty ||
                  seller.city.trim().isNotEmpty))
            '${seller.postalCode.trim()} ${seller.city.trim()}'.trim(),
          if (seller != null && seller.country.trim().isNotEmpty)
            seller.country.trim(),
        ];
        if (chunks.isEmpty) {
          return 'Adres odbioru nie został jeszcze uzupełniony.';
        }
        return chunks.join('\n');
      case _InfoSection.contact:
        final phone = (seller?.phone ?? '').trim();
        final email = (seller?.email ?? '').trim();
        if (phone.isEmpty && email.isEmpty) {
          return 'Dane kontaktowe nie zostały uzupełnione.';
        }
        if (phone.isEmpty) return 'email: $email';
        if (email.isEmpty) return 'tel. $phone';
        return 'tel. $phone\nemail: $email';
      case _InfoSection.payments:
        final methods = seller?.acceptedPaymentMethods ?? AppPaymentMethod.all;
        return methods.map((AppPaymentMethod m) => m.label).join('\n');
    }
  }
}

List<String> _qualityAndCertificatesForSeller(ProducerProfile? seller) {
  final quality = (seller?.qualityDescription ?? '').trim();
  if (quality.isEmpty) {
    return const <String>[
      'Brak dodatkowych informacji o jakości i certyfikatach.',
    ];
  }
  return <String>[quality];
}
