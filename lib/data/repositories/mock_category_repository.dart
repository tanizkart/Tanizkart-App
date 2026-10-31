import '../models/category_model.dart';

class MockCategoryRepository {
  static final List<Category> _categories = [
    const Category(
      id: 'cat_baby_care',
      name: 'Baby care',
      emoji: '👶',
      badge: 'Gentle Care',
      iconUrl: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=400&q=80',
      subcategories: [
        'All',
        'Diapers & Wipes',
        'Baby Food & Formula',
        'Baby Bath & Skin',
        'Baby Feeding',
      ],
      itemCount: 42,
      backgroundColorValue: 0xFFFDF2F8, // Soft Blossom Pink
    ),
    const Category(
      id: 'cat_personal_care',
      name: 'Personal care',
      emoji: '🧴',
      badge: 'Self Care',
      iconUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=400&q=80',
      subcategories: [
        'All',
        'Bath & Body',
        'Hair Care',
        'Skin Care',
        'Oral Care',
        'Men\'s Grooming',
      ],
      itemCount: 50,
      backgroundColorValue: 0xFFF5F3FF, // Soft Lavender
    ),
    const Category(
      id: 'cat_groceries',
      name: 'Groceries',
      emoji: '🌾',
      badge: 'Kitchen Staples',
      iconUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=400&q=80',
      subcategories: [
        'All',
        'Atta & Flours',
        'Rice & Grains',
        'Dals & Pulses',
        'Oils & Ghee',
        'Masalas & Spices',
        'Instant & Noodles',
      ],
      itemCount: 68,
      backgroundColorValue: 0xFFFEF9C3, // Pale Gold
    ),
    const Category(
      id: 'cat_home_essentials',
      name: 'Home essentials',
      emoji: '🧼',
      badge: 'Sparkle Clean',
      iconUrl: 'https://images.unsplash.com/photo-1585421514738-01798e348b17?auto=format&fit=crop&w=400&q=80',
      subcategories: [
        'All',
        'Detergents & Laundry',
        'Surface Cleaners',
        'Dishwashing',
        'Tissues & Disposables',
        'Pooja Essentials',
      ],
      itemCount: 45,
      backgroundColorValue: 0xFFF1F5F9, // Fresh Slate
    ),
    const Category(
      id: 'cat_dairy',
      name: 'Dairy',
      emoji: '🥛',
      badge: 'Farm Fresh',
      iconUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
      subcategories: [
        'All',
        'Milk & Cream',
        'Farm Eggs',
        'Bread & Pav',
        'Butter & Ghee',
        'Curd & Paneer',
      ],
      itemCount: 56,
      backgroundColorValue: 0xFFEFF6FF, // Soft Ice Sky Blue
    ),
    const Category(
      id: 'cat_vegetables',
      name: 'Vegetables',
      emoji: '🥦',
      badge: 'Farm Direct',
      iconUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=400&q=80',
      subcategories: [
        'All',
        'Daily Vegetables',
        'Leafy Greens',
        'Root Vegetables',
        'Exotic & Salads',
        'Cooking Bases',
      ],
      itemCount: 60,
      backgroundColorValue: 0xFFECFDF5, // Emerald Mist
    ),
  ];

  static List<Category> getAllCategories() => List.unmodifiable(_categories);

  static Category getCategoryById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    // Graceful aliases for legacy IDs
    if (id == 'cat_produce') return getCategoryById('cat_vegetables');
    if (id == 'cat_care') return getCategoryById('cat_personal_care');
    if (id == 'cat_cleaning') return getCategoryById('cat_home_essentials');
    if (id == 'cat_staples' ||
        id == 'cat_snacks' ||
        id == 'cat_drinks' ||
        id == 'cat_instant' ||
        id == 'cat_sweets' ||
        id == 'cat_tea_coffee') {
      return getCategoryById('cat_groceries');
    }
    return _categories.first;
  }
}
