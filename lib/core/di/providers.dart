import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Providery Riverpoda odpowiedzialne za udostępnianie
/// klienta Supabase oraz repozytoriów używanych w aplikacji.
final supabaseClientProvider = Provider<SupabaseClient>((ref) => supabase);

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => SupabaseHomeRepository(ref.read(supabaseClientProvider)),
);

final discoverRepositoryProvider = Provider<DiscoverRepository>(
  (ref) => SupabaseDiscoverRepository(ref.read(supabaseClientProvider)),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => SupabaseCartRepository(ref.read(supabaseClientProvider)),
);

final productDetailsRepositoryProvider = Provider<ProductDetailsRepository>(
  (ref) => SupabaseProductDetailsRepository(ref.read(supabaseClientProvider)),
);

final producerDetailsRepositoryProvider = Provider<ProducerDetailsRepository>(
  (ref) => SupabaseProducerDetailsRepository(ref.read(supabaseClientProvider)),
);

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => SupabaseOrdersRepository(ref.read(supabaseClientProvider)),
);

final watchedProductsRepositoryProvider = Provider<WatchedProductsRepository>(
  (ref) => SupabaseWatchedProductsRepository(ref.read(supabaseClientProvider)),
);
