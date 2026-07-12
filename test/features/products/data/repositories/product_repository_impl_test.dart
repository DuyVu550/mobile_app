import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:toy_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:toy_app/features/products/data/models/product_model.dart';

class FakeProductRemoteDataSource implements ProductRemoteDataSource {
  @override
  Stream<List<ProductModel>> watchProducts() {
    return Stream.value([
      const ProductModel(
        id: 'p1',
        name: 'Điện thoại iPhone 15',
        description: 'iPhone 15 Pro Max',
        price: 25000000.0,
        imageUrl: 'iphone15.png',
        category: 'Điện thoại',
        isFeatured: false,
        rating: 4.8,
        hasPromotion: true,
      ),
    ]);
  }
}

void main() {
  test('ProductRepositoryImpl.watchProducts maps ProductModel to Product entity',
      () async {
    final dataSource = FakeProductRemoteDataSource();
    final repository = ProductRepositoryImpl(dataSource);

    final result = await repository.watchProducts().first;
    expect(result.isRight(), isTrue);
    result.match(
      (l) => fail('Should be right'),
      (r) {
        expect(r.length, 1);
        expect(r.first.id, 'p1');
        expect(r.first.name, 'Điện thoại iPhone 15');
      },
    );
  });
}
