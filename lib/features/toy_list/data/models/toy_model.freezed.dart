// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'toy_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ToyModel _$ToyModelFromJson(Map<String, dynamic> json) {
  return _ToyModel.fromJson(json);
}

/// @nodoc
mixin _$ToyModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this ToyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToyModelCopyWith<ToyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToyModelCopyWith<$Res> {
  factory $ToyModelCopyWith(ToyModel value, $Res Function(ToyModel) then) =
      _$ToyModelCopyWithImpl<$Res, ToyModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    double price,
    String imageUrl,
  });
}

/// @nodoc
class _$ToyModelCopyWithImpl<$Res, $Val extends ToyModel>
    implements $ToyModelCopyWith<$Res> {
  _$ToyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? imageUrl = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ToyModelImplCopyWith<$Res>
    implements $ToyModelCopyWith<$Res> {
  factory _$$ToyModelImplCopyWith(
    _$ToyModelImpl value,
    $Res Function(_$ToyModelImpl) then,
  ) = __$$ToyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    double price,
    String imageUrl,
  });
}

/// @nodoc
class __$$ToyModelImplCopyWithImpl<$Res>
    extends _$ToyModelCopyWithImpl<$Res, _$ToyModelImpl>
    implements _$$ToyModelImplCopyWith<$Res> {
  __$$ToyModelImplCopyWithImpl(
    _$ToyModelImpl _value,
    $Res Function(_$ToyModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? imageUrl = null,
  }) {
    return _then(
      _$ToyModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ToyModelImpl extends _ToyModel {
  const _$ToyModelImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  }) : super._();

  factory _$ToyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToyModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
  @override
  final String imageUrl;

  @override
  String toString() {
    return 'ToyModel(id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, price, imageUrl);

  /// Create a copy of ToyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToyModelImplCopyWith<_$ToyModelImpl> get copyWith =>
      __$$ToyModelImplCopyWithImpl<_$ToyModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToyModelImplToJson(this);
  }
}

abstract class _ToyModel extends ToyModel {
  const factory _ToyModel({
    required final String id,
    required final String name,
    required final String description,
    required final double price,
    required final String imageUrl,
  }) = _$ToyModelImpl;
  const _ToyModel._() : super._();

  factory _ToyModel.fromJson(Map<String, dynamic> json) =
      _$ToyModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  double get price;
  @override
  String get imageUrl;

  /// Create a copy of ToyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToyModelImplCopyWith<_$ToyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
