import 'package:fpdart/fpdart.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class WatchProductsUseCase {
  final ProductRepository _repository;

  WatchProductsUseCase(this._repository);

  Stream<Either<String, List<Product>>> execute() {
    return _repository.watchProducts();
  }
}
