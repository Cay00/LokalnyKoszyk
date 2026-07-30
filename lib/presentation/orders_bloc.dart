import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/order_summary.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';

sealed class OrdersEvent {
  const OrdersEvent();
}

final class OrdersLoadCartRequested extends OrdersEvent {
  const OrdersLoadCartRequested();
}

final class OrdersLoadOrdersRequested extends OrdersEvent {
  const OrdersLoadOrdersRequested();
}

final class OrdersRefreshAllRequested extends OrdersEvent {
  const OrdersRefreshAllRequested();
}

final class OrdersRemoveItemRequested extends OrdersEvent {
  const OrdersRemoveItemRequested(this.item);

  final CartItem item;
}

class OrdersState {
  const OrdersState({
    required this.isLoadingCart,
    required this.isRemovingItem,
    required this.isLoadingOrders,
    required this.cartItems,
    required this.orders,
    this.ordersError,
    this.feedbackMessage,
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
  final String? feedbackMessage;

  OrdersState copyWith({
    bool? isLoadingCart,
    bool? isRemovingItem,
    bool? isLoadingOrders,
    String? ordersError,
    List<CartItem>? cartItems,
    List<OrderSummary>? orders,
    Object? feedbackMessage = _unset,
  }) {
    return OrdersState(
      isLoadingCart: isLoadingCart ?? this.isLoadingCart,
      isRemovingItem: isRemovingItem ?? this.isRemovingItem,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      ordersError: ordersError,
      cartItems: cartItems ?? this.cartItems,
      orders: orders ?? this.orders,
      feedbackMessage: identical(feedbackMessage, _unset)
          ? this.feedbackMessage
          : feedbackMessage as String?,
    );
  }
}

const _unset = Object();

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({
    required CartRepository cartRepository,
    required OrdersRepository ordersRepository,
  }) : _cartRepository = cartRepository,
       _ordersRepository = ordersRepository,
       super(OrdersState.initial()) {
    on<OrdersLoadCartRequested>(_onLoadCart);
    on<OrdersLoadOrdersRequested>(_onLoadOrders);
    on<OrdersRefreshAllRequested>(_onRefreshAll);
    on<OrdersRemoveItemRequested>(_onRemoveItem);
  }

  final CartRepository _cartRepository;
  final OrdersRepository _ordersRepository;

  Future<void> _onLoadCart(
    OrdersLoadCartRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isLoadingCart: true));
    try {
      final items = await _cartRepository.getCartItemsForCurrentUser();
      emit(state.copyWith(cartItems: items, isLoadingCart: false));
    } catch (_) {
      emit(
        state.copyWith(
          cartItems: const <CartItem>[],
          isLoadingCart: false,
        ),
      );
    }
  }

  Future<void> _onLoadOrders(
    OrdersLoadOrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isLoadingOrders: true, ordersError: null));
    try {
      final orders = await _ordersRepository.getOrdersForCurrentUser();
      emit(
        state.copyWith(
          orders: orders,
          isLoadingOrders: false,
          ordersError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          ordersError: 'Nie udało się pobrać historii zamówień: $e',
          isLoadingOrders: false,
        ),
      );
    }
  }

  Future<void> _onRefreshAll(
    OrdersRefreshAllRequested event,
    Emitter<OrdersState> emit,
  ) async {
    await _onLoadCart(const OrdersLoadCartRequested(), emit);
    await _onLoadOrders(const OrdersLoadOrdersRequested(), emit);
  }

  Future<void> _onRemoveItem(
    OrdersRemoveItemRequested event,
    Emitter<OrdersState> emit,
  ) async {
    if (state.isRemovingItem) return;
    emit(state.copyWith(isRemovingItem: true, feedbackMessage: null));
    try {
      await _cartRepository.removeCartItem(cartItemId: event.item.id);
      emit(
        state.copyWith(
          cartItems: state.cartItems
              .where((x) => x.id != event.item.id)
              .toList(),
          isRemovingItem: false,
          feedbackMessage: 'Usunięto z koszyka: ${event.item.name}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isRemovingItem: false,
          feedbackMessage: 'Nie udało się usunąć produktu: $e',
        ),
      );
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
      return AppColors.accent;
    case 'in_progress':
      return AppColors.accent;
    case 'rejected':
      return Colors.redAccent;
    case 'sent':
      return AppColors.accent;
    case 'delivered':
      return AppColors.accent;
    case 'received':
      return AppColors.textSecondary;
    default:
      return AppColors.textSecondary;
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
