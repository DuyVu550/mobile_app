import 'package:fpdart/fpdart.dart';
import '../../domain/entities/toy.dart';
import '../../domain/repositories/toy_repository.dart';
import '../datasources/toy_remote_datasource.dart';

class ToyRepositoryImpl implements ToyRepository {
  final ToyRemoteDataSource _remoteDataSource;

  const ToyRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, List<Toy>>> getToys() async {
    try {
      final models = await _remoteDataSource.fetchToys();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
