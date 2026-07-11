import 'package:fpdart/fpdart.dart';
import '../../domain/entities/toy.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/toy_repository.dart';
import '../datasources/toy_remote_datasource.dart';

class ToyRepositoryImpl implements ToyRepository {
  final ToyRemoteDataSource _remoteDataSource;

  const ToyRepositoryImpl(this._remoteDataSource);

  @override
  Stream<Either<String, List<Toy>>> watchToys() async* {
    try {
      await for (final models in _remoteDataSource.watchToys()) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      // Lỗi Firestore (mất mạng, quyền bị từ chối...) -> Left thông điệp.
      yield Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Toy>> getToyById(String id) async {
    try {
      final model = await _remoteDataSource.fetchToyById(id);
      if (model == null) {
        return const Left('Không tìm thấy sản phẩm.');
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Stream<Either<String, List<Brand>>> watchBrands() async* {
    try {
      await for (final models in _remoteDataSource.watchBrands()) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      yield Left('Không tải được danh sách thương hiệu: $e');
    }
  }

  String _mapError(Object e) => 'Không tải được dữ liệu sản phẩm: $e';
}

