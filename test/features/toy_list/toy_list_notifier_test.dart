import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/toy_list/presentation/controllers/toy_list_notifier.dart';
import 'package:toy_app/features/toy_list/presentation/controllers/toy_list_state.dart';

Future<FakeFirebaseFirestore> seed() async {
  final firestore = FakeFirebaseFirestore();
  final toys = firestore.collection('toys');
  await toys.doc('t1').set({
    'name': 'Teddy Bear',
    'description': 'd', 'price': 10, 'imageUrl': 'a',
    'brand': 'Fisher-Price', 'ageGroup': '3-5', 'gender': 'unisex', 'color': 'brown',
  });
  await toys.doc('t2').set({
    'name': 'Lego Police',
    'description': 'd', 'price': 20, 'imageUrl': 'b',
    'brand': 'Lego', 'ageGroup': '6-8', 'gender': 'unisex', 'color': 'blue',
  });
  await toys.doc('t3').set({
    'name': 'RC Car',
    'description': 'd', 'price': 30, 'imageUrl': 'c',
    'brand': 'Hot Wheels', 'ageGroup': '6-8', 'gender': 'boy', 'color': 'red',
  });

  final brands = firestore.collection('brands');
  await brands.doc('b1').set({'name': 'Fisher-Price', 'imageUrl': 'a'});
  await brands.doc('b2').set({'name': 'Lego', 'imageUrl': 'b'});
  await brands.doc('b3').set({'name': 'Hot Wheels', 'imageUrl': 'c'});

  return firestore;
}

void main() {
  late ProviderContainer container;

  Future<void> boot(FakeFirebaseFirestore firestore) async {
    container = ProviderContainer(
      overrides: [firestoreProvider.overrideWithValue(firestore)],
    );
    container.listen(toyListNotifierProvider, (_, _) {});
    container.listen(selectedBrandSectionProvider, (_, _) {});
    container.listen(selectedAgeSectionProvider, (_, _) {});
    container.listen(selectedGenderSectionProvider, (_, _) {});
    // Chờ stream phát dữ liệu đầu tiên.
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  tearDown(() => container.dispose());

  ToyListNotifier notifier() =>
      container.read(toyListNotifierProvider.notifier);
  ToyListState state() => container.read(toyListNotifierProvider);

  List<String> names(ToyListState s) => s.maybeWhen(
        success: (toys) => toys.map((t) => t.name).toList(),
        orElse: () => <String>[],
      );

  test('load realtime -> success với đủ 3 sản phẩm', () async {
    await boot(await seed());
    expect(state(), isA<ToyListState>());
    expect(names(state()).length, 3);
  });

  test('search theo tên', () async {
    await boot(await seed());
    notifier().search('lego');
    expect(names(state()), ['Lego Police']);
  });

  test('lọc theo brand', () async {
    await boot(await seed());
    notifier().filterByBrand('Hot Wheels');
    expect(names(state()), ['RC Car']);
  });

  test('lọc theo độ tuổi', () async {
    await boot(await seed());
    notifier().filterByAgeGroup('6-8');
    expect(names(state()).toSet(), {'Lego Police', 'RC Car'});
  });

  test('lọc theo giới tính', () async {
    await boot(await seed());
    notifier().filterByGender('boy');
    expect(names(state()), ['RC Car']);
  });

  test('kết hợp brand + tuổi', () async {
    await boot(await seed());
    notifier().filterByAgeGroup('6-8');
    notifier().filterByBrand('Lego');
    expect(names(state()), ['Lego Police']);
  });

  test('clearFilters khôi phục toàn bộ', () async {
    await boot(await seed());
    notifier().filterByGender('boy');
    expect(names(state()).length, 1);
    notifier().clearFilters();
    expect(names(state()).length, 3);
  });

  test('collection rỗng -> success danh sách rỗng', () async {
    await boot(FakeFirebaseFirestore());
    expect(names(state()), isEmpty);
  });

  test('selected sections initial state', () async {
    await boot(await seed());
    final brand = container.read(selectedBrandSectionProvider);
    final age = container.read(selectedAgeSectionProvider);
    final gender = container.read(selectedGenderSectionProvider);

    expect(brand, 'Fisher-Price');
    expect(age, '3-5');
    expect(gender, 'boy');
  });
}
