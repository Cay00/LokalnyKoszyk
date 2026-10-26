import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/favorite_seller.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/favorites_bloc.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/producer/producer_tile.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';
import 'package:lokalny_koszyk/widgets/common/segmented_toggle.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/app_notification.dart';
import '../../widgets/common/default_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  static const List<SegmentedToggleOption<FavoritesTabKind>> _tabOptions =
      <SegmentedToggleOption<FavoritesTabKind>>[
        SegmentedToggleOption<FavoritesTabKind>(
          value: FavoritesTabKind.products,
          label: 'Produkty',
          iconAsset: 'assets/icons/package.svg',
        ),
        SegmentedToggleOption<FavoritesTabKind>(
          value: FavoritesTabKind.sellers,
          label: 'Sprzedawcy',
          iconAsset: 'assets/icons/barn.svg',
        ),
      ];

  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<FavoritesBloc>();
    final int gen = bloc.state.refreshGeneration;
    bloc.add(const FavoritesLoadRequested());
    return bloc.stream.firstWhere(
      (FavoritesState s) => s.refreshGeneration > gen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Ulubione',
      onBack: onBack,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: BlocListener<FavoritesBloc, FavoritesState>(
          listenWhen: (FavoritesState previous, FavoritesState current) =>
              current.feedbackMessage != null &&
              current.feedbackMessage != previous.feedbackMessage,
          listener: (BuildContext context, FavoritesState state) {
            final String? message = state.feedbackMessage;
            if (message == null) return;
            showAppNotification(context, message);
          },
          child: BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (BuildContext context, FavoritesState state) {
              void reloadAfterReturn() {
                if (context.mounted) {
                  context.read<FavoritesBloc>().add(
                    const FavoritesLoadRequested(),
                  );
                }
              }

              void openProductDetails(ProductUiModel product) {
                final String? sid = product.sellerId?.trim();
                final bool hasSeller = sid != null && sid.isNotEmpty;

                Navigator.of(context)
                    .push(
                      PageRouteBuilder<void>(
                        pageBuilder: (_, _, _) => ProductDetailsScreen(
                          product: product,
                          onBack: () => Navigator.of(context).pop(),
                          onOpenProducerDetails: hasSeller
                              ? () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder<void>(
                                      pageBuilder: (_, _, _) =>
                                          ProducerDetailsScreen(
                                            sellerId: sid,
                                            onBack: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  ).then((_) => reloadAfterReturn());
                                }
                              : null,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    )
                    .then((_) => reloadAfterReturn());
              }

              void openSeller(FavoriteSeller seller) {
                Navigator.of(context)
                    .push(
                      PageRouteBuilder<void>(
                        pageBuilder: (_, _, _) => ProducerDetailsScreen(
                          sellerId: seller.id,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    )
                    .then((_) => reloadAfterReturn());
              }

              if (state.isLoading) {
                return RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const <Widget>[
                      SizedBox(height: 120),
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                );
              }
              if (!state.isSignedIn) {
                return RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const <Widget>[
                      SizedBox(height: 48),
                      Text(
                        'Zaloguj się, aby zobaczyć ulubione produkty i sprzedawców.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state.errorText != null) {
                return RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      const SizedBox(height: 48),
                      Text(
                        state.errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: FilledButton(
                          onPressed: () => context.read<FavoritesBloc>().add(
                            const FavoritesLoadRequested(),
                          ),
                          child: const Text('Ponów'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: <Widget>[
                  SegmentedToggle<FavoritesTabKind>(
                    options: _tabOptions,
                    value: state.activeTab,
                    onChanged: (FavoritesTabKind tab) {
                      context.read<FavoritesBloc>().add(
                        FavoritesTabChanged(tab),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _refresh(context),
                      child: state.activeTab == FavoritesTabKind.products
                          ? _ProductsList(
                              items: state.items,
                              onOpenDetails: openProductDetails,
                              onAddToCart: (ProductUiModel product) {
                                context.read<FavoritesBloc>().add(
                                  FavoritesAddToCartRequested(product),
                                );
                              },
                            )
                          : _SellersList(
                              sellers: state.sellers,
                              onOpen: openSeller,
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList({
    required this.items,
    required this.onOpenDetails,
    required this.onAddToCart,
  });

  final List<ProductUiModel> items;
  final ValueChanged<ProductUiModel> onOpenDetails;
  final ValueChanged<ProductUiModel> onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          SizedBox(height: 48),
          Text(
            'Nie obserwujesz jeszcze żadnych produktów.\nDodaj obserwację na karcie produktu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: DefaultScreen.bodyPadding(context, left: 0, top: 0, right: 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final ProductUiModel product = items[index];
        return ProductTile(
          product: product,
          onOpenDetails: () => onOpenDetails(product),
          onAddToCart: () => onAddToCart(product),
        );
      },
    );
  }
}

class _SellersList extends StatelessWidget {
  const _SellersList({
    required this.sellers,
    required this.onOpen,
  });

  final List<FavoriteSeller> sellers;
  final ValueChanged<FavoriteSeller> onOpen;

  @override
  Widget build(BuildContext context) {
    if (sellers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          SizedBox(height: 48),
          Text(
            'Nie masz jeszcze ulubionych sprzedawców.\nDodaj sercem na profilu gospodarstwa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: DefaultScreen.bodyPadding(context, left: 0, top: 0, right: 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sellers.length,
      itemBuilder: (BuildContext context, int index) {
        final FavoriteSeller seller = sellers[index];
        return ProducerTile(
          name: seller.name,
          distance: '',
          rating: '—',
          reviews: '0',
          verified: seller.isVerified,
          onTap: () => onOpen(seller),
        );
      },
    );
  }
}
