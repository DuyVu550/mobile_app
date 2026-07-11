class Toy {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  // Thuộc tính phân loại (dùng cho Detail + lọc sub-category).
  final String brand;
  final String ageGroup;
  final String gender;
  final String color;

  const Toy({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.brand = '',
    this.ageGroup = '',
    this.gender = '',
    this.color = '',
  });
}
