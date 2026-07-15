import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/domain/repositories/product_repository.dart';
import 'package:toy_app/features/products/domain/usecases/watch_products_usecase.dart';

class FakeProductRepository implements ProductRepository {
  @override
  Stream<Either<String, List<Product>>> watchProducts() async* {
    yield const Right([
      Product(
        id: 'p1',
        name: 'Điện thoại iPhone 15',
        description: 'iPhone 15 Pro Max',
        price: 25000000.0,
        imageUrl: 'iphone15.png',
        category: 'Điện thoại',
        isFeatured: false,
        rating: 4.8,
        hasPromotion: true,
        stock: 10,
      ),
    ]);
  }
}

void main() {
  test('WatchProductsUseCase should execute and return list of products',
      () async {
    final repository = FakeProductRepository();
    final useCase = WatchProductsUseCase(repository);

    final result = await useCase.execute().first;
    expect(result.isRight(), isTrue);
    result.match(
      (l) => fail('Should be right'),
      (r) {
        expect(r.length, 1);
        expect(r.first.name, 'Điện thoại iPhone 15');
      },
    );
  });
}
