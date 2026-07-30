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

class CheckoutState {
  const CheckoutState({
    required this.isLoading,
    required this.isRemovingItem,
    required this.isPaying,
    required this.items,
    required this.deliveryOption,
    this.errorText,
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

  CheckoutState copyWith({
    bool? isLoading,
    bool? isRemovingItem,
    bool? isPaying,
    String? errorText,
    List<CartItem>? items,
    DeliveryOption? deliveryOption,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isRemovingItem: isRemovingItem ?? this.isRemovingItem,
      isPaying: isPaying ?? this.isPaying,
      errorText: errorText,
      items: items ?? this.items,
      deliveryOption: deliveryOption ?? this.deliveryOption,
    );
  }
}

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required CartRepository cartRepository})
    : _cartRepository = cartRepository,
      super(CheckoutState.initial());

  final CartRepository _cartRepository;

  Future<void> load() async {
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

  Future<String?> removeItem(CartItem item) async {
    if (state.isRemovingItem) return null;
    emit(state.copyWith(isRemovingItem: true));
    try {
      await _cartRepository.removeCartItem(cartItemId: item.id);
      emit(
        state.copyWith(
          items: state.items.where((x) => x.id != item.id).toList(),
        ),
      );
      return null;
    } catch (e) {
      return 'Nie udało się usunąć produktu: $e';
    } finally {
      emit(state.copyWith(isRemovingItem: false));
    }
  }

  Future<String?> pay() async {
    if (state.isPaying || state.items.isEmpty) return null;
    emit(state.copyWith(isPaying: true));
    try {
      final result = await _cartRepository.placeOrderFromCurrentCart(
        status: 'placed',
      );
      emit(state.copyWith(items: <CartItem>[]));
      return 'Płatność zakończona. Utworzono zamówienie ${result.orderNumber}.';
    } catch (e) {
      return 'Nie udało się opłacić zamówienia: $e';
    } finally {
      emit(state.copyWith(isPaying: false));
    }
  }

  void setDeliveryOption(DeliveryOption option) {
    emit(state.copyWith(deliveryOption: option));
  }
}
