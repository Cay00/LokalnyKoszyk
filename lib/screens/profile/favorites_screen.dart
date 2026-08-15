import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/favorites_bloc.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/app_notification.dart';
import '../../widgets/common/default_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.onBack});

  final VoidCallback? onBack;

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
              void openProductDetails(ProductUiModel product) {
                final String? sid = product.sellerId?.trim();
                final bool hasSeller = sid != null && sid.isNotEmpty;

                Navigator.of(context).push(
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
                              );
                            }
                          : null,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }

              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!state.isSignedIn) {
                return const Center(
                  child: Text(
                    'Zaloguj się, aby zobaczyć obserwowane produkty.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              if (state.errorText != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        state.errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.read<FavoritesBloc>().add(
                          const FavoritesLoadRequested(),
                        ),
                        child: const Text('Ponów'),
                      ),
                    ],
                  ),
                );
              }
              if (state.items.isEmpty) {
                return const Center(
                  child: Text(
                    'Nie obserwujesz jeszcze żadnych produktów.\nDodaj obserwację na karcie produktu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () {
                  final bloc = context.read<FavoritesBloc>();
                  bloc.add(const FavoritesLoadRequested());
                  return bloc.stream.firstWhere(
                    (FavoritesState s) => !s.isLoading,
                  );
                },
                child: ListView.separated(
                  padding: DefaultScreen.bodyPadding(
                    context,
                    left: 0,
                    top: 0,
                    right: 0,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.items.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final ProductUiModel product = state.items[index];
                    return ProductTile(
                      product: product,
                      onOpenDetails: () => openProductDetails(product),
                      onAddToCart: () {
                        context.read<FavoritesBloc>().add(
                          FavoritesAddToCartRequested(product),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
