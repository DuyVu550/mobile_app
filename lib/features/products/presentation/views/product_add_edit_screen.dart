import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/services/file_upload_service.dart';
import 'category_admin_screen.dart'; // To consume adminCategoriesProvider
import 'brand_admin_screen.dart'; // To consume adminBrandsProvider

class ProductAddEditScreen extends ConsumerStatefulWidget {
  final String? productId;
  final Map<String, dynamic>? productData;

  const ProductAddEditScreen({super.key, this.productId, this.productData});

  @override
  ConsumerState<ProductAddEditScreen> createState() =>
      _ProductAddEditScreenState();
}

class _ProductAddEditScreenState extends ConsumerState<ProductAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;

  String? _selectedCategory;
  String? _selectedBrand;
  bool _isFeatured = false;
  bool _hasPromotion = false;

  final List<MapEntry<TextEditingController, TextEditingController>>
  _specControllers = [];

  @override
  void initState() {
    super.initState();
    final data = widget.productData;
    _nameController = TextEditingController(text: data?['name'] ?? '');
    _descController = TextEditingController(text: data?['description'] ?? '');
    _priceController = TextEditingController(
      text: data != null ? (data['price'] ?? 0.0).toStringAsFixed(0) : '',
    );
    _imageController = TextEditingController(text: data?['imageUrl'] ?? '');
    _selectedCategory = data?['category'];
    _isFeatured = data?['isFeatured'] ?? false;
    _hasPromotion = data?['hasPromotion'] ?? false;
    _selectedBrand = data?['brand'];

    // Load specs
    if (data?['specifications'] != null && data?['specifications'] is Map) {
      final specs = data?['specifications'] as Map;
      specs.forEach((key, val) {
        _specControllers.add(
          MapEntry(
            TextEditingController(text: key.toString()),
            TextEditingController(text: val.toString()),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    for (final entry in _specControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }

  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final uploadService = ref.read(fileUploadServiceProvider);
      final result = await uploadService.uploadFile(
        bytes,
        image.name,
        webBlobUrl: image.path,
      );

      result.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không thể tải ảnh lên: $error')),
            );
          }
        },
        (uploadedUrl) {
          setState(() {
            _imageController.text = uploadedUrl;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tải ảnh lên thành công!')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải ảnh lên: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _addSpecField() {
    setState(() {
      _specControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeSpecField(int index) {
    setState(() {
      final entry = _specControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn thể loại')));
      return;
    }
    if (_imageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tải ảnh sản phẩm lên')),
      );
      return;
    }

    if (_selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thương hiệu')),
      );
      return;
    }

    final double price = double.tryParse(_priceController.text) ?? 0.0;

    // Construct specs map
    final Map<String, String> specs = {};
    for (final entry in _specControllers) {
      final k = entry.key.text.trim();
      final v = entry.value.text.trim();
      if (k.isNotEmpty && v.isNotEmpty) {
        specs[k] = v;
      }
    }

    final productPayload = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': price,
      'imageUrl': _imageController.text.trim(),
      'category': _selectedCategory,
      'brand': _selectedBrand,
      'isFeatured': _isFeatured,
      'hasPromotion': _hasPromotion,
      'rating': widget.productData?['rating'] ?? 5.0,
      'specifications': specs.isNotEmpty ? specs : null,
    };

    try {
      if (widget.productId != null) {
        await ref
            .read(firestoreProvider)
            .collection('products')
            .doc(widget.productId)
            .update(productPayload);
      } else {
        await ref
            .read(firestoreProvider)
            .collection('products')
            .add(productPayload);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu sản phẩm: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.productId == null ? 'THÊM SẢN PHẨM MỚI' : 'CHỈNH SỬA SẢN PHẨM',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade800,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập tên sản phẩm'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập mô tả'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá sản phẩm (đ)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập giá';
                  if (double.tryParse(v) == null) return 'Giá trị không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _imageController.text.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(
                              _imageController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image),
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                            size: 36,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: _isUploadingImage
                          ? const Center(child: CircularProgressIndicator())
                          : OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _pickAndUploadImage,
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: const Text('Tải ảnh sản phẩm'),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Lỗi tải thể loại: $err'),
                data: (cats) {
                  final catNames = cats
                      .map((c) => (c['name'] ?? '').toString())
                      .where((n) => n.isNotEmpty)
                      .toList();
                  return DropdownButtonFormField<String>(
                    initialValue:
                        _selectedCategory != null &&
                            catNames.contains(_selectedCategory)
                        ? _selectedCategory
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Chọn thể loại',
                      border: OutlineInputBorder(),
                    ),
                    items: catNames
                        .map(
                          (name) =>
                              DropdownMenuItem(value: name, child: Text(name)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  );
                },
              ),
              const SizedBox(height: 16),
              ref
                  .watch(adminBrandsProvider)
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Lỗi tải thương hiệu: $err'),
                    data: (brands) {
                      final brandNames = brands
                          .map((b) => (b['name'] ?? '').toString())
                          .where((n) => n.isNotEmpty)
                          .toList();
                      return DropdownButtonFormField<String>(
                        initialValue:
                            _selectedBrand != null &&
                                brandNames.contains(_selectedBrand)
                            ? _selectedBrand
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Chọn thương hiệu',
                          border: OutlineInputBorder(),
                        ),
                        items: brandNames
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedBrand = val),
                      );
                    },
                  ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Sản phẩm nổi bật (Featured)'),
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
              ),
              SwitchListTile(
                title: const Text('Có chương trình khuyến mãi (Promotion)'),
                value: _hasPromotion,
                onChanged: (val) => setState(() => _hasPromotion = val),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thông số kỹ thuật',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addSpecField,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm dòng'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _specControllers.length,
                itemBuilder: (context, idx) {
                  final entry = _specControllers[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.key,
                            decoration: const InputDecoration(
                              labelText: 'Tên thông số (e.g. RAM)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: const InputDecoration(
                              labelText: 'Giá trị (e.g. 8GB)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeSpecField(idx),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveProduct,
                child: const Text(
                  'LƯU SẢN PHẨM',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
