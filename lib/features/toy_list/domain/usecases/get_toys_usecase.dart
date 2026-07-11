import 'package:fpdart/fpdart.dart';
import '../entities/toy.dart';
import '../repositories/toy_repository.dart';

/// Stream danh sách sản phẩm realtime.
class WatchToysUseCase {
  final ToyRepository _repository;

  const WatchToysUseCase(this._repository);

  Stream<Either<String, List<Toy>>> execute() => _repository.watchToys();
}

/// Lấy chi tiết 1 sản phẩm theo id.
class GetToyByIdUseCase {
  final ToyRepository _repository;

  const GetToyByIdUseCase(this._repository);

  Future<Either<String, Toy>> execute(String id) =>
      _repository.getToyById(id);
}
