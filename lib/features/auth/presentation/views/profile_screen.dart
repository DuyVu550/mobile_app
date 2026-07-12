import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../../products/presentation/views/category_admin_screen.dart';
import '../controllers/auth_action_controller.dart';
import '../controllers/auth_providers.dart';
import '../../domain/entities/app_user.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authActionControllerProvider.notifier).signOut();
    }
  }

  void _editProfile(BuildContext context, WidgetRef ref, AppUser user) {
    final nameController = TextEditingController(text: user.displayName);
    final avatarController = TextEditingController(text: user.photoUrl);
    String selectedAvatar = user.photoUrl ?? '';
    bool isLoading = false;
    bool isUploadingImage = false;

    final presets = [
      'https://api.dicebear.com/7.x/adventurer/png?seed=Felix',
      'https://api.dicebear.com/7.x/adventurer/png?seed=Aneka',
      'https://api.dicebear.com/7.x/bottts/png?seed=Bella',
      'https://api.dicebear.com/7.x/pixel-art/png?seed=John',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chỉnh sửa hồ sơ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                   const SizedBox(height: 20),
                  const Text(
                    'Chọn ảnh đại diện có sẵn hoặc tải lên:',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: presets.length,
                            itemBuilder: (context, index) {
                              final url = presets[index];
                              final isSelected = selectedAvatar == url;
                              return GestureDetector(
                                onTap: isLoading || isUploadingImage
                                    ? null
                                    : () {
                                        setModalState(() {
                                          selectedAvatar = url;
                                          avatarController.text = url;
                                        });
                                      },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(url),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: isUploadingImage
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : InkWell(
                                onTap: isLoading
                                    ? null
                                    : () async {
                                        final picker = ImagePicker();
                                        final XFile? image = await picker.pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (image == null) return;

                                        setModalState(() {
                                          isUploadingImage = true;
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
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Không thể tải ảnh lên: $error')),
                                                );
                                              }
                                            },
                                            (uploadedUrl) {
                                              setModalState(() {
                                                selectedAvatar = uploadedUrl;
                                                avatarController.text = uploadedUrl;
                                              });
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Tải ảnh lên thành công!')),
                                                );
                                              }
                                            },
                                          );
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Không thể tải ảnh lên: $e')),
                                            );
                                          }
                                        } finally {
                                          setModalState(() {
                                            isUploadingImage = false;
                                          });
                                        }
                                      },
                                borderRadius: BorderRadius.circular(30),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: avatarController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Hoặc nhập URL ảnh khác',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        selectedAvatar = val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(sheetContext),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final avatar = avatarController.text.trim();
                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Họ và tên không được để trống')),
                                  );
                                  return;
                                }

                                setModalState(() {
                                  isLoading = true;
                                });

                                final success = await ref
                                    .read(authActionControllerProvider.notifier)
                                    .updateProfile(
                                      displayName: name,
                                      photoUrl: avatar,
                                    );

                                if (sheetContext.mounted) {
                                  if (success) {
                                    ref.invalidate(authStateProvider);
                                    Navigator.pop(sheetContext); // Close sheet
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Cập nhật hồ sơ thành công!')),
                                    );
                                  } else {
                                    setModalState(() {
                                      isLoading = false;
                                    });
                                    final error = ref
                                        .read(authActionControllerProvider)
                                        .errorMessage;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(error ?? 'Cập nhật thất bại.')),
                                    );
                                  }
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black87),
                                ),
                              )
                            : const Text('Lưu'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final role = profileAsync.valueOrNull?['role'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: authState.when(
        data: (user) => user == null
            ? const Center(child: Text('Chưa đăng nhập.'))
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.amber.shade100,
                          backgroundImage:
                              user.photoUrl != null && user.photoUrl!.isNotEmpty
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                          child: user.photoUrl == null ||
                                  user.photoUrl!.isEmpty
                              ? Text(
                                  _initials(user.displayName, user.email),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                              onPressed: () => _editProfile(context, ref, user),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.displayName?.isNotEmpty == true
                              ? user.displayName!
                              : 'Chưa đặt tên',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: Colors.grey),
                          onPressed: () => _editProfile(context, ref, user),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _InfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: 32),
                  if (role == 'admin') ...[
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoryAdminScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.category),
                      label: const Text('Quản lý thể loại'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Đổi mật khẩu'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _confirmSignOut(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  String _initials(String? name, String email) {
    final source = (name != null && name.trim().isNotEmpty) ? name : email;
    final trimmed = source.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber),
        title: Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
