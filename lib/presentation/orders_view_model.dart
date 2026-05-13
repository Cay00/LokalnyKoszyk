import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokalny_koszyk/core/di/providers.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/order_summary.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';

final ordersViewModelProvider =
    StateNotifierProvider.autoDispose<OrdersViewModel, OrdersState>((ref) {
      return OrdersViewModel(
        cartRepository: ref.read(cartRepositoryProvider),
        ordersRepository: ref.read(ordersRepositoryProvider),
      )..refreshAll();
    });

class OrdersState {
  const OrdersState({
    required this.isLoadingCart,
    required this.isRemovingItem,
    required this.isLoadingOrders,
    required this.cartItems,
    required this.orders,
    this.ordersError,
  });

  factory OrdersState.initial() => const OrdersState(
    isLoadingCart: true,
    isRemovingItem: false,
    isLoadingOrders: true,
    cartItems: <CartItem>[],
    orders: <OrderSummary>[],
  );

  final bool isLoadingCart;
  final bool isRemovingItem;
  final bool isLoadingOrders;
  final String? ordersError;
  final List<CartItem> cartItems;
  final List<OrderSummary> orders;

  OrdersState copyWith({
    bool? isLoadingCart,
    bool? isRemovingItem,
    bool? isLoadingOrders,
    String? ordersError,
    List<CartItem>? cartItems,
    List<OrderSummary>? orders,
  }) {
    return OrdersState(
      isLoadingCart: isLoadingCart ?? this.isLoadingCart,
      isRemovingItem: isRemovingItem ?? this.isRemovingItem,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      ordersError: ordersError,
      cartItems: cartItems ?? this.cartItems,
      orders: orders ?? this.orders,
    );
  }
}

class OrdersViewModel extends StateNotifier<OrdersState> {
  OrdersViewModel({
    required CartRepository cartRepository,
    required OrdersRepository ordersRepository,
  }) : _cartRepository = cartRepository,
       _ordersRepository = ordersRepository,
       super(OrdersState.initial());

  final CartRepository _cartRepository;
  final OrdersRepository _ordersRepository;

  Future<void> loadCart() async {
    state = state.copyWith(isLoadingCart: true);
    try {
      final items = await _cartRepository.getCartItemsForCurrentUser();
      state = state.copyWith(cartItems: items, isLoadingCart: false);
    } catch (_) {
      state = state.copyWith(
        cartItems: const <CartItem>[],
        isLoadingCart: false,
      );
    }
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoadingOrders: true, ordersError: null);
    try {
      final orders = await _ordersRepository.getOrdersForCurrentUser();
      state = state.copyWith(
        orders: orders,
        isLoadingOrders: false,
        ordersError: null,
      );
    } catch (e) {
      state = state.copyWith(
        ordersError: 'Nie udało się pobrać historii zamówień: $e',
        isLoadingOrders: false,
      );
    }
  }

  Future<void> refreshAll() async {
    await Future.wait(<Future<void>>[loadCart(), loadOrders()]);
  }

  Future<String?> removeItem(CartItem item) async {
    if (state.isRemovingItem) return null;
    state = state.copyWith(isRemovingItem: true);
    try {
      await _cartRepository.removeCartItem(cartItemId: item.id);
      state = state.copyWith(
        cartItems: state.cartItems.where((x) => x.id != item.id).toList(),
      );
      return null;
    } catch (e) {
      return 'Nie udało się usunąć produktu: $e';
    } finally {
      state = state.copyWith(isRemovingItem: false);
    }
  }
}

String orderStatusLabel(String rawStatus) {
  switch (rawStatus) {
    case 'placed':
      return 'Złożone';
    case 'in_progress':
      return 'W realizacji';
    case 'rejected':
      return 'Odrzucone';
    case 'sent':
      return 'Wysłane';
    case 'delivered':
      return 'Dostarczone';
    case 'received':
      return 'Odebrane';
    default:
      return rawStatus.isEmpty ? 'Nieznany' : rawStatus;
  }
}

Color orderStatusColor(String rawStatus) {
  switch (rawStatus) {
    case 'placed':
      return AppColors.primary;
    case 'in_progress':
      return AppColors.accent;
    case 'rejected':
      return Colors.redAccent;
    case 'sent':
      return AppColors.primaryLight;
    case 'delivered':
      return AppColors.primary;
    case 'received':
      return AppColors.textLight;
    default:
      return AppColors.textLight;
  }
}

String orderStatusIcon(String rawStatus) {
  switch (rawStatus) {
    case 'placed':
      return 'assets/icons/receipt.svg';
    case 'in_progress':
      return 'assets/icons/clock-countdown.svg';
    case 'rejected':
      return 'assets/icons/question.svg';
    case 'sent':
      return 'assets/icons/package.svg';
    case 'delivered':
    case 'received':
      return 'assets/icons/check-circle.svg';
    default:
      return 'assets/icons/receipt.svg';
  }
}

String formatMoney(double value, String currency) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return '$formatted $currency';
}

String formatOrderDate(DateTime? date) {
  if (date == null) return '—';
  final d = date.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd.$mm';
}
