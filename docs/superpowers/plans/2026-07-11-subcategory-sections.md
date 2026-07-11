# Sub-category Sections Display Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Group and display toy products under horizontal scrollable sections (by Brand, Age Group, Gender) on the home screen when no active search/filters are applied, while keeping a standard list view during search/filtering.

**Architecture:** We will declare three StateProviders in the presentation controllers to track the selected items in each home screen section. A new reusable `ToyCard` widget will represent individual toys in horizontal scroll lists. We will refactor `ToyListScreen` to check for active filters and conditionally toggle between categorized home view and search results list view.

**Tech Stack:** Flutter, Riverpod, Dart, fpdart.

## Global Constraints
- None.

---

### Task 1: Add StateProviders for Category Selection Sections

**Files:**
- Modify: `lib/features/toy_list/presentation/controllers/toy_list_notifier.dart`

**Interfaces:**
- Produces:
  * `selectedBrandSectionProvider` (`StateProvider<String>`)
  * `selectedAgeSectionProvider` (`StateProvider<String>`)
  * `selectedGenderSectionProvider` (`StateProvider<String>`)

- [ ] **Step 1: Write the tests in a new test file or add to existing notifier tests**

Modify: `test/features/toy_list/presentation/toy_list_notifier_test.dart` to add a test case verifying the initialization of the new providers.

```dart
  test('selected sections initial state', () async {
    await boot(await seed());
    final brand = container.read(selectedBrandSectionProvider);
    final age = container.read(selectedAgeSectionProvider);
    final gender = container.read(selectedGenderSectionProvider);

    // Initial state should match the first item in the derived list or empty if not loaded yet.
    // In seeded database, we expect:
    // brand = 'Fisher-Price' (sorted alphabetically)
    // age = '3-5'
    // gender = 'boy'
    expect(brand, 'Fisher-Price');
    expect(age, '3-5');
    expect(gender, 'boy');
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/toy_list/presentation/toy_list_notifier_test.dart`
Expected: Compilation failure due to missing providers.

- [ ] **Step 3: Write minimal implementation**

Modify: `lib/features/toy_list/presentation/controllers/toy_list_notifier.dart` to append the new providers:

```dart
// StateProviders for tracking active selections in individual home sections.
final selectedBrandSectionProvider = StateProvider<String>((ref) {
  final brands = ref.watch(brandsListProvider);
  return brands.isNotEmpty ? brands.first.name : '';
});

final selectedAgeSectionProvider = StateProvider<String>((ref) {
  final ages = ref.watch(ageGroupOptionsProvider);
  return ages.isNotEmpty ? ages.first : '';
});

final selectedGenderSectionProvider = StateProvider<String>((ref) {
  final genders = ref.watch(genderOptionsProvider);
  return genders.isNotEmpty ? genders.first : '';
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/toy_list/presentation/toy_list_notifier_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/toy_list/presentation/controllers/toy_list_notifier.dart test/features/toy_list/presentation/toy_list_notifier_test.dart
git commit -m "feat: add category section state providers"
```

---

### Task 2: Create a Reusable Premium ToyCard Widget

**Files:**
- Create: `lib/features/toy_list/presentation/views/widgets/toy_card.dart`
- Create: `test/features/toy_list/presentation/views/widgets/toy_card_test.dart`

**Interfaces:**
- Produces:
  * `ToyCard` class constructor accepting `required Toy toy` and `required VoidCallback onTap`.

- [ ] **Step 1: Write a failing widget test for ToyCard**

Create: `test/features/toy_list/presentation/views/widgets/toy_card_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/toy_list/domain/entities/toy.dart';
import 'package:toy_app/features/toy_list/presentation/views/widgets/toy_card.dart';

void main() {
  const toy = Toy(
    id: '1',
    name: 'Sample Toy',
    description: 'A sample toy',
    price: 15.99,
    imageUrl: 'https://example.com/image.png',
    brand: 'Lego',
    ageGroup: '3-5',
    gender: 'boy',
  );

  testWidgets('renders ToyCard details and responds to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToyCard(
          toy: toy,
          onTap: () => tapped = true,
        ),
      ),
    ));

    expect(find.text('Sample Toy'), findsOneWidget);
    expect(find.text('\$15.99'), findsOneWidget);
    expect(find.text('Lego'), findsOneWidget);

    await tester.tap(find.byType(ToyCard));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/toy_list/presentation/views/widgets/toy_card_test.dart`
Expected: Compilation failure because `ToyCard` does not exist.

- [ ] **Step 3: Write minimal implementation**

