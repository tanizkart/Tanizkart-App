import '../models/category_model.dart';

class MockCategoryRepository {
  static final List<Category> _categories = [
    const Category(
      id: 'cat_dairy',
      name: 'Dairy, Bread & Eggs',
      emoji: '🥛',
      badge: 'Daily',
      iconUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Milk & Curd', 'Farm Eggs', 'Bread & Pav', 'Butter & Ghee', 'Cheese & Paneer'],
      itemCount: 48,
      backgroundColorValue: 0xFFEFF6FF, // Soft Ice Blue
    ),
    const Category(
      id: 'cat_produce',
      name: 'Fruits & Vegetables',
      emoji: '🥦',
      badge: 'Farm Direct',
      iconUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Fresh Vegetables', 'Daily Fruits', 'Organic Herbs', 'Exotics & Cut'],
      itemCount: 64,
      backgroundColorValue: 0xFFECFDF5, // Emerald Mist
    ),
    const Category(
      id: 'cat_snacks',
      name: 'Munchies & Chips',
      emoji: '🍿',
      badge: 'Party',
      iconUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Chips & Crisps', 'Bhujia & Namkeen', 'Biscuits & Cookies', 'Popcorn'],
      itemCount: 52,
      backgroundColorValue: 0xFFFFF7ED, // Warm Orange
    ),
    const Category(
      id: 'cat_drinks',
      name: 'Cold Drinks & Juices',
      emoji: '🥤',
      badge: 'Chilled',
      iconUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Soft Drinks', 'Real Fruit Juices', 'Energy Drinks', 'Mineral Water'],
      itemCount: 36,
      backgroundColorValue: 0xFFF0FDF4, // Mint Soda
    ),
    const Category(
      id: 'cat_instant',
      name: 'Instant & Frozen',
      emoji: '🍜',
      badge: 'Ready in 2m',
      iconUrl: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Maggi & Noodles', 'Pasta & Sauces', 'Frozen Snacks & Peas', 'Ready Meals'],
      itemCount: 42,
      backgroundColorValue: 0xFFFEF3C7, // Warm Amber
    ),
    const Category(
      id: 'cat_staples',
      name: 'Atta, Rice & Dals',
      emoji: '🌾',
      badge: 'Wholesale',
      iconUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Wheat Atta', 'Basmati Rice', 'Toor & Moong Dal', 'Cooking Oils', 'Spices & Salt'],
      itemCount: 78,
      backgroundColorValue: 0xFFFEF9C3, // Pale Gold
    ),
    const Category(
      id: 'cat_sweets',
      name: 'Chocolates & Sweets',
      emoji: '🍫',
      badge: 'Sweet Tooth',
      iconUrl: 'https://images.unsplash.com/photo-1549007994-cb92caebd54b?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Chocolates', 'Ice Creams', 'Traditional Mithai', 'Dessert Syrups'],
      itemCount: 30,
      backgroundColorValue: 0xFFFCE7F3, // Soft Pink
    ),
    const Category(
      id: 'cat_tea_coffee',
      name: 'Tea, Coffee & More',
      emoji: '☕',
      badge: 'Morning',
      iconUrl: 'https://images.unsplash.com/photo-1559561853-08451507cbe7?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Leaf Tea', 'Instant Coffee', 'Green Tea', 'Health Drinks'],
      itemCount: 28,
      backgroundColorValue: 0xFFF5F3FF, // Lavender
    ),
    const Category(
      id: 'cat_cleaning',
      name: 'Cleaning & Home',
      emoji: '🧼',
      badge: 'Essential',
      iconUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Detergents & Powders', 'Floor Cleaners', 'Dishwashers', 'Tissues & Wipes'],
      itemCount: 45,
      backgroundColorValue: 0xFFF1F5F9, // Slate White
    ),
    const Category(
      id: 'cat_care',
      name: 'Personal Care',
      emoji: '🧴',
      badge: 'Self Care',
      iconUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=400&q=80',
      subcategories: ['All', 'Soaps & Body Wash', 'Hair Care', 'Oral Care & Toothpaste', 'Skincare'],
      itemCount: 50,
      backgroundColorValue: 0xFFFDF4FF, // Soft Violet
    ),
  ];

  static List<Category> getAllCategories() => List.unmodifiable(_categories);

  static Category getCategoryById(String id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => _categories.first,
    );
  }
}
