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
  }) = _ToyModel;

  const ToyModel._();

  factory ToyModel.fromJson(Map<String, dynamic> json) =>
      _$ToyModelFromJson(json);

  factory ToyModel.fromEntity(Toy entity) {
    return ToyModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      imageUrl: entity.imageUrl,
    );
  }

  Toy toEntity() {
    return Toy(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
    );
  }
}
