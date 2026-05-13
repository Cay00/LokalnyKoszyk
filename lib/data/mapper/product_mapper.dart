import 'package:lokalny_koszyk/data/dto/product_dto.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';

Product mapProductDtoToDomain(ProductDto dto) => dto.toDomain();
