import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';
import '../product/product_tile_small.dart';
import '../../widgets/common/default_screen.dart';

class ProducerDetailsScreen extends StatefulWidget {
  const ProducerDetailsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<ProducerDetailsScreen> createState() => _ProducerDetailsScreenState();
}

class _ProducerDetailsScreenState extends State<ProducerDetailsScreen> {
  bool _isLiked = false;
  _InfoSection _selectedInfoSection = _InfoSection.address;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Sprzedawca',
      body: SingleChildScrollView(
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
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: () => setState(() => _isLiked = !_isLiked),
                      borderRadius: BorderRadius.circular(AppRadius.normal),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          _isLiked
                              ? 'assets/icons/heart-fill.svg'
                              : 'assets/icons/heart.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            _isLiked ? Colors.redAccent : AppColors.primary,
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
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
                          const Flexible(
                            child: Text(
                              'Eko Zagroda Liski',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
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
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Odległość: 4 km',
                        style: TextStyle(
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
                            '4.9',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '(64)',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textLight,
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
            const Text(
              'Średni czas realizacji zamówienia: 2h 30 min',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
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
                    height: 130,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _selectedInfoSection.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedInfoSection.content,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rodzinna farma z okolic Wrocławia, specjalizująca się w ekologicznych warzywach i nabiale. '
              'Od ponad 15 lat prowadzimy uprawy bez chemii, dbając o najwyższą jakość i lokalny charakter produktów.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Jakość i certyfikaty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._qualityAndCertificates.map(
              (String item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Wszystkie produkty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._products.map(
              (_ProductListItem product) => ProductTileSmall(
                name: product.name,
                distance: product.distance,
                price: product.price,
                unit: product.unit,
                verified: true,
              ),
            ),
          ],
        ),
      ),
      onBack: widget.onBack,
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
  address(
    title: 'Adres',
    content: 'ul. Zielona 12,\n55-040 Kobierzyce',
  ),
  contact(
    title: 'Kontakt',
    content: 'tel. +48 600 123 456\nemail: kontakt@ekozagroda.pl',
  ),
  payments(
    title: 'Metody płatności',
    content: 'BLIK\nKarta płatnicza\nGotówka przy odbiorze',
  );

  const _InfoSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}

const List<String> _qualityAndCertificates = <String>[
  'Certyfikat rolnictwa ekologicznego UE',
  'Regularne badania jakości produktów',
];

const List<_ProductListItem> _products = <_ProductListItem>[
  _ProductListItem(name: 'Rzodkiewka BIO', distance: '4 km', price: '20', unit: '0.9 L'),
  _ProductListItem(name: 'Jajka od szczęśliwych kur', distance: '6 km', price: '10', unit: '1 szt.'),
  _ProductListItem(name: 'Ser koryciński tradycyjny', distance: '5 km', price: '28', unit: '0.5 kg'),
  _ProductListItem(name: 'Mleko świeże 3,2%', distance: '3 km', price: '12', unit: '1 L'),
  _ProductListItem(name: 'Masło wiejskie', distance: '7 km', price: '14', unit: '200 g'),
];

class _ProductListItem {
  const _ProductListItem({
    required this.name,
    required this.distance,
    required this.price,
    required this.unit,
  });

  final String name;
  final String distance;
  final String price;
  final String unit;
}
