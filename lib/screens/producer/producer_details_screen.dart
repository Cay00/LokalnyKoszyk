import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/domain/models/producer_profile.dart';
import 'package:lokalny_koszyk/domain/repositories/producer_details_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/producer_details_cubit.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/default_screen.dart';
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
      create: (BuildContext context) => ProducerDetailsCubit(
        repository: context.read<ProducerDetailsRepository>(),
        sellerId: sellerId,
      )..load(),
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
    return BlocBuilder<ProducerDetailsCubit, ProducerDetailsState>(
      builder: (BuildContext context, ProducerDetailsState vmState) {
        final seller = vmState.seller;
        return DefaultScreen(
          title: 'Sprzedawca',
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
                            color: AppColors.textLight,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.read<ProducerDetailsCubit>().load(),
                          child: const Text('Ponów'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: AppColors.lightSage,
                          borderRadius: BorderRadius.circular(AppRadius.normal),
                          border: Border.all(color: AppColors.border),
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
                                  AppColors.primary,
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
                            Positioned(
                              top: 12,
                              right: 12,
                              child: InkWell(
                                onTap: () => context
                                    .read<ProducerDetailsCubit>()
                                    .toggleLike(),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.normal,
                                ),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    vmState.isLiked
                                        ? 'assets/icons/heart-fill.svg'
                                        : 'assets/icons/heart.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                      vmState.isLiked
                                          ? Colors.redAccent
                                          : AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
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
                          borderRadius: BorderRadius.circular(AppRadius.normal),
                          border: Border.all(color: AppColors.border),
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
                                  AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/farm_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (BuildContext context, Object error, StackTrace? stackTrace) =>
                                      const SizedBox.shrink(),
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
                                      AppColors.primary,
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.normal),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: <Widget>[
                              _buildInfoTabButton(
                                label: 'Adres',
                                section: _InfoSection.address,
                              ),
                              _buildInfoTabButton(
                                label: 'Kontakt',
                                section: _InfoSection.contact,
                              ),
                              _buildInfoTabButton(
                                label: 'Płatność',
                                section: _InfoSection.payments,
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: AppColors.border),
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
                                  style: AppTypography.sectionHeader,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedInfoSection.contentForSeller(seller),
                                  style: AppTypography.body,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Opis',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (seller?.description ?? '').isEmpty
                        ? 'Ten sprzedawca nie uzupełnił jeszcze opisu.'
                        : seller!.description,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jakość i certyfikaty',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 8),
                  ..._qualityAndCertificatesForSeller(seller).map(
                    (String item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            '• ',
                            style: AppTypography.body,
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: AppTypography.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Wszystkie produkty',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 12),
                  if (vmState.products.isEmpty)
                    const Text(
                      'Ten sprzedawca nie ma aktywnych produktów.',
                      style: AppTypography.body,
                    )
                  else
                    ...vmState.products.map(
                      (ProductUiModel product) => ProductTileSmall(
                        name: product.name,
                        distance: product.distance,
                        priceWithUnitLabel: product.pricePerOfferLabel,
                        verified: seller?.isVerified == true,
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder<void>(
                              pageBuilder: (_, _, _) => ProductDetailsScreen(
                                product: product,
                                onBack: () => Navigator.of(context).pop(),
                                openedFromSeller: true,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          onBack: widget.onBack,
        );
      },
    );
  }

  Widget _buildInfoTabButton({
    required String label,
    required _InfoSection section,
  }) {
    final bool isSelected = _selectedInfoSection == section;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedInfoSection = section),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

enum _InfoSection {
  address(title: 'Adres'),
  contact(title: 'Kontakt'),
  payments(
    title: 'Metody płatności',
    content: 'BLIK\nKarta płatnicza\nGotówka przy odbiorze',
  );

  const _InfoSection({required this.title, this.content = ''});

  final String title;
  final String content;

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
          // if (seller?.latitude != null && seller?.longitude != null)
          //   'GPS: ${seller!.latitude!.toStringAsFixed(6)}, ${seller.longitude!.toStringAsFixed(6)}',
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
        return content;
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
