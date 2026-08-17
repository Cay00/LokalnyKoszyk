import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/screens/producer/producer_tile.dart';
import 'package:lokalny_koszyk/screens/product/product_card.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';
import 'package:lokalny_koszyk/screens/product/product_tile_small.dart';
import 'package:lokalny_koszyk/widgets/app_bottom_navigation_bar.dart';
import 'package:lokalny_koszyk/widgets/common/add_to_cart_icon_button.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/menu_action_button.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';
import 'package:lokalny_koszyk/widgets/common/quantity_selector.dart';
import 'package:lokalny_koszyk/widgets/common/product_info_chip.dart';
import 'package:lokalny_koszyk/widgets/common/screen_header.dart';
import 'package:lokalny_koszyk/widgets/common/section_header.dart';
import 'package:lokalny_koszyk/widgets/common/segmented_toggle.dart';
import 'package:lokalny_koszyk/widgets/discover/category_tile.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_fulfillment_toggle.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_header.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  static const ProductUiModel _sampleEggs = ProductUiModel(
    id: 'dev-eggs',
    name: 'Jajka wiejskie',
    producer: 'Gospodarstwo Zielona Dolina',
    price: '12,99',
    unit: '/szt',
    distance: '2,4 km',
    rating: '4.8',
    reviews: '24',
    bgColor: AppColors.background,
    sellerId: 'dev-seller',
    unitKey: 'piece',
    packageQuantity: 10,
    categoryId: 'nabial',
  );

  static const ProductUiModel _sampleHoney = ProductUiModel(
    id: 'dev-honey',
    name: 'Miód lipowy',
    producer: 'Pasieka nad Odrą',
    price: '34,50',
    unit: '/g',
    distance: '5,1 km',
    rating: '4.9',
    reviews: '61',
    bgColor: AppColors.background,
    sellerId: 'dev-seller-2',
    unitKey: 'g',
    packageQuantity: 500,
    categoryId: 'spiżarnia',
    oldPrice: '39,90',
  );

  static const List<({String id, String iconAsset, String name, int count})>
  _sampleCategories =
      <({String id, String iconAsset, String name, int count})>[
        (
          id: 'warzywa',
          iconAsset: 'assets/categories/carrot.svg',
          name: 'Warzywa',
          count: 18,
        ),
        (
          id: 'owoce',
          iconAsset: 'assets/categories/potted-plant.svg',
          name: 'Owoce',
          count: 12,
        ),
        (
          id: 'nabial',
          iconAsset: 'assets/categories/cow.svg',
          name: 'Nabiał',
          count: 9,
        ),
        (
          id: 'pieczywo',
          iconAsset: 'assets/categories/bread.svg',
          name: 'Pieczywo',
          count: 7,
        ),
      ];

  String _segment = 'adres';
  DiscoverFulfillmentMode _fulfillmentMode = DiscoverFulfillmentMode.delivery;
  String _activeCategoryId = 'warzywa';
  int _navIndex = 0;
  int _quantity = 1;

  Widget _productImage() {
    return Image.asset(
      'assets/images/food_default.png',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) =>
              const ColoredBox(color: AppColors.background),
    );
  }

  Widget _headerIcon(String asset) {
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(
        AppColors.textPrimary,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Ekran deweloperski',
      onBack: widget.onBack,
      body: ListView(
        padding: DefaultScreen.bodyPadding(context, left: 0, right: 0),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Katalog wielokrotnie używanych komponentów. '
              'Ten ekran jest owinięty w DefaultScreen.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          _ComponentPreview(
            name: 'ScreenHeader',
            fullBleed: true,
            child: ScreenHeader(
              title: 'Przykładowy tytuł',
              leading: ScreenHeaderBackButton(onPressed: () {}),
              actions: <Widget>[
                ScreenHeaderButton(
                  onPressed: () {},
                  child: _headerIcon('assets/icons/heart.svg'),
                ),
              ],
            ),
          ),
          _ComponentPreview(
            name: 'ScreenHeaderButton / ScreenHeaderBackButton',
            child: Row(
              children: <Widget>[
                ScreenHeaderBackButton(onPressed: () {}),
                const SizedBox(width: 8),
                ScreenHeaderButton(
                  onPressed: () {},
                  child: _headerIcon('assets/icons/magnifying-glass.svg'),
                ),
                const SizedBox(width: 8),
                ScreenHeaderButton(
                  onPressed: () {},
                  child: _headerIcon('assets/icons/bell.svg'),
                ),
                const SizedBox(width: 8),
                ScreenHeaderButton(
                  onPressed: () {},
                  splash: false,
                  child: _headerIcon('assets/icons/share-network.svg'),
                ),
              ],
            ),
          ),
          _ComponentPreview(
            name: 'DiscoverHeader',
            fullBleed: true,
            child: DiscoverHeader(
              locationName: 'Wrocław, Nadodrze',
              onNotificationsTap: () {},
              onSearchChanged: (_) {},
            ),
          ),
          _ComponentPreview(
            name: 'SectionHeader',
            child: const SectionHeader(
              title: 'Popularne produkty',
              titleCount: 12,
              actionLabel: 'Zobacz wszystkie',
            ),
          ),
          _ComponentPreview(
            name: 'SegmentedToggle',
            child: SegmentedToggle<String>(
              value: _segment,
              onChanged: (String value) => setState(() => _segment = value),
              options: const <SegmentedToggleOption<String>>[
                SegmentedToggleOption<String>(
                  value: 'adres',
                  label: 'Adres',
                  iconAsset: 'assets/icons/map-pin-area.svg',
                ),
                SegmentedToggleOption<String>(
                  value: 'kontakt',
                  label: 'Kontakt',
                  iconAsset: 'assets/icons/chat-circle-dots.svg',
                ),
                SegmentedToggleOption<String>(
                  value: 'platnosc',
                  label: 'Płatność',
                  iconAsset: 'assets/icons/hand-coins.svg',
                ),
              ],
            ),
          ),
          _ComponentPreview(
            name: 'DiscoverFulfillmentToggle',
            child: DiscoverFulfillmentToggle(
              value: _fulfillmentMode,
              onChanged: (DiscoverFulfillmentMode mode) {
                setState(() => _fulfillmentMode = mode);
              },
            ),
          ),
          _ComponentPreview(
            name: 'CategoryTile',
            fullBleed: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  for (final category in _sampleCategories) ...<Widget>[
                    Expanded(
                      child: CategoryTile(
                        iconAsset: category.iconAsset,
                        name: category.name,
                        count: category.count,
                        active: _activeCategoryId == category.id,
                        onTap: () {
                          setState(() => _activeCategoryId = category.id);
                        },
                      ),
                    ),
                    if (category != _sampleCategories.last)
                      const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          _ComponentPreview(
            name: 'ProductInfoChip',
            child: const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ProductInfoChip(text: 'Bio'),
                ProductInfoChip(
                  text: '2,4 km',
                  iconAsset: 'assets/icons/map-pin-area.svg',
                ),
                ProductInfoChip(
                  text: '4.8 (24)',
                  iconAsset: 'assets/icons/star-fill.svg',
                ),
              ],
            ),
          ),
          _ComponentPreview(
            name: 'ProductCard / ProductCardGrid',
            child: ProductCardGrid(
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                final ProductUiModel product =
                    index == 0 ? _sampleEggs : _sampleHoney;
                return ProductCard(
                  image: _productImage(),
                  name: product.name,
                  size: product.sizeLabel,
                  price: product.priceLabel,
                  oldPrice: index == 1 ? '39,90 zł' : null,
                  onTap: () {},
                  onAddToCart: () {},
                );
              },
            ),
          ),
          _ComponentPreview(
            name: 'ProductTile',
            child: Column(
              children: <Widget>[
                ProductTile(
                  product: _sampleEggs,
                  onOpenDetails: () {},
                  onAddToCart: () {},
                ),
                const SizedBox(height: 8),
                ProductTile(
                  product: _sampleHoney,
                  onOpenDetails: () {},
                  onAddToCart: () {},
                ),
              ],
            ),
          ),
          _ComponentPreview(
            name: 'ProductTileSmall',
            child: ProductTileSmall(
              name: _sampleHoney.name,
              distance: _sampleHoney.distance,
              priceWithUnitLabel: _sampleHoney.pricePerOfferLabel,
              verified: true,
              margin: EdgeInsets.zero,
              onTap: () {},
            ),
          ),
          _ComponentPreview(
            name: 'ProducerTile',
            child: ProducerTile(
              name: _sampleEggs.producer,
              subtitle: 'Warzywa, nabiał i przetwory',
              distance: _sampleEggs.distance,
              rating: _sampleEggs.rating,
              reviews: _sampleEggs.reviews,
              verified: true,
              onTap: () {},
            ),
          ),
          _ComponentPreview(
            name: 'AddToCartIconButton',
            child: Align(
              alignment: Alignment.centerLeft,
              child: AddToCartIconButton(onPressed: () {}),
            ),
          ),
          _ComponentPreview(
            name: 'QuantitySelector',
            child: Align(
              alignment: Alignment.centerLeft,
              child: QuantitySelector(
                quantity: _quantity,
                onIncrease: () => setState(() => _quantity++),
                onDecrease: () => setState(() => _quantity--),
              ),
            ),
          ),
          _ComponentPreview(
            name: 'PrimaryActionButton',
            child: PrimaryActionButton(
              label: 'Dodaj do koszyka',
              onPressed: () {},
            ),
          ),
          _ComponentPreview(
            name: 'MenuActionButton',
            child: Column(
              children: <Widget>[
                MenuActionButton(
                  iconAsset: 'assets/icons/package.svg',
                  label: 'Moje zamówienia',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                MenuActionButton(
                  iconAsset: 'assets/icons/barn.svg',
                  label: 'Zostań sprzedawcą',
                  backgroundColor: AppColors.accent,
                  onTap: () {},
                ),
              ],
            ),
          ),
          _ComponentPreview(
            name: 'showAppNotification',
            child: PrimaryActionButton(
              label: 'Pokaż powiadomienie',
              onPressed: () {
                showAppNotification(
                  context,
                  'Dodano jajka wiejskie do koszyka',
                );
              },
            ),
          ),
          _ComponentPreview(
            name: 'AppBottomNavigationBar',
            fullBleed: true,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewPadding: EdgeInsets.zero,
                padding: EdgeInsets.zero,
              ),
              child: AppBottomNavigationBar(
                currentIndex: _navIndex,
                onTap: (int index) => setState(() => _navIndex = index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentPreview extends StatelessWidget {
  const _ComponentPreview({
    required this.name,
    required this.child,
    this.fullBleed = false,
  });

  final String name;
  final Widget child;
  final bool fullBleed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(name, style: AppTypography.normalBold),
          ),
          if (fullBleed)
            child
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
