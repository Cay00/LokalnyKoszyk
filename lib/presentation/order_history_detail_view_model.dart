import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokalny_koszyk/core/di/providers.dart';
import 'package:lokalny_koszyk/domain/models/order_details.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';

final orderHistoryDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<OrderHistoryDetailViewModel, OrderHistoryDetailState, String>((
      ref,
      orderId,
    ) {
      return OrderHistoryDetailViewModel(
        ordersRepository: ref.read(ordersRepositoryProvider),
        orderId: orderId,
      )..load();
    });

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

class OrderHistoryDetailViewModel
    extends StateNotifier<OrderHistoryDetailState> {
  OrderHistoryDetailViewModel({
    required OrdersRepository ordersRepository,
    required String orderId,
  }) : _ordersRepository = ordersRepository,
       _orderId = orderId,
       super(OrderHistoryDetailState.initial());

  final OrdersRepository _ordersRepository;
  final String _orderId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorText: null);
    try {
      final order = await _ordersRepository.getOrderDetails(_orderId);
      state = state.copyWith(order: order, isLoading: false, errorText: null);
    } catch (e) {
      state = state.copyWith(
        errorText: 'Nie udało się pobrać szczegółów zamówienia: $e',
        isLoading: false,
      );
    }
  }
}
