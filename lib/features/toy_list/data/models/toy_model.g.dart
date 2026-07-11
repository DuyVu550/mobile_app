// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ToyModelImpl _$$ToyModelImplFromJson(Map<String, dynamic> json) =>
    _$ToyModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      brand: json['brand'] as String? ?? '',
      ageGroup: json['ageGroup'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      color: json['color'] as String? ?? '',
    );

Map<String, dynamic> _$$ToyModelImplToJson(_$ToyModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'brand': instance.brand,
      'ageGroup': instance.ageGroup,
      'gender': instance.gender,
      'color': instance.color,
    };