Create: `lib/features/toy_list/presentation/views/widgets/toy_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../domain/entities/toy.dart';

class ToyCard extends StatelessWidget {
  final Toy toy;
  final VoidCallback onTap;

  const ToyCard({
    super.key,
    required this.toy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Image.network(
                  toy.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.amber.shade100,
                    child: const Center(
                      child: Icon(Icons.toys, size: 40, color: Colors.amber),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toy.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (toy.brand.isNotEmpty)
                    Text(
                      toy.brand,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text(
                        '\$${toy.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(Icons.add_shopping_cart, size: 16, color: Colors.amber),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/toy_list/presentation/views/widgets/toy_card_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/toy_list/presentation/views/widgets/toy_card.dart test/features/toy_list/presentation/views/widgets/toy_card_test.dart
git commit -m "feat: create reusable premium ToyCard widget"
```

---

### Task 3: Update ToyListScreen with Subcategory Horizontal Sections

**Files:**
- Modify: `lib/features/toy_list/presentation/views/toy_list_screen.dart`

**Interfaces:**
- Consumes:
  * `selectedBrandSectionProvider`
  * `selectedAgeSectionProvider`
  * `selectedGenderSectionProvider`
  * `ToyCard`

- [ ] **Step 1: Write a widget test verifying home sections are rendered when filters are empty**

Modify: `test/features/toy_list/presentation/views/widgets/toy_filter_bar_test.dart` or create a new `toy_list_screen_test.dart`. Let's look at `test/features/toy_list/toy_detail_screen_test.dart` and see if we can create `test/features/toy_list/presentation/views/toy_list_screen_test.dart`.

Create: `test/features/toy_list/presentation/views/toy_list_screen_test.dart`

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/toy_list/presentation/views/toy_list_screen.dart';

Future<FakeFirebaseFirestore> seedData() async {
  final firestore = FakeFirebaseFirestore();
  await firestore.collection('brands').doc('b1').set({
    'name': 'Lego',
    'imageUrl': 'logo_lego',
  });
  await firestore.collection('toys').doc('t1').set({
    'name': 'Lego Spaceship',
    'description': 'Description',
    'price': 29.99,
    'imageUrl': 'image_spaceship',
    'brand': 'Lego',
    'ageGroup': '3-5',
    'gender': 'unisex',
  });
  return firestore;
}

