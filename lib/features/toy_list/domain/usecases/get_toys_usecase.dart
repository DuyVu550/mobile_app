import 'package:fpdart/fpdart.dart';
import '../entities/toy.dart';
import '../repositories/toy_repository.dart';

class GetToysUseCase {
  final ToyRepository _repository;

  const GetToysUseCase(this._repository);

  Future<Either<String, List<Toy>>> execute() async {
    return await _repository.getToys();
  }
}
