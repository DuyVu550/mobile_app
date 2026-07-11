import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/toy_list_notifier.dart';
import '../controllers/toy_list_state.dart';
import 'widgets/featured_toy_slider.dart';
import '../../../auth/presentation/views/profile_screen.dart';

class ToyListScreen extends ConsumerWidget {
  const ToyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toyListNotifierProvider);

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
          Expanded(
            child: _buildBody(ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(WidgetRef ref, ToyListState state) {
    return state.when(
      initial: () => const Center(child: Text('Initializing store...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (toys) {
        if (toys.isEmpty) {
          return const Center(child: Text('Không tìm thấy đồ chơi nào.'));
        }
        return ListView.builder(
          // +1 cho slide sản phẩm nổi bật ở đầu danh sách.
          itemCount: toys.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: FeaturedToySlider(toys: toys),
              );
            }
            final toy = toys[index - 1];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.toys, size: 40, color: Colors.amber),
                title: Text(toy.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(toy.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Text(
                  '\$${toy.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            );
          },
        );
      },
      error: (message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load toys: $message', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(toyListNotifierProvider.notifier).loadToys(),
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}
