class Product {
  final String id;
  final String name;
  final String brand;
  final String packSize;
  final double price;
  final double originalPrice;
  final int discountPercent;
  final String imageUrl;
  final String categoryId;
  final String subcategory;
  final int deliveryTimeMins;
  final double rating;
  final int ratingCount;
  final String description;
  final Map<String, String> nutritionalInfo;
  final List<String> highlights;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.packSize,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    required this.imageUrl,
    required this.categoryId,
    required this.subcategory,
    this.deliveryTimeMins = 10,
    this.rating = 4.8,
    this.ratingCount = 840,
    this.description = '',
    this.nutritionalInfo = const {},
    this.highlights = const [],
  });

  double get savings => originalPrice - price;
}
