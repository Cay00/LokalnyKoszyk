import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/payment_method.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';

enum DeliveryOption {
  courier('Kurier'),
  pickupPoint('Paczkomat / punkt odbioru'),
  personalPickup('Odbiór osobisty');

  const DeliveryOption(this.label);
  final String label;
}

enum CheckoutAddressChoice {
  current,
  newAddress,
}

sealed class CheckoutEvent {
  const CheckoutEvent();
}

final class CheckoutLoadRequested extends CheckoutEvent {
  const CheckoutLoadRequested({this.selectedCartItemIds});

  /// Jeśli podane — pokaż tylko wybrane pozycje koszyka.
  final List<String>? selectedCartItemIds;
}

final class CheckoutPayRequested extends CheckoutEvent {
  const CheckoutPayRequested();
}

final class CheckoutDeliveryOptionChanged extends CheckoutEvent {
  const CheckoutDeliveryOptionChanged(this.option);

  final DeliveryOption option;
}

final class CheckoutPaymentMethodChanged extends CheckoutEvent {
  const CheckoutPaymentMethodChanged(this.method);

  final AppPaymentMethod method;
}

final class CheckoutAddressChoiceChanged extends CheckoutEvent {
  const CheckoutAddressChoiceChanged(this.choice);

  final CheckoutAddressChoice choice;
}

final class CheckoutNewAddressChanged extends CheckoutEvent {
  const CheckoutNewAddressChanged(this.address);

  final String address;
}

final class CheckoutDefaultAddressLoaded extends CheckoutEvent {
  const CheckoutDefaultAddressLoaded(this.address);

  final String address;
}

class CheckoutState {
  const CheckoutState({
    required this.isLoading,
    required this.isPaying,
    required this.items,
    required this.deliveryOption,
    required this.paymentMethod,
    required this.addressChoice,
    required this.defaultAddress,
    required this.newAddress,
    this.errorText,
    this.feedbackMessage,
  });

  factory CheckoutState.initial() => const CheckoutState(
    isLoading: true,
    isPaying: false,
    items: <CartItem>[],
    deliveryOption: DeliveryOption.courier,
    paymentMethod: AppPaymentMethod.blik,
    addressChoice: CheckoutAddressChoice.current,
    defaultAddress: '',
    newAddress: '',
  );

  final bool isLoading;
  final bool isPaying;
  final String? errorText;
  final List<CartItem> items;
  final DeliveryOption deliveryOption;
  final AppPaymentMethod paymentMethod;
  final CheckoutAddressChoice addressChoice;
  final String defaultAddress;
  final String newAddress;
  final String? feedbackMessage;

  double get productsTotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  String get selectedDeliveryAddress {
    if (addressChoice == CheckoutAddressChoice.current) {
      return defaultAddress.trim();
    }
    return newAddress.trim();
  }

  bool get canConfirmAddress {
    if (deliveryOption == DeliveryOption.personalPickup) return true;
    return selectedDeliveryAddress.isNotEmpty;
  }

  CheckoutState copyWith({
    bool? isLoading,
    bool? isPaying,
    String? errorText,
    List<CartItem>? items,
    DeliveryOption? deliveryOption,
    AppPaymentMethod? paymentMethod,
    CheckoutAddressChoice? addressChoice,
    String? defaultAddress,
    String? newAddress,
    Object? feedbackMessage = _unset,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isPaying: isPaying ?? this.isPaying,
      errorText: errorText,
      items: items ?? this.items,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      addressChoice: addressChoice ?? this.addressChoice,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      newAddress: newAddress ?? this.newAddress,
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
    on<CheckoutPayRequested>(_onPay);
    on<CheckoutDeliveryOptionChanged>(_onDeliveryOptionChanged);
    on<CheckoutPaymentMethodChanged>(_onPaymentMethodChanged);
    on<CheckoutAddressChoiceChanged>(_onAddressChoiceChanged);
    on<CheckoutNewAddressChanged>(_onNewAddressChanged);
    on<CheckoutDefaultAddressLoaded>(_onDefaultAddressLoaded);
  }

  final CartRepository _cartRepository;

  Future<void> _onLoad(
    CheckoutLoadRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      var items = await _cartRepository.getCartItemsForCurrentUser();
      final ids = event.selectedCartItemIds;
      if (ids != null && ids.isNotEmpty) {
        final allowed = ids.toSet();
        items = items.where((CartItem i) => allowed.contains(i.id)).toList();
      }
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
              'Zamówienie ${result.orderNumber} złożone '
              '(${state.paymentMethod.label}).',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPaying: false,
          feedbackMessage: 'Nie udało się złożyć zamówienia: $e',
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

  void _onPaymentMethodChanged(
    CheckoutPaymentMethodChanged event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.method));
  }

  void _onAddressChoiceChanged(
    CheckoutAddressChoiceChanged event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(addressChoice: event.choice));
  }

  void _onNewAddressChanged(
    CheckoutNewAddressChanged event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(newAddress: event.address));
  }

  void _onDefaultAddressLoaded(
    CheckoutDefaultAddressLoaded event,
    Emitter<CheckoutState> emit,
  ) {
    final address = event.address.trim();
    emit(
      state.copyWith(
        defaultAddress: address,
        addressChoice: address.isEmpty
            ? CheckoutAddressChoice.newAddress
            : CheckoutAddressChoice.current,
      ),
    );
  }
}
