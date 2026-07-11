import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/toy.dart';

part 'toy_list_state.freezed.dart';

@freezed
class ToyListState with _$ToyListState {
  const factory ToyListState.initial() = _Initial;
  const factory ToyListState.loading() = _Loading;
  const factory ToyListState.success(List<Toy> toys) = _Success;
  const factory ToyListState.error(String message) = _Error;
}
