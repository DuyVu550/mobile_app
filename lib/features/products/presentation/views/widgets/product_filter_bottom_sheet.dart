import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/product_list_notifier.dart';

class ProductFilterBottomSheet extends ConsumerStatefulWidget {
  const ProductFilterBottomSheet({super.key});

  @override
  ConsumerState<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState
    extends ConsumerState<ProductFilterBottomSheet> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  double? _selectedMinRating;
  bool _onlyPromotions = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(productListNotifierProvider);
    _minPriceController = TextEditingController(
        text: state.minPrice != null ? state.minPrice!.toInt().toString() : '');
    _maxPriceController = TextEditingController(
        text: state.maxPrice != null ? state.maxPrice!.toInt().toString() : '');
    _selectedMinRating = state.minRating;
    _onlyPromotions = state.onlyPromotions;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _selectPricePreset(double? min, double? max) {
    setState(() {
      _minPriceController.text = min != null ? min.toInt().toString() : '';
      _maxPriceController.text = max != null ? max.toInt().toString() : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc tìm kiếm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Khoảng giá
            const Text(
              'Khoảng giá (VND)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Từ',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—'),
                ),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Đến',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Preset giá
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    label: const Text('Dưới 5tr'),
                    onPressed: () => _selectPricePreset(0, 5000000),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('5tr - 15tr'),
                    onPressed: () => _selectPricePreset(5000000, 15000000),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Trên 15tr'),
                    onPressed: () => _selectPricePreset(15000000, null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Đánh giá sao tối thiểu
            const Text(
              'Đánh giá',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _selectedMinRating == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMinRating = null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('4★ trở lên'),
                  selected: _selectedMinRating == 4.0,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMinRating = 4.0);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('3★ trở lên'),
                  selected: _selectedMinRating == 3.0,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMinRating = 3.0);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Khuyến mãi
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Chỉ hiện sản phẩm khuyến mãi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: _onlyPromotions,
              onChanged: (val) {
                setState(() => _onlyPromotions = val);
              },
            ),
            const SizedBox(height: 24),

            // Áp dụng / Hủy
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(productListNotifierProvider.notifier)
                          .clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Thiết lập lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final minVal = double.tryParse(_minPriceController.text);
                      final maxVal = double.tryParse(_maxPriceController.text);
                      ref
                          .read(productListNotifierProvider.notifier)
                          .applyFilters(
                            minPrice: minVal,
                            maxPrice: maxVal,
                            minRating: _selectedMinRating,
                            onlyPromotions: _onlyPromotions,
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
