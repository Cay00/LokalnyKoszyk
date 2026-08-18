import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/order_summary.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';

sealed class MyOrdersEvent {
  const MyOrdersEvent();
}

final class MyOrdersLoadRequested extends MyOrdersEvent {
  const MyOrdersLoadRequested();
}

class MyOrdersState {
  const MyOrdersState({
    required this.isLoading,
    this.errorText,
    this.orders = const <OrderSummary>[],
  });

  factory MyOrdersState.initial() => const MyOrdersState(isLoading: true);

  final bool isLoading;
  final String? errorText;
  final List<OrderSummary> orders;

  MyOrdersState copyWith({
    bool? isLoading,
    String? errorText,
    List<OrderSummary>? orders,
  }) {
    return MyOrdersState(
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText,
      orders: orders ?? this.orders,
    );
  }
}

class MyOrdersBloc extends Bloc<MyOrdersEvent, MyOrdersState> {
  MyOrdersBloc({required OrdersRepository ordersRepository})
    : _ordersRepository = ordersRepository,
      super(MyOrdersState.initial()) {
    on<MyOrdersLoadRequested>(_onLoad);
  }

  final OrdersRepository _ordersRepository;

  Future<void> _onLoad(
    MyOrdersLoadRequested event,
    Emitter<MyOrdersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      final orders = await _ordersRepository.getOrdersForCurrentUser();
      emit(
        state.copyWith(orders: orders, isLoading: false, errorText: null),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorText: 'Nie udało się pobrać historii zamówień: $e',
          isLoading: false,
        ),
      );
    }
  }
}
