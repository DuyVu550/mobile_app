import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:toy_app/features/toy_list/domain/entities/brand.dart';
import 'package:toy_app/features/toy_list/domain/repositories/toy_repository.dart';
import 'package:toy_app/features/toy_list/domain/usecases/watch_brands_usecase.dart';
import 'package:toy_app/features/toy_list/domain/entities/toy.dart';

class FakeToyRepository implements ToyRepository {
  @override
  Stream<Either<String, List<Brand>>> watchBrands() async* {
    yield const Right([
      Brand(id: 'b1', name: 'Lego', imageUrl: 'lego.png'),
    ]);
  }

  @override
  Stream<Either<String, List<Toy>>> watchToys() => const Stream.empty();

  @override
  Future<Either<String, Toy>> getToyById(String id) async => Left('Not implemented');
}

void main() {
  test('WatchBrandsUseCase should execute and return list of brands', () async {
    final repository = FakeToyRepository();
    final useCase = WatchBrandsUseCase(repository);

    final result = await useCase.execute().first;
    expect(result.isRight(), isTrue);
    result.match(
      (l) => fail('Should be right'),
      (r) {
        expect(r.length, 1);
        expect(r.first.name, 'Lego');
      },
    );
  });
}
