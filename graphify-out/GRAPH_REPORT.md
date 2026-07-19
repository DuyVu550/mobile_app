# Graph Report - .  (2026-07-19)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 1159 nodes · 1680 edges · 82 communities (74 shown, 8 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3245d8e4`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- login_screen.dart
- GeneratedPluginRegistrant.swift
- admin_home_screen.dart
- order_providers_test.dart
- product_list_notifier.dart
- profile_screen.dart
- top_products_admin_screen.dart
- my_application.cc
- product_add_edit_screen.dart
- revenue_admin_screen.dart
- file_upload_service.dart
- auth_action_controller_test.dart
- auth_action_controller.dart
- promotion_admin_screen.dart
- order_entity.dart
- product_model.dart
- auth_providers.dart
- product_list_state.dart
- brand_admin_screen.dart
- checkout_providers.dart
- package:toy_app/core/providers/firebase_providers.dart
- package:flutter_test/flutter_test.dart
- package:flutter_riverpod/flutter_riverpod.dart
- auth_repository_impl.dart
- product_list_notifier_test.dart
- product_remote_datasource.dart
- category_admin_screen.dart
- auth_repository_impl_test.dart
- auth_repository.dart
- product_filter_bottom_sheet.dart
- cart_providers.dart
- checkout_screen.dart
- featured_product_slider.dart
- auth_remote_datasource.dart
- product.dart
- wWinMain
- home_screen_test.dart
- product_admin_screen.dart
- admin_shared_widgets.dart
- cart_remote_datasource.dart
- promotion_repository_impl.dart
- manifest.json
- order_history_screen.dart
- address_repository.dart
- StatelessWidget
- order_admin_screen.dart
- Product
- CartActionNotifier
- authStateProvider
- cart_repository.dart
- cart_repository_impl.dart
- order_repository_impl.dart
- product_detail_screen.dart
- package:toy_app/core/utils/string_utils.dart
- cart_item_model.dart
- string_utils.dart
- address.dart
- address_repository_impl.dart
- promotion.dart
- rating_section.dart
- package:flutter/material.dart
- auth_form_validation_test.dart
- cart_icon_button.dart
- app_user.dart
- AsyncValue
- product_card.dart
- MaterialPageRoute
- FeaturedProductSlider
- MainActivity
- @JsonSerializable
- flutter_export_environment.sh
- Package.swift
- @JsonKey
- ../../../feedback/data/feedback_service.dart
- fromJson
- String?

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `authActionControllerProvider` - 14 edges
3. `authStateProvider` - 12 edges
4. `MessageHandler` - 12 edges
5. `FlutterWindow` - 10 edges
6. `Create` - 10 edges
7. `WndProc` - 10 edges
8. `_CheckoutScreenState` - 9 edges
9. `MessageHandler` - 9 edges
10. `firestoreProvider` - 8 edges

## Surprising Connections (you probably didn't know these)
- `FakeAuthRepository` --implements--> `AuthRepository`  [EXTRACTED]
  test/features/auth/auth_action_controller_test.dart → lib/features/auth/domain/repositories/auth_repository.dart
- `FakeProductRepository` --implements--> `ProductRepository`  [EXTRACTED]
  test/features/home/presentation/views/home_screen_test.dart → lib/features/products/domain/repositories/product_repository.dart
- `FakeProductRepository` --implements--> `ProductRepository`  [EXTRACTED]
  test/features/products/presentation/controllers/product_list_notifier_test.dart → lib/features/products/domain/repositories/product_repository.dart
- `ThrowingAuthDataSource` --implements--> `AuthRemoteDataSource`  [EXTRACTED]
  test/features/auth/auth_repository_impl_test.dart → lib/features/auth/data/datasources/auth_remote_datasource.dart
- `FakeAppUser` --inherits--> `AppUser`  [EXTRACTED]
  test/features/home/presentation/views/admin_home_screen_test.dart → lib/features/auth/domain/entities/app_user.dart

## Import Cycles
- None detected.

## Communities (82 total, 8 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "login_screen.dart"
Cohesion: 0.05
Nodes (52): ConsumerState, ConsumerStatefulWidget, ../controllers/auth_action_controller.dart, forgot_password_screen.dart, FormState, authActionControllerProvider, build, ChangePasswordScreen (+44 more)

### Community 2 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (30): Any, cloud_firestore, Cocoa, file_selector_macos, firebase_auth, firebase_core, Flutter, FlutterAppDelegate (+22 more)

