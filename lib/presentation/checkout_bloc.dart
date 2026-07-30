import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';

enum DeliveryOption {
  courier('Kurier'),
  pickupPoint('Paczkomat / punkt odbioru'),
  personalPickup('Odbiór osobisty');

  const DeliveryOption(this.label);
  final String label;
}

sealed class CheckoutEvent {
  const CheckoutEvent();
}

final class CheckoutLoadRequested extends CheckoutEvent {
  const CheckoutLoadRequested();
}

final class CheckoutRemoveItemRequested extends CheckoutEvent {
  const CheckoutRemoveItemRequested(this.item);

  final CartItem item;
}

final class CheckoutPayRequested extends CheckoutEvent {
  const CheckoutPayRequested();
}

final class CheckoutDeliveryOptionChanged extends CheckoutEvent {
  const CheckoutDeliveryOptionChanged(this.option);

  final DeliveryOption option;
}

class CheckoutState {
  const CheckoutState({
    required this.isLoading,
    required this.isRemovingItem,
    required this.isPaying,
    required this.items,
    required this.deliveryOption,
    this.errorText,
    this.feedbackMessage,
  });

  factory CheckoutState.initial() => const CheckoutState(
    isLoading: true,
    isRemovingItem: false,
    isPaying: false,
    items: <CartItem>[],
    deliveryOption: DeliveryOption.courier,
  );

  final bool isLoading;
  final bool isRemovingItem;
  final bool isPaying;
  final String? errorText;
  final List<CartItem> items;
  final DeliveryOption deliveryOption;
  final String? feedbackMessage;

  CheckoutState copyWith({
    bool? isLoading,
    bool? isRemovingItem,
    bool? isPaying,
    String? errorText,
    List<CartItem>? items,
    DeliveryOption? deliveryOption,
    Object? feedbackMessage = _unset,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isRemovingItem: isRemovingItem ?? this.isRemovingItem,
      isPaying: isPaying ?? this.isPaying,
      errorText: errorText,
      items: items ?? this.items,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      feedbackMessage: identical(feedbackMessage, _unset)
          ? this.feedbackMessage
          : feedbackMessage as String?,
    );
  }
}

const _unset = Object();

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({required CartRepository cartRepository})
    : _cartRepository = cartRepository,
      super(CheckoutState.initial()) {
    on<CheckoutLoadRequested>(_onLoad);
    on<CheckoutRemoveItemRequested>(_onRemoveItem);
    on<CheckoutPayRequested>(_onPay);
    on<CheckoutDeliveryOptionChanged>(_onDeliveryOptionChanged);
  }

  final CartRepository _cartRepository;

  Future<void> _onLoad(
    CheckoutLoadRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      final items = await _cartRepository.getCartItemsForCurrentUser();
      emit(state.copyWith(items: items, isLoading: false, errorText: null));
    } catch (e) {
      emit(
        state.copyWith(
          errorText: 'Nie udało się pobrać koszyka: $e',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onRemoveItem(
    CheckoutRemoveItemRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state.isRemovingItem) return;
    emit(state.copyWith(isRemovingItem: true, feedbackMessage: null));
    try {
      await _cartRepository.removeCartItem(cartItemId: event.item.id);
      emit(
        state.copyWith(
          items: state.items.where((x) => x.id != event.item.id).toList(),
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

  Future<void> _onPay(
    CheckoutPayRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state.isPaying || state.items.isEmpty) return;
    emit(state.copyWith(isPaying: true, feedbackMessage: null));
    try {
      final result = await _cartRepository.placeOrderFromCurrentCart(
        status: 'placed',
      );
      emit(
        state.copyWith(
          items: <CartItem>[],
          isPaying: false,
          feedbackMessage:
              'Płatność zakończona. Utworzono zamówienie ${result.orderNumber}.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPaying: false,
          feedbackMessage: 'Nie udało się opłacić zamówienia: $e',
        ),
      );
    }
  }

  void _onDeliveryOptionChanged(
    CheckoutDeliveryOptionChanged event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(deliveryOption: event.option));
  }
}
