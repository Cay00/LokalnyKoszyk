import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_cart_repository.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_discover_repository.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_home_repository.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_orders_repository.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_producer_details_repository.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_product_details_repository.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_watched_products_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/discover_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/home_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/producer_details_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/product_details_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repozytoria udostępniane w drzewie widgetów przez [RepositoryProvider].
class AppRepositories extends MultiRepositoryProvider {
  AppRepositories({required super.child, super.key})
    : super(
        providers: <RepositoryProvider<dynamic>>[
          RepositoryProvider<SupabaseClient>(create: (_) => supabase),
          RepositoryProvider<HomeRepository>(
            create: (context) =>
                SupabaseHomeRepository(context.read<SupabaseClient>()),
          ),
          RepositoryProvider<DiscoverRepository>(
            create: (context) =>
                SupabaseDiscoverRepository(context.read<SupabaseClient>()),
          ),
          RepositoryProvider<CartRepository>(
            create: (context) =>
                SupabaseCartRepository(context.read<SupabaseClient>()),
          ),
          RepositoryProvider<ProductDetailsRepository>(
            create: (context) =>
                SupabaseProductDetailsRepository(context.read<SupabaseClient>()),
          ),
          RepositoryProvider<ProducerDetailsRepository>(
            create: (context) => SupabaseProducerDetailsRepository(
              context.read<SupabaseClient>(),
            ),
          ),
          RepositoryProvider<OrdersRepository>(
            create: (context) =>
                SupabaseOrdersRepository(context.read<SupabaseClient>()),
          ),
          RepositoryProvider<WatchedProductsRepository>(
            create: (context) => SupabaseWatchedProductsRepository(
              context.read<SupabaseClient>(),
            ),
          ),
        ],
      );
}
