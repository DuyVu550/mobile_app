import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_action_controller.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../auth/presentation/views/profile_screen.dart';
import '../../../products/presentation/views/category_admin_screen.dart';
import '../../../products/presentation/views/product_admin_screen.dart';
import '../../../products/presentation/views/brand_admin_screen.dart';
import '../../../../features/orders/presentation/views/order_admin_screen.dart';
import '../../../../features/feedback/presentation/views/feedback_admin_screen.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTabIndex = 0;

  final List<String> _tabTitles = [
    'TỔNG QUAN',
    'QUẢN LÝ THỂ LOẠI',
    'QUẢN LÝ SẢN PHẨM',
    'QUẢN LÝ THƯƠNG HIỆU',
    'QUẢN LÝ ĐƠN HÀNG',
    'QUẢN LÝ PHẢN HỒI',
    'HỒ SƠ CÁ NHÂN',
  ];

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào mừng quay trở lại, Admin!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 24),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Tổng số thể loại',
                  value: 'Đang hoạt động',
                  icon: Icons.category_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Trạng thái hệ thống',
                  value: 'Ổn định',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return const CategoryAdminScreen();
      case 2:
        return const ProductAdminScreen();
      case 3:
        return const BrandAdminScreen();
      case 4:
        return const OrderAdminScreen();
      case 5:
        return const FeedbackAdminScreen();
      case 6:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  String _initials(String? name, String email) {
    final source = (name != null && name.trim().isNotEmpty) ? name : email;
    final trimmed = source.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  Widget _buildSidebar(BuildContext context, {bool isPersistent = true}) {
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final user = authState.valueOrNull;
    final profile = profileAsync.valueOrNull;

    if (user == null) return const SizedBox.shrink();

    final displayName = user.displayName ?? profile?['displayName'] ?? '';
    final email = user.email;
    final photoUrl = user.photoUrl ?? profile?['photoUrl'];

    return Material(
      color: Colors.white,
      shape: Border(
        right: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: SizedBox(
        width: 260,
        child: Column(
        children: [
          // Sidebar User Header (Custom, clean, no overlapping)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.amber.shade100,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Text(
                          _initials(displayName, email),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName.isNotEmpty ? displayName : 'Admin User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blueGrey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ADMINISTRATOR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sidebar Items
          _buildSidebarItem(0, Icons.dashboard_outlined, 'Tổng quan'),
          _buildSidebarItem(1, Icons.category_outlined, 'Quản lý thể loại'),
          _buildSidebarItem(2, Icons.shopping_bag_outlined, 'Quản lý sản phẩm'),
          _buildSidebarItem(3, Icons.business_outlined, 'Quản lý thương hiệu'),
          _buildSidebarItem(4, Icons.receipt_long, 'Quản lý đơn hàng'),
          _buildSidebarItem(5, Icons.feedback_outlined, 'Quản lý phản hồi'),
          _buildSidebarItem(6, Icons.person_outline, 'Hồ sơ cá nhân'),
          const Spacer(),
          Divider(color: Colors.grey.shade200),
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
              ),
              onTap: () async {
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
              if (!isPersistent && context.mounted) {
                Navigator.of(context).pop(); // Close drawer
              }
              await ref.read(authActionControllerProvider.notifier).signOut();
            }
          },
        ),
      ),
      const SizedBox(height: 16),
        ],
      ),
    ),);
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedTabIndex == index;
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blueGrey.shade900 : Colors.grey.shade500,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blueGrey.shade900 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.grey.shade100,
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          if (_scaffoldKey.currentState?.isDrawerOpen == true) {
            Navigator.of(context).pop(); // Close drawer on mobile
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: isWideScreen
          ? null
          : AppBar(
              title: Text(_tabTitles[_selectedTabIndex]),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blueGrey.shade800,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: Colors.grey.shade200,
                  height: 1.0,
                ),
              ),
            ),
      drawer: isWideScreen
          ? null
          : Drawer(
              child: Builder(
                builder: (context) => _buildSidebar(context, isPersistent: false),
              ),
            ),
      body: Row(
        children: [
          if (isWideScreen) _buildSidebar(context, isPersistent: true),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
