# Design Specification: Featured Product Image Slideshow (Slide Image)
**Date:** 2026-07-12
**Topic:** Featured Product Slider with Auto-Scrolling PageView and Navigation to Detail Page

---

## 1. Goal
Implement a featured product image slideshow ("Tính năng Slide Image") at the top of the main catalog view on the `HomeScreen`. The slides will display products flagged as `isFeatured` from Firestore, automatically cycle every 3 seconds, and navigate the user to a `ProductDetailScreen` when clicked.

---

## 2. Requirements & UX Flow
* **Data Fields**: Products will contain a boolean `isFeatured` attribute.
* **Component Location**: Below the search bar and above the grid of products on the `HomeScreen`.
* **Component Behavior**:
  * Display a full-width horizontally scrolling list of cards showing the product image.
  * At the bottom of each slide, overlay the product's name and price using a semi-transparent dark gradient background.
  * Auto-scroll/flip to the next slide every 3 seconds.
  * Wrap around infinitely: when reaching the last featured product, transition back to the first.
  * Display animated indicator dots at the bottom to represent the active page.
  * Tapping a slide navigates the user to `ProductDetailScreen`.
  * If no products are marked as `isFeatured`, the slider should not occupy any layout space (zero height).

---

## 3. Proposed Changes

### A. Domain Layer

#### 1. [MODIFY] [product.dart](file:///d:/toy_app/lib/features/products/domain/entities/product.dart)
Add the `isFeatured` boolean flag:
```dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isFeatured; // New field

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isFeatured,
  });
}
```

---

### B. Data Layer

#### 1. [MODIFY] [product_model.dart](file:///d:/toy_app/lib/features/products/data/models/product_model.dart)
Update the freezed annotation model to include the `isFeatured` field and Firestore mapping:
```dart
@freezed
class ProductModel with _$ProductModel implements Product {
  const factory ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
    required bool isFeatured, // New field
  }) = _ProductModel;

  const ProductModel._();
  
  // ... fromJson and toJson ...

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      price: ((data['price'] ?? 0) as num).toDouble(),
      imageUrl: (data['imageUrl'] ?? '') as String,
      category: (data['category'] ?? '') as String,
      isFeatured: (data['isFeatured'] ?? false) as bool, // New mapping
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      isFeatured: isFeatured,
    );
  }
}
```

---

### C. Presentation Layer

#### 1. [NEW] [product_detail_screen.dart](file:///d:/toy_app/lib/features/products/presentation/views/product_detail_screen.dart)
Create a new product detail screen displaying a large image, formatted price, category, and description:
```dart
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 80, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${product.price.toStringAsFixed(0)}đ', // Or formatted price
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    'Mô tả sản phẩm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 2. [NEW] [featured_product_slider.dart](file:///d:/toy_app/lib/features/products/presentation/views/widgets/featured_product_slider.dart)
Create the slideshow component using a custom `PageView` controller and a `Timer` loop:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../product_detail_screen.dart';

class FeaturedProductSlider extends StatefulWidget {
  final List<Product> products;
  const FeaturedProductSlider({super.key, required this.products});

  @override
  State<FeaturedProductSlider> createState() => _FeaturedProductSliderState();
}

class _FeaturedProductSliderState extends State<FeaturedProductSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || widget.products.isEmpty) return;
      
      final nextPage = (_currentPage + 1) % widget.products.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                        // Dark bottom gradient overlay
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black87],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${product.price.toStringAsFixed(0)}đ', // Or formatted price
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.products.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              height: 8,
              width: _currentPage == index ? 16 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blue : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

#### 3. [MODIFY] [home_screen.dart](file:///d:/toy_app/lib/features/home/presentation/views/home_screen.dart)
Integrate the slideshow component:
```dart
  // Inside HomeScreen State build method:
  final productsState = ref.watch(filteredProductsProvider);
  
  // Extract and build top slider
  Widget _buildSlider(List<Product> allProducts) {
    final featured = allProducts.where((p) => p.isFeatured).toList();
    return FeaturedProductSlider(products: featured);
  }
  
  // Add _buildSlider inside the Column above products list
```

---

## 4. Verification Plan

### Automated Tests
* **Model Serialization Tests**: Verify `isFeatured` parses correctly from JSON and Firestore map.
* **Featured Slider Tests**: Verify that only products with `isFeatured: true` are supplied to the slider widget.
* **Timer Auto-Scroll Tests**: Verify page transitions trigger on a timer loop.

### Manual Verification
* Upload mock products in Firestore with `isFeatured: true` and verify they populate the slider correctly.
* Verify auto-scroll every 3 seconds works and wraps around at the end.
* Verify clicking a slide redirects to the detail page.
