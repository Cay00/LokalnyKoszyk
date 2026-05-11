import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/supabase/cart_repository.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';
import 'package:lokalny_koszyk/screens/producer/producer_tile.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/default_screen.dart';
import '../../widgets/common/section_header.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onBack,
    this.onOpenProducerDetails,
    this.openedFromSeller = false,
  });

  final ProductData product;
  final VoidCallback? onBack;
  final VoidCallback? onOpenProducerDetails;
  final bool openedFromSeller;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLiked = false;
  bool _isAddingToCart = false;
  int _selectedQuantity = 1;

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);
    try {
      await CartRepository.addToCart(
        productId: widget.product.id,
        quantityToAdd: _selectedQuantity,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dodano do koszyka: ${widget.product.name} x$_selectedQuantity',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się dodać do koszyka: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _handleOpenProducer() {
    if (widget.openedFromSeller) {
      Navigator.of(context).pop();
      return;
    }
    widget.onOpenProducerDetails?.call();
  }

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
            ProducerTile(
              name: widget.product.producer,
              distance: widget.product.distance,
              rating: widget.product.rating,
              reviews: '16',
              verified: true,
              onTap: _handleOpenProducer,
            ),
            const SizedBox(height: 8),
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
                      widget.product.pricePerOfferLabel,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    if (!widget.product.hasKnownDbUnit &&
                        widget.product.unit.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        widget.product.unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '*Najniższa cena z ostatnich 30 dni: ${widget.product.pricePerOfferLabel}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.normal),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: _selectedQuantity > 1
                          ? AppColors.primaryLight
                          : AppColors.border,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.normal),
                        bottomLeft: Radius.circular(AppRadius.normal),
                      ),
                    ),
                    child: IconButton(
                      onPressed: _selectedQuantity > 1
                          ? () => setState(() => _selectedQuantity--)
                          : null,
                      icon: Icon(
                        Icons.remove,
                        size: 16,
                        color: _selectedQuantity > 1
                            ? AppColors.white
                            : AppColors.textLight,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_selectedQuantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppRadius.normal),
                        bottomRight: Radius.circular(AppRadius.normal),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => setState(() => _selectedQuantity++),
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: AppColors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAddingToCart ? null : _addToCart,
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
            const SizedBox(height: 24),
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
            // const SizedBox(height: 16),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: <Widget>[
            //     SvgPicture.asset(
            //       'assets/icons/seal-percent.svg',
            //       width: 22,
            //       height: 22,
            //       colorFilter: const ColorFilter.mode(
            //         AppColors.primaryLight,
            //         BlendMode.srcIn,
            //       ),
            //     ),
            //     const SizedBox(width: 8),
            //     const Expanded(
            //       child: Text(
            //         'Promocja',
            //         style: TextStyle(
            //           fontSize: 14,
            //           fontWeight: FontWeight.w500,
            //           color: AppColors.textPrimary,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: <Widget>[
            //     SvgPicture.asset(
            //       'assets/icons/certificate.svg',
            //       width: 22,
            //       height: 22,
            //       colorFilter: const ColorFilter.mode(
            //         AppColors.primaryLight,
            //         BlendMode.srcIn,
            //       ),
            //     ),
            //     const SizedBox(width: 8),
            //     const Expanded(
            //       child: Text(
            //         'Chronione Oznaczenie Geograficzne',
            //         style: TextStyle(
            //           fontSize: 14,
            //           fontWeight: FontWeight.w500,
            //           color: AppColors.textPrimary,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 24),
            // const SectionHeader(title: 'Dostępność'),
            // const SizedBox(height: 12),
            // _MonthAvailabilityGrid(monthsAvailable: details.availableMonthIndices),
            // const SizedBox(height: 24),
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

const List<String> _polishMonthLabels = <String>[
  'Styczeń',
  'Luty',
  'Marzec',
  'Kwiecień',
  'Maj',
  'Czerwiec',
  'Lipiec',
  'Sierpień',
  'Wrzesień',
  'Październik',
  'Listopad',
  'Grudzień',
];

class _MonthAvailabilityGrid extends StatelessWidget {
  const _MonthAvailabilityGrid({
    required this.monthsAvailable,
  });

  final Set<int> monthsAvailable;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(3, (int row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row < 2 ? 8 : 0),
          child: Row(
            children: List<Widget>.generate(4, (int col) {
              final int month = row * 4 + col + 1;
              final bool active = monthsAvailable.contains(month);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: col < 3 ? 8 : 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: active ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _polishMonthLabels[month - 1],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                                  color: active ? AppColors.white : AppColors.textLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
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
    required this.availableMonthIndices,
  });

  final String description;
  final List<String> highlights;
  final List<String> ingredients;
  final bool requiresColdStorage;
  final Set<int> availableMonthIndices;
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
    availableMonthIndices: <int>{3, 4, 5, 6},
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
    availableMonthIndices: <int>{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
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
    availableMonthIndices: <int>{6, 7, 8, 9, 10},
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
    availableMonthIndices: <int>{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
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
    'Brak dodatkowych składników.',
  ],
  requiresColdStorage: false,
  availableMonthIndices: <int>{5, 6, 7, 8, 9},
);
