import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';

sealed class OrdersEvent {
  const OrdersEvent();
}

final class OrdersLoadCartRequested extends OrdersEvent {
  const OrdersLoadCartRequested();
}

final class OrdersRefreshAllRequested extends OrdersEvent {
  const OrdersRefreshAllRequested();
}

final class OrdersRemoveItemRequested extends OrdersEvent {
  const OrdersRemoveItemRequested(this.item);

  final CartItem item;
}

final class OrdersAddToCartRequested extends OrdersEvent {
  const OrdersAddToCartRequested(this.productId);

  final String productId;
}

final class OrdersSellerSelectionToggled extends OrdersEvent {
  const OrdersSellerSelectionToggled(this.sellerKey);

  final String sellerKey;
}

class OrdersState {
  const OrdersState({
    required this.isLoadingCart,
    required this.isRemovingItem,
    required this.cartItems,
    this.unselectedSellerKeys = const <String>{},
    this.feedbackMessage,
  });

  factory OrdersState.initial() => const OrdersState(
    isLoadingCart: true,
    isRemovingItem: false,
    cartItems: <CartItem>[],
  );

  final bool isLoadingCart;
  final bool isRemovingItem;
  final List<CartItem> cartItems;
  final Set<String> unselectedSellerKeys;
  final String? feedbackMessage;

  bool isSellerSelected(String sellerKey) =>
      !unselectedSellerKeys.contains(sellerKey);

  List<CartItem> get selectedCartItems => cartItems
      .where((CartItem item) => isSellerSelected(item.sellerKey))
      .toList();

  double get selectedProductsTotal => selectedCartItems.fold<double>(
    0,
    (double sum, CartItem item) => sum + item.lineTotal,
  );

  OrdersState copyWith({
    bool? isLoadingCart,
    bool? isRemovingItem,
    List<CartItem>? cartItems,
    Set<String>? unselectedSellerKeys,
    Object? feedbackMessage = _unset,
  }) {
    return OrdersState(
      isLoadingCart: isLoadingCart ?? this.isLoadingCart,
      isRemovingItem: isRemovingItem ?? this.isRemovingItem,
      cartItems: cartItems ?? this.cartItems,
      unselectedSellerKeys:
          unselectedSellerKeys ?? this.unselectedSellerKeys,
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
    OrdersRepository? ordersRepository,
  }) : _cartRepository = cartRepository,
       super(OrdersState.initial()) {
    on<OrdersLoadCartRequested>(_onLoadCart);
    on<OrdersRefreshAllRequested>(_onRefreshAll);
    on<OrdersRemoveItemRequested>(_onRemoveItem);
    on<OrdersAddToCartRequested>(_onAddToCart);
    on<OrdersSellerSelectionToggled>(_onSellerSelectionToggled);
  }

  final CartRepository _cartRepository;

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

  Future<void> _onRefreshAll(
    OrdersRefreshAllRequested event,
    Emitter<OrdersState> emit,
  ) {
    return _onLoadCart(const OrdersLoadCartRequested(), emit);
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

  Future<void> _onAddToCart(
    OrdersAddToCartRequested event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await _cartRepository.addToCart(productId: event.productId);
      final items = await _cartRepository.getCartItemsForCurrentUser();
      emit(
        state.copyWith(
          cartItems: items,
          feedbackMessage: 'Dodano do koszyka',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          feedbackMessage: 'Nie udało się dodać do koszyka: $e',
        ),
      );
    }
  }

  void _onSellerSelectionToggled(
    OrdersSellerSelectionToggled event,
    Emitter<OrdersState> emit,
  ) {
    final next = Set<String>.from(state.unselectedSellerKeys);
    if (!next.add(event.sellerKey)) {
      next.remove(event.sellerKey);
    }
    emit(state.copyWith(unselectedSellerKeys: next));
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
  final yyyy = d.year.toString();
  return '$dd.$mm.$yyyy';
}
