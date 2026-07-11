import 'package:fpdart/fpdart.dart';
import '../entities/toy.dart';

abstract interface class ToyRepository {
  Future<Either<String, List<Toy>>> getToys();
}
