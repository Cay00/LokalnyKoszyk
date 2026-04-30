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
              child: Stack(
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Eko Zagroda Liski',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
            const Text(
              'Średni czas realizacji zamówienia: 2h 30 min',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),
            const Text(
              'Adres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ul. Zielona 12, 55-040 Kobierzyce',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kontakt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'tel. +48 600 123 456\nemail: kontakt@ekozagroda.pl',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Metody płatności',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'BLIK\nKarta płatnicza\nGotówka przy odbiorze',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 12),
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
