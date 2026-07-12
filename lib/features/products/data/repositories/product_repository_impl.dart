import 'package:fpdart/fpdart.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  const ProductRepositoryImpl(this._remoteDataSource);

  @override
  Stream<Either<String, List<Product>>> watchProducts() async* {
    try {
      await for (final models in _remoteDataSource.watchProducts()) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      yield Left('Không tải được danh sách sản phẩm: $e');
    }
  }
}
