import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/presentation/discover_bloc.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/widgets/discover/category_tile.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_filter_sheet.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_fulfillment_toggle.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_header.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_search_bar.dart';
import 'package:lokalny_koszyk/screens/product/product_card.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/section_header.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/app_notification.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    this.onOpenProductDetails,
    this.onOpenNotifications,
  });

  final ValueChanged<ProductUiModel>? onOpenProductDetails;
  final VoidCallback? onOpenNotifications;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  DiscoverFulfillmentMode _fulfillmentMode = DiscoverFulfillmentMode.delivery;
  final TextEditingController _searchController = TextEditingController();
  String _deliveryLocationName = '';

  @override
  void initState() {
    super.initState();
    _loadDeliveryLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveryLocation() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    String address = '';
    final meta = user.userMetadata?['default_address'];
    if (meta is String) address = meta.trim();

    try {
      final row = await supabase
          .from('profiles')
          .select('default_address')
          .eq('id', user.id)
          .maybeSingle();
      final fromRow = (row?['default_address'] ?? '').toString().trim();
      if (fromRow.isNotEmpty) address = fromRow;
    } catch (_) {}

    if (!mounted) return;
    setState(() => _deliveryLocationName = address);
  }

  Future<void> _openFilters(DiscoverState state) async {
    final result = await showDiscoverFilterSheet(
      context: context,
      priceFilter: state.priceFilter,
      distanceFilter: state.distanceFilter,
      sortOption: state.sortOption,
    );
    if (!mounted || result == null) return;
    context.read<DiscoverBloc>().add(
      DiscoverFiltersApplied(
        priceFilter: result.price,
        distanceFilter: result.distance,
        sortOption: result.sort,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiscoverBloc, DiscoverState>(
      listenWhen: (DiscoverState previous, DiscoverState current) =>
          current.feedbackMessage != null &&
          current.feedbackMessage != previous.feedbackMessage,
      listener: (BuildContext context, DiscoverState state) {
        final message = state.feedbackMessage;
        if (message == null) return;
        showAppNotification(
          context,
          message,
          duration: message.startsWith('Dodano')
              ? const Duration(milliseconds: 900)
              : const Duration(seconds: 4),
        );
      },
      child: BlocBuilder<DiscoverBloc, DiscoverState>(
        builder: (BuildContext context, DiscoverState state) {
          final visibleProducts = state.visibleProducts;
          return DefaultScreen(
            header: DiscoverHeader(
              locationName: _deliveryLocationName,
              onNotificationsTap: widget.onOpenNotifications,
            ),
            body: RefreshIndicator(
              onRefresh: () {
                final bloc = context.read<DiscoverBloc>();
                final done = bloc.stream.firstWhere(
                  (DiscoverState s) => !s.isLoadingProducts,
                );
                bloc.add(const DiscoverLoadProductsRequested());
                return done;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: DefaultScreen.bodyPadding(
                  context,
                  left: 0,
                  top: 0,
                  right: 0,
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: DiscoverFulfillmentToggle(
                      value: _fulfillmentMode,
                      onChanged: (DiscoverFulfillmentMode mode) {
                        setState(() => _fulfillmentMode = mode);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _PromoBanner(),
                  ),
                  _CategoriesSection(
                    categories: state.categoryItems,
                    activeCategoryId: state.activeCategoryId,
                    onSelect: (String categoryId) {
                      context.read<DiscoverBloc>().add(
                        DiscoverCategoryToggled(categoryId),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: DiscoverSearchBar(
                      controller: _searchController,
                      filterActive: state.hasActiveFilters,
                      onChanged: (String query) {
                        context.read<DiscoverBloc>().add(
                          DiscoverSearchQueryChanged(query),
                        );
                      },
                      onFilterTap: () => _openFilters(state),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SectionHeader(
                          title: 'Popularne produkty',
                          titleCount: state.isLoadingProducts
                              ? null
                              : visibleProducts.length,
                        ),
                        const SizedBox(height: 16),
                        if (state.isLoadingProducts)
                          const Center(child: CircularProgressIndicator())
                        else if (state.productsError != null)
                          Text(
                            state.productsError!,
                            style: AppTypography.normal,
                          )
                        else if (visibleProducts.isEmpty)
                          Text(
                            'Brak produktów do wyświetlenia.',
                            style: AppTypography.normal,
                          )
                        else
                          ProductCardGrid(
                            itemCount: visibleProducts.length,
                            itemBuilder: (BuildContext context, int index) {
                              final ProductUiModel product =
                                  visibleProducts[index];

                              return ProductCard(
                                image: Image.asset(
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
                                name: product.name,
                                size: product.sizeLabel,
                                price: product.priceLabel,
                                onTap: () =>
                                    widget.onOpenProductDetails?.call(product),
                                onAddToCart: () {
                                  context.read<DiscoverBloc>().add(
                                    DiscoverAddToCartRequested(product),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(AppRadius.normal),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Sezon wiosenny!', style: AppTypography.header),
          ),
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({
    required this.categories,
    required this.activeCategoryId,
    required this.onSelect,
  });

  final List<DiscoverCategoryItem> categories;
  final String? activeCategoryId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (BuildContext context, int index) {
              final DiscoverCategoryItem category = categories[index];
              final bool active = activeCategoryId == category.id;
              return CategoryTile(
                iconAsset: category.iconAsset,
                name: category.name,
                count: category.count,
                active: active,
                onTap: () => onSelect(category.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

