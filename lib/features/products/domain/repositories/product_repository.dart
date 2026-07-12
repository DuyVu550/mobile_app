import 'package:fpdart/fpdart.dart';
import '../entities/product.dart';

abstract interface class ProductRepository {
  Stream<Either<String, List<Product>>> watchProducts();
}