void main() {
  testWidgets('renders horizontal sections when filters are empty', (tester) async {
    final firestore = await seedData();
    await tester.pumpWidget(ProviderScope(
      overrides: [firestoreProvider.overrideWithValue(firestore)],
      child: const MaterialApp(
        home: ToyListScreen(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100)); // wait for streams

    // Check that section headers are present
    expect(find.text('Mua theo thương hiệu'), findsOneWidget);
    expect(find.text('Phân loại theo độ tuổi'), findsOneWidget);
    expect(find.text('Dành riêng cho bé'), findsOneWidget);
    expect(find.text('Gợi ý cho bạn'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/toy_list/presentation/views/toy_list_screen_test.dart`
Expected: FAIL (cannot find section headers because they are not yet implemented in `ToyListScreen`).

- [ ] **Step 3: Implement subcategory horizontal sections in ToyListScreen**

Modify: `lib/features/toy_list/presentation/views/toy_list_screen.dart` to split the body conditionally.

Replace content:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/toy_list_notifier.dart';
import '../controllers/toy_list_state.dart';
import 'widgets/featured_toy_slider.dart';
import 'widgets/toy_filter_bar.dart';
import 'widgets/toy_card.dart';
import 'toy_detail_screen.dart';
import '../../../auth/presentation/views/profile_screen.dart';
import '../../domain/entities/toy.dart';

class ToyListScreen extends ConsumerWidget {
  const ToyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toyListNotifierProvider);
    final filter = ref.watch(toyFilterProvider);

    final isSearchOrFilterActive = filter.query.trim().isNotEmpty ||
        filter.brand.isNotEmpty ||
        filter.ageGroup.isNotEmpty ||
        filter.gender.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toy Store Catalog'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Hồ sơ',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) =>
                  ref.read(toyListNotifierProvider.notifier).search(value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đồ chơi theo tên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const ToyFilterBar(),
          const SizedBox(height: 8),
          Expanded(
            child: isSearchOrFilterActive
                ? _buildFilteredBody(ref, state)
                : _buildCategorizedBody(ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredBody(WidgetRef ref, ToyListState state) {
    return state.when(
      initial: () => const Center(child: Text('Initializing store...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (toys) {
        if (toys.isEmpty) {
          return const Center(child: Text('Không tìm thấy đồ chơi nào.'));
        }
        return ListView.builder(
          itemCount: toys.length,
          itemBuilder: (context, index) {
            final toy = toys[index];
            return _buildToyCardRow(context, toy);
          },
        );
      },
      error: (message) => _buildErrorWidget(ref, message),
    );
  }

  Widget _buildCategorizedBody(WidgetRef ref, ToyListState state) {
    return state.when(
      initial: () => const Center(child: Text('Initializing store...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (allToys) {
        if (allToys.isEmpty) {
          return const Center(child: Text('Không có sản phẩm nào.'));
        }

        final brands = ref.watch(brandsListProvider);
        final ages = ref.watch(ageGroupOptionsProvider);
        final genders = ref.watch(genderOptionsProvider);

        final selectedBrandSection = ref.watch(selectedBrandSectionProvider);
        final selectedAgeSection = ref.watch(selectedAgeSectionProvider);
        final selectedGenderSection = ref.watch(selectedGenderSectionProvider);

        final brandToys = allToys.where((t) => t.brand == selectedBrandSection).toList();
        final ageToys = allToys.where((t) => t.ageGroup == selectedAgeSection).toList();
        final genderToys = allToys.where((t) => t.gender == selectedGenderSection).toList();

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Slider sản phẩm nổi bật
            FeaturedToySlider(toys: allToys),
            const SizedBox(height: 16),

            // 2. Mua theo thương hiệu
            if (brands.isNotEmpty) ...[
              _buildSectionHeader('Mua theo thương hiệu'),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brandName = brands[index].name;
                    final isSelected = selectedBrandSection == brandName;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(brandName),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(selectedBrandSectionProvider.notifier)
                            .state = brandName,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildHorizontalToysList(ref, brandToys),
              const SizedBox(height: 24),
            ],

            // 3. Phân loại theo độ tuổi
            if (ages.isNotEmpty) ...[
              _buildSectionHeader('Phân loại theo độ tuổi'),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ages.length,
                  itemBuilder: (context, index) {
                    final ageVal = ages[index];
                    final isSelected = selectedAgeSection == ageVal;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(ageVal),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(selectedAgeSectionProvider.notifier)
                            .state = ageVal,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildHorizontalToysList(ref, ageToys),
              const SizedBox(height: 24),
            ],

            // 4. Dành riêng cho bé
            if (genders.isNotEmpty) ...[
              _buildSectionHeader('Dành riêng cho bé'),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: genders.length,
                  itemBuilder: (context, index) {
                    final genderVal = genders[index];
                    final isSelected = selectedGenderSection == genderVal;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_genderLabel(genderVal)),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(selectedGenderSectionProvider.notifier)
                            .state = genderVal,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildHorizontalToysList(ref, genderToys),
              const SizedBox(height: 24),
            ],

            // 5. Gợi ý cho bạn (Tất cả sản phẩm cuộn dọc)
            _buildSectionHeader('Gợi ý cho bạn'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allToys.length,
              itemBuilder: (context, index) {
                final toy = allToys[index];
                return _buildToyCardRow(context, toy);
              },
            ),
          ],
        );
      },
      error: (message) => _buildErrorWidget(ref, message),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHorizontalToysList(WidgetRef ref, List<Toy> toys) {
    if (toys.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Text('Không có sản phẩm nào cho danh mục này.', style: TextStyle(color: Colors.grey)),
      );
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: toys.length,
        itemBuilder: (context, index) {
          final toy = toys[index];
          return ToyCard(
            toy: toy,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ToyDetailScreen(toy: toy)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToyCardRow(BuildContext context, Toy toy) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Image.network(
              toy.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.toys, size: 40, color: Colors.amber),
            ),
          ),
        ),
        title: Text(toy.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(toy.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(
          '\$${toy.price.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ToyDetailScreen(toy: toy)),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Failed to load toys: $message', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(toyListNotifierProvider.notifier).reload(),
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }

  String _genderLabel(String gender) {
    switch (gender) {
      case 'boy':
        return 'Bé trai';
      case 'girl':
        return 'Bé gái';
      case 'unisex':
        return 'Cả hai';
      default:
        return gender;
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/toy_list/presentation/views/toy_list_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/toy_list/presentation/views/toy_list_screen.dart test/features/toy_list/presentation/views/toy_list_screen_test.dart
git commit -m "feat: implement horizontal subcategory sections on homepage"
```
