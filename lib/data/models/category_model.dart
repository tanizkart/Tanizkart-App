class Category {
  final String id;
  final String name;
  final String iconUrl;
  final List<String> subcategories;
  final int itemCount;
  final int backgroundColorValue;
  final String? emoji;
  final String? badge;

  const Category({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.subcategories,
    required this.itemCount,
    this.backgroundColorValue = 0xFFFFFBEB, // default amber tint
    this.emoji,
    this.badge,
  });
}

