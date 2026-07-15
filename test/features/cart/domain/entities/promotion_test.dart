import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/cart/domain/entities/promotion.dart';

void main() {
  test('Promotion.isExpired returns correct status', () {
    final notExpired = Promotion(
      id: '1',
      code: 'TEST1',
      description: 'Desc',
      discountPercent: 10,
      minOrderValue: 100,
      isActive: true,
      endDate: DateTime.now().add(const Duration(hours: 1)),
    );
    final expired = Promotion(
      id: '2',
      code: 'TEST2',
      description: 'Desc',
      discountPercent: 10,
      minOrderValue: 100,
      isActive: true,
      endDate: DateTime.now().subtract(const Duration(hours: 1)),
    );
    final infinite = Promotion(
      id: '3',
      code: 'TEST3',
      description: 'Desc',
      discountPercent: 10,
      minOrderValue: 100,
      isActive: true,
      endDate: null,
    );

    expect(notExpired.isExpired, isFalse);
    expect(expired.isExpired, isTrue);
    expect(infinite.isExpired, isFalse);
  });
}
