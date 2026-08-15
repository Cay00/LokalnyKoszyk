import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/product_details_bloc.dart';
import 'package:lokalny_koszyk/screens/producer/producer_tile.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/default_screen.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/section_header.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onBack,
    this.onOpenProducerDetails,
    this.openedFromSeller = false,
  });

  final ProductUiModel product;
  final VoidCallback? onBack;
  final VoidCallback? onOpenProducerDetails;
  final bool openedFromSeller;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ProductDetailsBloc(
        watchedProductsRepository: context.read<WatchedProductsRepository>(),
        cartRepository: context.read<CartRepository>(),
        product: product,
      )..add(const ProductDetailsStarted()),
      child: _ProductDetailsBody(
        product: product,
        onBack: onBack,
        onOpenProducerDetails: onOpenProducerDetails,
        openedFromSeller: openedFromSeller,
      ),
    );
  }
}

class _ProductDetailsBody extends StatelessWidget {
  const _ProductDetailsBody({
    required this.product,
    this.onBack,
    this.onOpenProducerDetails,
    this.openedFromSeller = false,
  });

  final ProductUiModel product;
  final VoidCallback? onBack;
  final VoidCallback? onOpenProducerDetails;
  final bool openedFromSeller;

  String _producerDisplayName(ProductDetailsState state) {
    final fromDb = state.sellerNameFromDb?.trim();
    if (fromDb != null && fromDb.isNotEmpty) return fromDb;
    final fromProduct = product.producer.trim();
    if (fromProduct.isNotEmpty) return fromProduct;
    return 'Sprzedawca';
  }

  Future<void> _addToCart(BuildContext context) async {
    context.read<ProductDetailsBloc>().add(
      const ProductDetailsAddToCartRequested(),
    );
  }

  void _onFavoriteTap(BuildContext context) {
    context.read<ProductDetailsBloc>().add(
      const ProductDetailsToggleFavoriteRequested(),
    );
  }

  void _handleOpenProducer(BuildContext context) {
    if (openedFromSeller) {
      Navigator.of(context).pop();
      return;
    }
    onOpenProducerDetails?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductDetailsBloc, ProductDetailsState>(
      listenWhen: (ProductDetailsState previous, ProductDetailsState current) =>
          current.feedbackMessage != null &&
          current.feedbackMessage != previous.feedbackMessage,
      listener: (BuildContext context, ProductDetailsState state) {
        final message = state.feedbackMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      child: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (BuildContext context, ProductDetailsState vmState) {
        final _LocalProductDetails details =
            _detailsById[product.id] ?? _fallbackDetails;

        return DefaultScreen(
          title: 'Szczegóły produktu',
          actions: <Widget>[
            ScreenHeaderButton(
              onPressed: vmState.favoriteBusy || vmState.isFavorite == null
                  ? null
                  : () => _onFavoriteTap(context),
              splash: false,
              child: SvgPicture.asset(
                vmState.isFavorite == true
                    ? 'assets/icons/heart-fill.svg'
                    : 'assets/icons/heart.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  vmState.isFavorite == true
                      ? Colors.redAccent
                      : AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
          body: SingleChildScrollView(
            padding: DefaultScreen.bodyPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 220,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: product.bgColor,
                    borderRadius: BorderRadius.circular(AppRadius.normal),
                    border: Border.all(color: AppColors.background),
                  ),
                  child: Image.asset(
                    'assets/images/food_default.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) => ColoredBox(color: product.bgColor),
                  ),
                ),
                const SizedBox(height: 16),
                ProducerTile(
                  name: _producerDisplayName(vmState),
                  distance: product.distance,
                  rating: product.rating,
                  reviews: '16',
                  verified: true,
                  onTap: () => _handleOpenProducer(context),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTypography.header,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          product.pricePerOfferLabel,
                          textAlign: TextAlign.right,
                          style: AppTypography.header,
                        ),
                        if (!product.hasKnownDbUnit &&
                            product.unit.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            product.unit,
                            style: AppTypography.caption,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '*Najniższa cena z ostatnich 30 dni: ${product.pricePerOfferLabel}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    _QuantityCircleButton(
                      icon: Icons.remove,
                      backgroundColor: Colors.transparent,
                      showBorder: true,
                      onPressed: vmState.selectedQuantity > 1
                          ? () => context.read<ProductDetailsBloc>().add(
                                const ProductDetailsDecreaseQuantityRequested(),
                              )
                          : null,
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${vmState.selectedQuantity}',
                        textAlign: TextAlign.center,
                        style: AppTypography.header,
                      ),
                    ),
                    _QuantityCircleButton(
                      icon: Icons.add,
                      backgroundColor: AppColors.accent,
                      showBorder: false,
                      onPressed: vmState.selectedQuantity < 99
                          ? () => context.read<ProductDetailsBloc>().add(
                                const ProductDetailsIncreaseQuantityRequested(),
                              )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: vmState.isAddingToCart
                              ? null
                              : () => _addToCart(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Dodaj do koszyka',
                            style: AppTypography.header,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Opis'),
            const SizedBox(height: 16),
            Text(
              details.description,
              style: AppTypography.normal.copyWith(height: 1.5),
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
            //         AppColors.accent,
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
            //         AppColors.accent,
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
            const SectionHeader(title: 'Dostępność'),
            const SizedBox(height: 12),
            _MonthAvailabilityGrid(monthsAvailable: details.availableMonthIndices),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Składniki'),
            const SizedBox(height: 8),
            ...details.ingredients.map(
              (String item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '• ',
                      style: AppTypography.normal,
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTypography.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Warunki przechowywania'),
            const SizedBox(height: 8),
            Text(
              details.requiresColdStorage
                  ? 'Wymaga przechowywania w warunkach chłodzonych'
                  : 'Nie wymaga przechowywania w warunkach chłodzonych',
              style: AppTypography.normal,
            ),
            const SizedBox(height: 8),
            Text(
              _sharedStorageDetailsText,
              style: AppTypography.normal.copyWith(height: 1.5),
            ),
              ],
            ),
          ),
          onBack: onBack,
        );
      },
    ),
    );
  }
}

class _QuantityCircleButton extends StatelessWidget {
  const _QuantityCircleButton({
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
    this.showBorder = true,
  });

  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Material(
        color: backgroundColor,
        shape: CircleBorder(
          side: showBorder
              ? const BorderSide(color: AppColors.textPrimary)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            size: 22,
            color: onPressed != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
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
                      color: active ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(25),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _polishMonthLabels[month - 1],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: AppTypography.tinyCaptionDark,
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
