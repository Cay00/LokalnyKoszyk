import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokalny_koszyk/presentation/discover_view_model.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_filters.dart';
import 'package:lokalny_koszyk/widgets/discover/category_tile.dart';
import 'package:lokalny_koszyk/screens/product/product_card.dart';
import 'package:lokalny_koszyk/widgets/common/search_bar.dart';
import 'package:lokalny_koszyk/widgets/common/section_header.dart';

import '../core/themes/app_theme.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key, this.onOpenProductDetails});

  final ValueChanged<ProductUiModel>? onOpenProductDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoverViewModelProvider);
    final vm = ref.read(discoverViewModelProvider.notifier);
    final visibleProducts = state.visibleProducts;
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text('Odkrywaj', style: AppTypography.header),
              SizedBox(height: 16),
              DiscoverSearchBar(),
            ],
          ),
        ),
        _CategoriesSection(
          categories: vm.categoryItems,
          activeCategoryId: state.activeCategoryId,
          onSelect: vm.toggleCategory,
        ),
        DiscoverFilters(
          filters: DiscoverViewModel.filters,
          activeFilter: state.activeFilter,
          onFilterSelected: vm.setActiveFilter,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionHeader(
                title: 'Wyniki',
                titleCount: state.isLoadingProducts ? null : visibleProducts.length,
              ),
              const SizedBox(height: 16),

              if (state.isLoadingProducts)
                const Center(child: CircularProgressIndicator())
              else if (state.productsError != null)
                Text(state.productsError!, style: AppTypography.body)
              else if (visibleProducts.isEmpty)
                const Text(
                  'Brak produktów do wyświetlenia.',
                  style: AppTypography.body,
                )
              else
                ProductCardGrid(
                  itemCount: visibleProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ProductUiModel product = visibleProducts[index];

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
                      price: product.pricePerOfferLabel,
                      onTap: () => onOpenProductDetails?.call(product),
                      onAddToCart: () async {
                        final error = await vm.addToCart(product);
                        if (!context.mounted) return;
                        if (error == null) {
                          final cartCount = ref.read(discoverViewModelProvider).cartCount;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 900),
                              content: Text(
                                'Dodano do koszyka: ${product.name} (razem: $cartCount)',
                              ),
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ],
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
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: SectionHeader(
            title: 'Kategorie',
            actionLabel: 'Zobacz wszystkie',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final DiscoverCategoryItem category = categories[index];
              final bool active = activeCategoryId == category.id;
              return CategoryTile(
                icon: category.icon,
                name: category.name,
                count: category.count,
                active: active,
                onTap: () => onSelect(category.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
