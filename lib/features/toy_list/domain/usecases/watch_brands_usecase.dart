import 'package:fpdart/fpdart.dart';
import '../entities/brand.dart';
import '../repositories/toy_repository.dart';

class WatchBrandsUseCase {
  final ToyRepository _repository;

  WatchBrandsUseCase(this._repository);

  Stream<Either<String, List<Brand>>> execute() {
    return _repository.watchBrands();
  }
}
