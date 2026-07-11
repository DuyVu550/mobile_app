import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/toy.dart';

part 'toy_model.freezed.dart';
part 'toy_model.g.dart';

@freezed
class ToyModel with _$ToyModel implements Toy {
  const factory ToyModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    @Default('') String brand,
    @Default('') String ageGroup,
    @Default('') String gender,
    @Default('') String color,
  }) = _ToyModel;

  const ToyModel._();

  factory ToyModel.fromJson(Map<String, dynamic> json) =>
      _$ToyModelFromJson(json);

  /// Tạo model từ document Firestore (id lấy từ docId, không nằm trong data).
  factory ToyModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ToyModel(
      id: id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      // Firestore trả number dạng int hoặc double -> ép an toàn.
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: (data['imageUrl'] ?? '') as String,
      brand: (data['brand'] ?? '') as String,
      ageGroup: (data['ageGroup'] ?? '') as String,
      gender: (data['gender'] ?? '') as String,
      color: (data['color'] ?? '') as String,
    );
  }

  factory ToyModel.fromEntity(Toy entity) {
    return ToyModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      imageUrl: entity.imageUrl,
      brand: entity.brand,
      ageGroup: entity.ageGroup,
      gender: entity.gender,
      color: entity.color,
    );
  }

  Toy toEntity() {
    return Toy(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      brand: brand,
      ageGroup: ageGroup,
      gender: gender,
      color: color,
    );
  }
}
