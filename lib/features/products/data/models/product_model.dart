import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel implements Product {
  const factory ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
    required bool isFeatured,
    required double rating,
    required bool hasPromotion,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      price: ((data['price'] ?? 0) as num).toDouble(),
      imageUrl: (data['imageUrl'] ?? '') as String,
      category: (data['category'] ?? '') as String,
      isFeatured: (data['isFeatured'] ?? false) as bool,
      rating: ((data['rating'] ?? 0.0) as num).toDouble(),
      hasPromotion: (data['hasPromotion'] ?? false) as bool,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      isFeatured: isFeatured,
      rating: rating,
      hasPromotion: hasPromotion,
    );
  }
}
