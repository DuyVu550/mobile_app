import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/services/file_upload_service.dart';

final adminBrandsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('brands')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class BrandAdminScreen extends ConsumerStatefulWidget {
  const BrandAdminScreen({super.key});

  @override
  ConsumerState<BrandAdminScreen> createState() => _BrandAdminScreenState();
}

class _BrandAdminScreenState extends ConsumerState<BrandAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddEditDialog([String? id, Map<String, dynamic>? data]) async {
    final nameController = TextEditingController(text: data?['name'] ?? '');
    final logoController = TextEditingController(text: data?['logoUrl'] ?? '');
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickAndUpload() async {
            final picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image == null) return;

            setModalState(() {
              isUploading = true;
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
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Không thể tải ảnh lên: $error')),
                  );
                },
                (uploadedUrl) {
                  setModalState(() {
                    logoController.text = uploadedUrl;
                  });
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Tải ảnh lên thành công!')),
                  );
                },
              );
            } catch (e) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Không thể tải ảnh lên: $e')),
              );
            } finally {
              setModalState(() {
                isUploading = false;
              });
            }
          }

          final currentLogoUrl = logoController.text;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(id == null ? 'Thêm thương hiệu' : 'Chỉnh sửa thương hiệu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên thương hiệu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: currentLogoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  currentLogoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                                ),
                              )
                            : const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: isUploading
                              ? const Center(child: CircularProgressIndicator())
                              : OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: pickAndUpload,
                                  icon: const Icon(Icons.cloud_upload_outlined),
                                  label: const Text('Tải Logo'),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey.shade900),
                onPressed: () async {
                  final name = nameController.text.trim();
                  final logo = logoController.text.trim();
                  if (name.isEmpty) return;

                  final payload = {
                    'name': name,
                    'logoUrl': logo,
                  };

                  if (id == null) {
                    await ref.read(firestoreProvider).collection('brands').add(payload);
                  } else {
                    await ref.read(firestoreProvider).collection('brands').doc(id).update(payload);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteBrand(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thương hiệu "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(firestoreProvider).collection('brands').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(adminBrandsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'QUẢN LÝ THƯƠNG HIỆU',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade800,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thương hiệu...',
                prefixIcon: Icon(Icons.search, color: Colors.blueGrey.shade400, size: 22),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blueGrey.shade600, width: 1.5),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: brandsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (brands) {
                final filtered = brands.where((b) {
                  final name = (b['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy thương hiệu nào.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final item = filtered[idx];
                    final id = item['id'] as String;
                    final name = (item['name'] ?? '').toString();
                    final logoUrl = (item['logoUrl'] ?? '').toString();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: logoUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: Image.network(
                                      logoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(Icons.business),
                                    ),
                                  )
                                : const Icon(Icons.business),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: Colors.blue.shade600, size: 20),
                                onPressed: () => _showAddEditDialog(id, item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 20),
                                onPressed: () => _deleteBrand(id, name),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        hoverElevation: 2,
        label: const Text('Thêm thương hiệu'),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