### Community 3 - "admin_home_screen.dart"
Cohesion: 0.05
Nodes (42): ../../../auth/presentation/controllers/auth_action_controller.dart, ../../../auth/presentation/views/profile_screen.dart, categoriesProvider, ../../../../features/cart/presentation/views/promotion_admin_screen.dart, ../../../../features/feedback/presentation/views/feedback_admin_screen.dart, ../../../../features/orders/presentation/views/order_admin_screen.dart, ../../../../features/orders/presentation/views/revenue_admin_screen.dart, ../../../../features/orders/presentation/views/top_products_admin_screen.dart (+34 more)

### Community 4 - "order_providers_test.dart"
Cohesion: 0.05
Nodes (38): ../entities/order_entity.dart, FakeFirebaseFirestore, int?, OrderRepositoryImpl, OrderRepository, submitDeliveryReview, submitOrder, updateOrderStatus (+30 more)

### Community 5 - "product_list_notifier.dart"
Cohesion: 0.06
Nodes (34): ../../data/datasources/product_remote_datasource.dart, ../../data/repositories/product_repository_impl.dart, ../datasources/product_remote_datasource.dart, ../../domain/repositories/product_repository.dart, ../../domain/usecases/watch_products_usecase.dart, ../entities/product.dart, Left, ProductRepositoryImpl (+26 more)

### Community 6 - "profile_screen.dart"
Cohesion: 0.08
Nodes (29): authActionControllerProvider, authStateProvider, ../../../cart/presentation/views/cart_icon_button.dart, change_password_screen.dart, ../../domain/entities/app_user.dart, feedbackServiceProvider, fileUploadServiceProvider, build (+21 more)

### Community 7 - "top_products_admin_screen.dart"
Cohesion: 0.07
Nodes (28): _barColor, _computeTopProducts, createState, _end, endDay, initState, label, map (+20 more)

### Community 8 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 9 - "product_add_edit_screen.dart"
Cohesion: 0.08
Nodes (24): brand_admin_screen.dart, category_admin_screen.dart, _addSpecField, createState, _descController, dispose, _formKey, _hasPromotion (+16 more)

### Community 10 - "revenue_admin_screen.dart"
Cohesion: 0.09
Nodes (23): admin_shared_widgets.dart, averageOrderValue, byDay, _computeSummary, createState, _end, icon, iconColor (+15 more)

### Community 11 - "file_upload_service.dart"
Cohesion: 0.08
Nodes (21): dart:convert, dart:developer, Dio, features/auth/presentation/views/auth_gate.dart, firebase_options.dart, _dio, FileUploadService, uploadFile (+13 more)

### Community 12 - "auth_action_controller_test.dart"
Cohesion: 0.08
Nodes (23): Either, package:toy_app/features/auth/domain/repositories/auth_repository.dart, package:toy_app/features/auth/presentation/controllers/auth_action_controller.dart, ProviderContainer, authStateChanges, changePassword, changePasswordResult, container (+15 more)

### Community 13 - "auth_action_controller.dart"
Cohesion: 0.09
Nodes (22): auth_providers.dart, AutoDisposeNotifier, AuthActionController, AuthActionState, build, changePassword, errorMessage, failure (+14 more)

### Community 14 - "promotion_admin_screen.dart"
Cohesion: 0.10
Nodes (22): Color, adminPromotionsProvider, build, color, createState, _deletePromotion, dispose, icon (+14 more)

### Community 15 - "order_entity.dart"
Cohesion: 0.09
Nodes (22): addressLine, copyWith, createdAt, deliveryComment, deliveryRating, discount, fromJson, id (+14 more)

### Community 16 - "product_model.dart"
Cohesion: 0.10
Nodes (20): category, description, hashCode, hasPromotion, id, imageUrl, isFeatured, name (+12 more)

### Community 17 - "auth_providers.dart"
Cohesion: 0.12
Nodes (19): ../../data/datasources/auth_remote_datasource.dart, ../../data/repositories/auth_repository_impl.dart, ../../domain/usecases/auth_usecases.dart, ChangePasswordUseCase, execute, _repository, SendPasswordResetUseCase, SignInUseCase (+11 more)

### Community 18 - "product_list_state.dart"
Cohesion: 0.11
Nodes (18): bool get, _, hashCode, maxPrice, minPrice, minRating, onlyPromotions, operator (+10 more)

### Community 19 - "brand_admin_screen.dart"
Cohesion: 0.14
Nodes (18): ../../../../core/services/file_upload_service.dart, firestoreProvider, fileUploadServiceProvider, _showAddEditDialog, adminBrandsProvider, BrandAdminScreen, _BrandAdminScreenState, build (+10 more)

