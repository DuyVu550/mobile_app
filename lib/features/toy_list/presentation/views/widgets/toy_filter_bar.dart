import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/toy_list_notifier.dart';

/// Thanh lọc sản phẩm: chip thương hiệu + dropdown độ tuổi & giới tính.
/// Mọi tùy chọn derive từ dữ liệu realtime nên không cần cấu hình cứng.
class ToyFilterBar extends ConsumerWidget {
  const ToyFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brands = ref.watch(brandsListProvider);
    final ages = ref.watch(ageGroupOptionsProvider);
    final genders = ref.watch(genderOptionsProvider);
    final filter = ref.watch(toyFilterProvider);
    final notifier = ref.read(toyListNotifierProvider.notifier);

    final hasAnyFilter = filter.brand.isNotEmpty ||
        filter.ageGroup.isNotEmpty ||
        filter.gender.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (brands.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  final isSelected = filter.brand == brand.name;

                  return GestureDetector(
                    onTap: () => notifier.filterByBrand(isSelected ? '' : brand.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.amber : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.amber.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: ClipOval(
                              child: Image.network(
                                brand.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.amber.shade100,
                                  child: Center(
                                    child: Text(
                                      brand.name.isNotEmpty ? brand.name[0].toUpperCase() : 'B',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            brand.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.amber.shade800 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  hint: 'Độ tuổi',
                  value: filter.ageGroup.isEmpty ? null : filter.ageGroup,
                  options: ages,
                  onChanged: (v) => notifier.filterByAgeGroup(v ?? ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterDropdown(
                  hint: 'Giới tính',
                  value: filter.gender.isEmpty ? null : filter.gender,
                  options: genders,
                  labelOf: _genderLabel,
                  onChanged: (v) => notifier.filterByGender(v ?? ''),
                ),
              ),
              if (hasAnyFilter)
                IconButton(
                  tooltip: 'Xóa lọc',
                  icon: const Icon(Icons.filter_alt_off),
                  onPressed: notifier.clearFilters,
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _genderLabel(String g) {
    switch (g) {
      case 'boy':
        return 'Bé trai';
      case 'girl':
        return 'Bé gái';
      case 'unisex':
        return 'Cả hai';
      default:
        return g;
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String Function(String)? labelOf;

  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.labelOf,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      hint: Text(hint),
      items: [
        const DropdownMenuItem(value: null, child: Text('Tất cả')),
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text(labelOf?.call(option) ?? option),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
