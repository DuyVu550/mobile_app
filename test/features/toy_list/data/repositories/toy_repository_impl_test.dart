import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/toy_list/data/repositories/toy_repository_impl.dart';
import 'package:toy_app/features/toy_list/data/datasources/toy_remote_datasource.dart';
import 'package:toy_app/features/toy_list/data/models/brand_model.dart';
import 'package:toy_app/features/toy_list/data/models/toy_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeToyRemoteDataSource implements ToyRemoteDataSource {
  @override
  Stream<List<BrandModel>> watchBrands() {
    return Stream.value([
      const BrandModel(id: 'b1', name: 'Lego', imageUrl: 'lego.png'),
    ]);
  }

  @override
  Stream<List<ToyModel>> watchToys() => const Stream.empty();

  @override
  Future<ToyModel?> fetchToyById(String id) async => null;

  @override
  FirebaseFirestore get _firestore => throw UnimplementedError();
}

void main() {
  test('ToyRepositoryImpl.watchBrands maps BrandModel to Brand entity', () async {
    final dataSource = FakeToyRemoteDataSource();
    final repository = ToyRepositoryImpl(dataSource);

    final result = await repository.watchBrands().first;
    expect(result.isRight(), isTrue);
    result.match(
      (l) => fail('Should be right'),
      (r) {
        expect(r.length, 1);
        expect(r.first.id, 'b1');
        expect(r.first.name, 'Lego');
        expect(r.first.imageUrl, 'lego.png');
      },
    );
  });
}