### Community 20 - "checkout_providers.dart"
Cohesion: 0.11
Nodes (17): appliedPromotion, applyPromotion, auth, copyWith, firestore, _initDefaultAddress, paymentMethod, promotionRepositoryProvider (+9 more)

### Community 21 - "package:toy_app/core/providers/firebase_providers.dart"
Cohesion: 0.13
Nodes (14): package:fake_cloud_firestore/fake_cloud_firestore.dart, package:toy_app/core/providers/firebase_providers.dart, package:toy_app/features/products/presentation/views/brand_admin_screen.dart, package:toy_app/features/products/presentation/views/category_admin_screen.dart, package:toy_app/features/products/presentation/views/product_add_edit_screen.dart, package:toy_app/features/products/presentation/views/product_admin_screen.dart, main, wrap (+6 more)

### Community 22 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.14
Nodes (13): package:flutter_test/flutter_test.dart, package:toy_app/features/products/presentation/controllers/review_providers.dart, package:toy_app/features/products/presentation/views/product_detail_screen.dart, package:toy_app/features/products/presentation/views/widgets/featured_product_slider.dart, package:toy_app/features/products/presentation/views/widgets/product_card.dart, package:toy_app/features/products/presentation/views/widgets/rating_section.dart, main, main (+5 more)

### Community 23 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.15
Nodes (13): ../../../../core/providers/firebase_providers.dart, FirebaseFirestore, fromFirestore, PromotionModel, FeedbackService, feedbackServiceProvider, firestore, submitFeedback (+5 more)

### Community 24 - "auth_repository_impl.dart"
Cohesion: 0.13
Nodes (14): ../datasources/auth_remote_datasource.dart, ../../domain/repositories/auth_repository.dart, AuthRemoteDataSource, authStateChanges, changePassword, _mapError, _remoteDataSource, sendPasswordReset (+6 more)

### Community 25 - "product_list_notifier_test.dart"
Cohesion: 0.14
Nodes (12): CartItem, product, productId, quantity, package:toy_app/features/products/domain/entities/product.dart, package:toy_app/features/products/domain/repositories/product_repository.dart, package:toy_app/features/products/domain/usecases/watch_products_usecase.dart, package:toy_app/features/products/presentation/controllers/product_list_notifier.dart (+4 more)

### Community 26 - "product_remote_datasource.dart"
Cohesion: 0.14
Nodes (13): _collection, _firestore, ProductRemoteDataSource, ProductRemoteDataSourceImpl, watchProducts, ../models/product_model.dart, package:toy_app/features/products/data/datasources/product_remote_datasource.dart, package:toy_app/features/products/data/models/product_model.dart (+5 more)

### Community 27 - "category_admin_screen.dart"
Cohesion: 0.16
Nodes (14): adminCategoriesProvider, build, CategoryAdminScreen, _CategoryAdminScreenState, createState, dispose, ref, _searchController (+6 more)

### Community 28 - "auth_repository_impl_test.dart"
Cohesion: 0.13
Nodes (14): package:toy_app/features/auth/data/datasources/auth_remote_datasource.dart, package:toy_app/features/auth/data/repositories/auth_repository_impl.dart, authStateChanges, cases, changePassword, code, currentUser, _error (+6 more)

### Community 29 - "auth_repository.dart"
Cohesion: 0.14
Nodes (13): AppUser? get, ../entities/app_user.dart, AuthRepositoryImpl, AuthRepository, authStateChanges, changePassword, currentUser, sendPasswordReset (+5 more)

### Community 30 - "product_filter_bottom_sheet.dart"
Cohesion: 0.15
Nodes (13): class, ../../controllers/product_list_notifier.dart, double?, build, createState, dispose, _maxPriceController, _minPriceController (+5 more)

### Community 31 - "cart_providers.dart"
Cohesion: 0.14
Nodes (13): ../../data/datasources/cart_remote_datasource.dart, ../../data/repositories/cart_repository_impl.dart, ../../domain/entities/cart_item.dart, auth, build, cartItemCountProvider, cartModelsAsync, firestore (+5 more)

### Community 32 - "checkout_screen.dart"
Cohesion: 0.19
Nodes (13): addressesProvider, addressRepositoryProvider, checkoutStateProvider, promotionsProvider, _addAddressDialog, build, _CheckoutScreenState, createState (+5 more)

