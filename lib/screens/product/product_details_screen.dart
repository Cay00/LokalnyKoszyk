import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';
import 'package:lokalny_koszyk/widgets/common/product_info_chip.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/default_screen.dart';
import '../../widgets/home/section_header.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onBack,
  });

  final ProductData product;
  final VoidCallback? onBack;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final _LocalProductDetails details =
        _detailsById[widget.product.id] ?? _fallbackDetails;

    return DefaultScreen(
      title: 'Szczegóły produktu',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: widget.product.bgColor,
                borderRadius: BorderRadius.circular(AppRadius.normal),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Text(
                      widget.product.emoji,
                      style: const TextStyle(fontSize: 92),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.normal),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '🏪',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.product.producer,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            ProductInfoChip(
                              text: widget.product.distance,
                              iconAsset: 'assets/icons/map-pin-area.svg',
                            ),
                            const Spacer(),
                            SvgPicture.asset(
                              'assets/icons/star-fill.svg',
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(
                                AppColors.accent,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.product.reviews})',
                              style: const TextStyle(
                                fontSize: 12,
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
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${widget.product.price} zł',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    Text(
                      widget.product.unit,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.normal),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('+'),
                    SizedBox(width: 8),
                    Text(
                      'Dodaj do koszyka',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Opis'),
            const SizedBox(height: 16),
            Text(
              details.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/icons/seal-percent.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryLight,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Promocja',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/icons/certificate.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryLight,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Chronione Oznaczenie Geograficzne',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const SectionHeader(title: 'Szczegóły produktu'),
            const SizedBox(height: 8),
            ...details.highlights.map(
              (String item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Składniki'),
            const SizedBox(height: 8),
            ...details.ingredients.map(
              (String item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Warunki przechowywania'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (details.requiresColdStorage) ...<Widget>[
                  SvgPicture.asset(
                    'assets/icons/snowflake.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryLight,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Wymaga przechowywania w warunkach chłodzonych',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ] else ...<Widget>[
                  SvgPicture.asset(
                    'assets/icons/snowflake.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryLight,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Nie wymaga przechowywania w warunkach chłodzonych',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              _sharedStorageDetailsText,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      onBack: widget.onBack,
    );
  }
}

const String _sharedStorageDetailsText =
    'Przechowuj produkt w chłodnym miejscu, najlepiej w oryginalnym opakowaniu lub szczelnym pojemniku. '
    '\nPo otwarciu spożyć w możliwie krótkim czasie, zgodnie z informacją na etykiecie lub od sprzedawcy.';

class _LocalProductDetails {
  const _LocalProductDetails({
    required this.description,
    required this.highlights,
    required this.ingredients,
    required this.requiresColdStorage,
  });

  final String description;
  final List<String> highlights;
  final List<String> ingredients;
  final bool requiresColdStorage;
}

const Map<String, _LocalProductDetails> _detailsById = <String, _LocalProductDetails>{
  'hp1': _LocalProductDetails(
    description:
        'Młoda rzodkiewka BIO o delikatnym smaku i chrupiącej strukturze. Uprawiana bez chemicznych środków ochrony roślin, zbierana ręcznie tego samego dnia.',
    highlights: <String>[
      'Pochodzenie: gospodarstwo Zielone Pole, okolice Wrocławia',
      'Uprawa ekologiczna potwierdzona certyfikatem lokalnym',
      'Najlepsza do sałatek, kanapek i twarożku',
    ],
    ingredients: <String>[
      'Rzodkiewka BIO 100%',
    ],
    requiresColdStorage: true,
  ),
  'hp2': _LocalProductDetails(
    description:
        'Jajka od kur z wolnego wybiegu, karmionych naturalnymi paszami. Świeże, zebrane codziennie rano, idealne do śniadań i wypieków.',
    highlights: <String>[
      'Klasa jakości: A, rozmiar M/L',
      'Kury utrzymywane w systemie wolnowybiegowym',
      'Pakowane po 10 sztuk w papierowe opakowanie',
    ],
    ingredients: <String>[
      'Jaja kurze świeże',
    ],
    requiresColdStorage: true,
  ),
  'p1': _LocalProductDetails(
    description:
        'Soczyste pomidory malinowe o słodkim, pełnym smaku. Dojrzewają naturalnie i trafiają do sprzedaży bezpośrednio po zbiorze.',
    highlights: <String>[
      'Odmiana: pomidor malinowy',
      'Idealne do kanapek, sałatek i sosów',
      'Sprzedaż prowadzona bezpośrednio przez producenta',
    ],
    ingredients: <String>[
      'Pomidory malinowe 100%',
    ],
    requiresColdStorage: false,
  ),
  'p2': _LocalProductDetails(
    description:
        'Tradycyjny ser koryciński produkowany z mleka od lokalnych krów. Wyrazisty smak i półtwarda konsystencja sprawdzają się na desce serów i w daniach na ciepło.',
    highlights: <String>[
      'Dojrzewanie: minimum 14 dni',
      'Bez sztucznych konserwantów',
      'Pakowanie próżniowe wydłużające świeżość',
    ],
    ingredients: <String>[
      'Mleko krowie pasteryzowane',
      'Sól',
      'Kultury bakterii mlekowych',
      'Podpuszczka',
    ],
    requiresColdStorage: true,
  ),
};

const _LocalProductDetails _fallbackDetails = _LocalProductDetails(
  description:
      'Świeży produkt od lokalnego producenta. Szczegółowe informacje są sukcesywnie uzupełniane.',
  highlights: <String>[
    'Dostępność sezonowa zależna od zbiorów',
    'Odbiór i dostawa realizowane lokalnie',
    'Wysoka jakość potwierdzona opiniami kupujących',
  ],
  ingredients: <String>[
    'Składniki zostaną uzupełnione wkrótce.',
  ],
  requiresColdStorage: false,
);
