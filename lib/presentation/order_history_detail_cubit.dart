import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/order_details.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';

class OrderHistoryDetailState {
  const OrderHistoryDetailState({
    required this.isLoading,
    this.errorText,
    this.order,
  });

  factory OrderHistoryDetailState.initial() =>
      const OrderHistoryDetailState(isLoading: true);

  final bool isLoading;
  final String? errorText;
  final OrderDetails? order;

  OrderHistoryDetailState copyWith({
    bool? isLoading,
    String? errorText,
    OrderDetails? order,
  }) {
    return OrderHistoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText,
      order: order ?? this.order,
    );
  }
}

class OrderHistoryDetailCubit extends Cubit<OrderHistoryDetailState> {
  OrderHistoryDetailCubit({
    required OrdersRepository ordersRepository,
    required String orderId,
  }) : _ordersRepository = ordersRepository,
       _orderId = orderId,
       super(OrderHistoryDetailState.initial());

  final OrdersRepository _ordersRepository;
  final String _orderId;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      final order = await _ordersRepository.getOrderDetails(_orderId);
      emit(state.copyWith(order: order, isLoading: false, errorText: null));
    } catch (e) {
      emit(
        state.copyWith(
          errorText: 'Nie udało się pobrać szczegółów zamówienia: $e',
          isLoading: false,
        ),
      );
    }
  }
}
