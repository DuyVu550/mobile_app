import 'package:flutter/material.dart';
import '../../domain/entities/toy.dart';

/// Màn chi tiết sản phẩm: ảnh, giá, mô tả và các thuộc tính phân loại
/// (thương hiệu, độ tuổi, giới tính, màu sắc).
class ToyDetailScreen extends StatelessWidget {
  final Toy toy;

  const ToyDetailScreen({super.key, required this.toy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toy.name),
        backgroundColor: Colors.amberAccent,
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              toy.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toy.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${toy.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Thông tin sản phẩm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _AttrRow(label: 'Thương hiệu', value: toy.brand),
                _AttrRow(label: 'Độ tuổi', value: toy.ageGroup),
                _AttrRow(label: 'Giới tính', value: _genderLabel(toy.gender)),
                _AttrRow(label: 'Màu sắc', value: toy.color),
                const SizedBox(height: 16),
                const Text('Mô tả',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  toy.description.isEmpty ? 'Chưa có mô tả.' : toy.description,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
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

class _AttrRow extends StatelessWidget {
  final String label;
  final String value;

  const _AttrRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // Thuộc tính rỗng thì ẩn hàng để giao diện gọn.
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
