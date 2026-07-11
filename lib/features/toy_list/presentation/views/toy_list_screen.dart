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
      height: 200,
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
