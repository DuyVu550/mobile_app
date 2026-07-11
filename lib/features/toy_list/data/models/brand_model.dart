import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/brand.dart';

part 'brand_model.freezed.dart';
part 'brand_model.g.dart';

@freezed
class BrandModel with _$BrandModel implements Brand {
  const factory BrandModel({
    required String id,
    required String name,
    required String imageUrl,
  }) = _BrandModel;

  const BrandModel._();

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);

  factory BrandModel.fromFirestore(String id, Map<String, dynamic> data) {
    return BrandModel(
      id: id,
      name: (data['name'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
    );
  }

  Brand toEntity() {
    return Brand(
      id: id,
      name: name,
      imageUrl: imageUrl,
    );
  }
}
