import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/producer_profile.dart';
import 'package:lokalny_koszyk/domain/repositories/producer_details_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_sellers_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

sealed class ProducerDetailsEvent {
  const ProducerDetailsEvent();
}

final class ProducerDetailsLoadRequested extends ProducerDetailsEvent {
  const ProducerDetailsLoadRequested();
}

final class ProducerDetailsToggleLikeRequested extends ProducerDetailsEvent {
  const ProducerDetailsToggleLikeRequested();
}

class ProducerDetailsState {
  const ProducerDetailsState({
    required this.isLiked,
    required this.isTogglingLike,
    required this.isLoading,
    required this.distanceLabel,
    required this.products,
    this.errorText,
    this.seller,
    this.feedbackMessage,
  });

  factory ProducerDetailsState.initial() => const ProducerDetailsState(
    isLiked: false,
    isTogglingLike: false,
    isLoading: true,
    distanceLabel: 'brak danych',
    products: <ProductUiModel>[],
  );

  final bool isLiked;
  final bool isTogglingLike;
  final bool isLoading;
  final String? errorText;
  final String distanceLabel;
  final ProducerProfile? seller;
  final List<ProductUiModel> products;
  final String? feedbackMessage;

  ProducerDetailsState copyWith({
    bool? isLiked,
    bool? isTogglingLike,
    bool? isLoading,
    String? errorText,
    String? distanceLabel,
    ProducerProfile? seller,
    List<ProductUiModel>? products,
    Object? feedbackMessage = _unset,
  }) {
    return ProducerDetailsState(
      isLiked: isLiked ?? this.isLiked,
      isTogglingLike: isTogglingLike ?? this.isTogglingLike,
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText,
      distanceLabel: distanceLabel ?? this.distanceLabel,
      seller: seller ?? this.seller,
      products: products ?? this.products,
      feedbackMessage: identical(feedbackMessage, _unset)
          ? this.feedbackMessage
          : feedbackMessage as String?,
    );
  }
}

const _unset = Object();

class ProducerDetailsBloc
    extends Bloc<ProducerDetailsEvent, ProducerDetailsState> {
  ProducerDetailsBloc({
    required ProducerDetailsRepository repository,
    required WatchedSellersRepository watchedSellersRepository,
    required String? sellerId,
  }) : _repository = repository,
       _watchedSellersRepository = watchedSellersRepository,
       _sellerId = sellerId,
       super(ProducerDetailsState.initial()) {
    on<ProducerDetailsLoadRequested>(_onLoad);
    on<ProducerDetailsToggleLikeRequested>(_onToggleLike);
  }

  final ProducerDetailsRepository _repository;
  final WatchedSellersRepository _watchedSellersRepository;
  final String? _sellerId;

  Future<void> _onLoad(
    ProducerDetailsLoadRequested event,
    Emitter<ProducerDetailsState> emit,
  ) async {
    final sellerId = _sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          errorText: 'Brak identyfikatora sprzedawcy.',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      final data = await _repository.getSellerAndProducts(sellerId);
      var isLiked = false;
      try {
        isLiked = await _watchedSellersRepository.isFavoriteForCurrentUser(
          sellerId,
        );
      } catch (_) {
        isLiked = false;
      }
      emit(
        state.copyWith(
          seller: data.profile,
          products: data.products.map(ProductUiModel.fromDomain).toList(),
          isLiked: isLiked,
          isLoading: false,
          errorText: null,
        ),
      );
      final distanceLabel = await _repository.buildDistanceLabel(data.profile);
      emit(state.copyWith(distanceLabel: distanceLabel));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorText: 'Nie udało się pobrać danych sprzedawcy: $e',
        ),
      );
    }
  }

  Future<void> _onToggleLike(
    ProducerDetailsToggleLikeRequested event,
    Emitter<ProducerDetailsState> emit,
  ) async {
    final sellerId = _sellerId;
    if (sellerId == null || sellerId.isEmpty || state.isTogglingLike) return;

    if (!_watchedSellersRepository.isUserSignedIn) {
      emit(
        state.copyWith(
          feedbackMessage: 'Zaloguj się, aby dodać sprzedawcę do ulubionych.',
        ),
      );
      return;
    }

    final currentlyLiked = state.isLiked;
    emit(
      state.copyWith(
        isTogglingLike: true,
        isLiked: !currentlyLiked,
        feedbackMessage: null,
      ),
    );
    try {
      if (currentlyLiked) {
        await _watchedSellersRepository.removeFavoriteForCurrentUser(sellerId);
      } else {
        await _watchedSellersRepository.addFavoriteForCurrentUser(sellerId);
      }
      emit(
        state.copyWith(
          isTogglingLike: false,
          feedbackMessage: currentlyLiked
              ? 'Usunięto sprzedawcę z ulubionych'
              : 'Dodano sprzedawcę do ulubionych',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isTogglingLike: false,
          isLiked: currentlyLiked,
          feedbackMessage: 'Nie udało się zaktualizować ulubionych: $e',
        ),
      );
    }
  }
}