### Community 33 - "featured_product_slider.dart"
Cohesion: 0.15
Nodes (12): dart:async, createState, _currentPage, dispose, initState, _pageController, products, _startTimer (+4 more)

### Community 34 - "auth_remote_datasource.dart"
Cohesion: 0.15
Nodes (12): FirebaseAuth, authStateChanges, changePassword, currentUser, _firebaseAuth, sendPasswordReset, signIn, signOut (+4 more)

### Community 35 - "product.dart"
Cohesion: 0.15
Nodes (12): category, description, hasPromotion, id, imageUrl, isFeatured, name, price (+4 more)

### Community 36 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 37 - "home_screen_test.dart"
Cohesion: 0.20
Nodes (10): AppUser, package:toy_app/features/auth/domain/entities/app_user.dart, package:toy_app/features/auth/presentation/controllers/auth_providers.dart, package:toy_app/features/home/presentation/views/admin_home_screen.dart, package:toy_app/features/home/presentation/views/home_screen.dart, FakeAppUser, main, FakeAppUser (+2 more)

### Community 38 - "product_admin_screen.dart"
Cohesion: 0.21
Nodes (11): adminProductsProvider, build, createState, dispose, ProductAdminScreen, _ProductAdminScreenState, ref, _searchController (+3 more)

### Community 39 - "admin_shared_widgets.dart"
Cohesion: 0.18
Nodes (10): IconData, AdminDateRangeButton, AdminEmptyState, build, end, fmtDate, icon, onTap (+2 more)

### Community 40 - "cart_remote_datasource.dart"
Cohesion: 0.20
Nodes (10): addToCart, _cartCol, CartRemoteDataSource, CartRemoteDataSourceImpl, clearCart, _firestore, removeFromCart, updateQuantity (+2 more)

### Community 41 - "promotion_repository_impl.dart"
Cohesion: 0.20
Nodes (9): _firestore, PromotionRepositoryImpl, watchActivePromotions, Promotion, PromotionRepository, watchActivePromotions, package:toy_app/features/cart/data/models/promotion_model.dart, package:toy_app/features/cart/domain/entities/promotion.dart (+1 more)

### Community 42 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 43 - "order_history_screen.dart"
Cohesion: 0.22
Nodes (9): ConsumerWidget, build, _buildStep, OrderHistoryScreen, OrderListTab, _showRatingDialog, status, package:toy_app/features/cart/presentation/views/cart_icon_button.dart (+1 more)

### Community 44 - "address_repository.dart"
Cohesion: 0.20
Nodes (8): fromFirestore, toFirestore, AddressRepositoryImpl, addAddress, AddressRepository, setDefaultAddress, watchAddresses, package:toy_app/features/cart/domain/entities/address.dart

### Community 45 - "StatelessWidget"
Cohesion: 0.20
Nodes (10): _InfoChip, _PromotionCard, _StatusBadge, _BarChartCard, _KpiCard, _KpiRow, _ModeToggle, _ProductRankCard (+2 more)

### Community 46 - "order_admin_screen.dart"
Cohesion: 0.24
Nodes (9): adminOrdersProvider, orderControllerProvider, AdminOrderListTab, build, OrderAdminScreen, status, build, build (+1 more)

### Community 47 - "Product"
Cohesion: 0.22
Nodes (9): @freezed, ProductModel, _ProductModel, Product, ProductListNotifier, ProductListState, _ProductListState, ProductListState (+1 more)

### Community 48 - "CartActionNotifier"
Cohesion: 0.31
Nodes (9): AutoDisposeAsyncNotifier, add, CartActionNotifier, cartRepositoryProvider, cartStreamProvider, remove, updateQty, productListNotifierProvider (+1 more)

### Community 49 - "authStateProvider"
Cohesion: 0.28
Nodes (8): ../controllers/auth_providers.dart, ../../../home/presentation/views/admin_home_screen.dart, ../../../home/presentation/views/home_screen.dart, authStateProvider, userProfileProvider, AuthGate, build, login_screen.dart

### Community 50 - "cart_repository.dart"
Cohesion: 0.22
Nodes (8): ../../data/models/cart_item_model.dart, CartRepositoryImpl, addToCart, CartRepository, clearCart, removeFromCart, updateQuantity, watchCart

### Community 51 - "cart_repository_impl.dart"
Cohesion: 0.22
Nodes (8): ../datasources/cart_remote_datasource.dart, ../../domain/repositories/cart_repository.dart, addToCart, clearCart, _dataSource, removeFromCart, updateQuantity, watchCart

