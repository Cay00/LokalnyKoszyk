import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/producer_profile.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';
import 'package:lokalny_koszyk/domain/repositories/producer_details_repository.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

class ProducerDetailsState {
  const ProducerDetailsState({
    required this.isLiked,
    required this.isLoading,
    required this.distanceLabel,
    required this.products,
    this.errorText,
    this.seller,
  });

  factory ProducerDetailsState.initial() => const ProducerDetailsState(
    isLiked: false,
    isLoading: true,
    distanceLabel: 'brak danych',
    products: <ProductUiModel>[],
  );

  final bool isLiked;
  final bool isLoading;
  final String? errorText;
  final String distanceLabel;
  final ProducerProfile? seller;
  final List<ProductUiModel> products;

  ProducerDetailsState copyWith({
    bool? isLiked,
    bool? isLoading,
    String? errorText,
    String? distanceLabel,
    ProducerProfile? seller,
    List<ProductUiModel>? products,
  }) {
    return ProducerDetailsState(
      isLiked: isLiked ?? this.isLiked,
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText,
      distanceLabel: distanceLabel ?? this.distanceLabel,
      seller: seller ?? this.seller,
      products: products ?? this.products,
    );
  }
}

class ProducerDetailsCubit extends Cubit<ProducerDetailsState> {
  ProducerDetailsCubit({
    required ProducerDetailsRepository repository,
    required String? sellerId,
  }) : _repository = repository,
       _sellerId = sellerId,
       super(ProducerDetailsState.initial());

  final ProducerDetailsRepository _repository;
  final String? _sellerId;

  Future<void> load() async {
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
      emit(
        state.copyWith(
          seller: data.profile,
          products: data.products.map(_toProductData).toList(),
          isLoading: false,
          errorText: null,
        ),
      );
      _loadDistanceLabelInBackground(data.profile);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorText: 'Nie udało się pobrać danych sprzedawcy: $e',
        ),
      );
    }
  }

  Future<void> _loadDistanceLabelInBackground(ProducerProfile seller) async {
    final distanceLabel = await _repository.buildDistanceLabel(seller);
    emit(state.copyWith(distanceLabel: distanceLabel));
  }

  void toggleLike() {
    emit(state.copyWith(isLiked: !state.isLiked));
  }

  ProductUiModel _toProductData(Product product) {
    return ProductUiModel(
      id: product.id,
      name: product.name,
      producer: product.producer,
      price: product.price,
      unit: product.unit,
      distance: product.distance,
      season: product.season,
      rating: product.rating,
      reviews: product.reviews,
      emoji: '🧺',
      tag: 'LOKALNE',
      bgColor: AppColors.background,
      tagColor: AppColors.primaryLight,
      sellerId: product.sellerId,
      unitKey: product.unitKey,
      packageQuantity: product.packageQuantity,
      categoryId: product.categoryId,
    );
  }
}