### Community 52 - "order_repository_impl.dart"
Cohesion: 0.22
Nodes (8): ../../domain/entities/order_entity.dart, ../../domain/repositories/order_repository.dart, _firestore, submitDeliveryReview, submitOrder, updateOrderStatus, watchAllOrders, watchUserOrders

### Community 53 - "product_detail_screen.dart"
Cohesion: 0.29
Nodes (7): ../../../cart/presentation/controllers/cart_providers.dart, ../../../../core/utils/string_utils.dart, cartActionControllerProvider, build, product, ProductDetailScreen, widgets/rating_section.dart

### Community 54 - "package:toy_app/core/utils/string_utils.dart"
Cohesion: 0.32
Nodes (7): checkout_screen.dart, ../controllers/cart_providers.dart, cartItemsProvider, cartTotalPriceProvider, build, CartScreen, package:toy_app/core/utils/string_utils.dart

### Community 55 - "cart_item_model.dart"
Cohesion: 0.25
Nodes (7): DateTime, addedAt, CartItemModel, fromFirestore, productId, quantity, toFirestore

### Community 56 - "string_utils.dart"
Cohesion: 0.25
Nodes (7): buffer, formatPrice, lower, removeDiacritics, toString, withDiacritics, withoutDiacritics

### Community 57 - "address.dart"
Cohesion: 0.25
Nodes (7): AddressModel, Address, addressLine, id, isDefault, phoneNumber, receiverName

### Community 58 - "address_repository_impl.dart"
Cohesion: 0.25
Nodes (7): addAddress, _addressCol, _firestore, setDefaultAddress, watchAddresses, package:toy_app/features/cart/data/models/address_model.dart, package:toy_app/features/cart/domain/repositories/address_repository.dart

### Community 59 - "promotion.dart"
Cohesion: 0.25
Nodes (7): code, description, discountPercent, endDate, id, isActive, minOrderValue

### Community 60 - "rating_section.dart"
Cohesion: 0.33
Nodes (6): ../../../../auth/presentation/controllers/auth_providers.dart, ../../controllers/review_providers.dart, reviewsProvider, build, productId, RatingSection

### Community 61 - "package:flutter/material.dart"
Cohesion: 0.33
Nodes (6): ../../data/feedback_service.dart, allFeedbacksProvider, build, FeedbackAdminScreen, _formatDateTime, package:flutter/material.dart

### Community 62 - "auth_form_validation_test.dart"
Cohesion: 0.29
Nodes (6): package:toy_app/features/auth/presentation/views/change_password_screen.dart, package:toy_app/features/auth/presentation/views/forgot_password_screen.dart, package:toy_app/features/auth/presentation/views/login_screen.dart, package:toy_app/features/auth/presentation/views/register_screen.dart, main, wrap

### Community 63 - "cart_icon_button.dart"
Cohesion: 0.40
Nodes (5): cartItemCountProvider, build, CartIconButton, package:toy_app/features/cart/presentation/controllers/cart_providers.dart, package:toy_app/features/cart/presentation/views/cart_screen.dart

### Community 64 - "app_user.dart"
Cohesion: 0.33
Nodes (5): displayName, email, emailVerified, photoUrl, uid

### Community 65 - "AsyncValue"
Cohesion: 0.40
Nodes (5): AsyncValue, CheckoutNotifier, CheckoutState, OrderController, StateNotifier

### Community 66 - "product_card.dart"
Cohesion: 0.40
Nodes (4): ../../../domain/entities/product.dart, product, ProductCard, ../product_detail_screen.dart

### Community 67 - "MaterialPageRoute"
Cohesion: 0.50
Nodes (4): build, build, build, MaterialPageRoute

### Community 68 - "FeaturedProductSlider"
Cohesion: 0.50
Nodes (4): FeaturedProductSlider, _FeaturedProductSliderState, State, StatefulWidget

## Knowledge Gaps
- **550 isolated node(s):** `FileUploadService`, `_dio`, `_uploadUrl`, `uploadFile`, `withDiacritics` (+545 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Address` connect `address.dart` to `address_repository_impl.dart`, `checkout_providers.dart`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `AppUser` connect `home_screen_test.dart` to `app_user.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `FileUploadService`, `_dio`, `_uploadUrl` to the rest of the system?**
  _550 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `login_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.052597402597402594 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.05496828752642706 - nodes in this community are weakly interconnected._
- **Should `admin_home_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.049682875264270614 - nodes in this community are weakly interconnected._