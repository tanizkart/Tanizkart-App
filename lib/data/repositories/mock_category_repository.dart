import '../models/category_model.dart';

class MockCategoryRepository {
  static final List<Category> _categories = [
    const Category(
      id: 'cat_dairy',
      name: 'Dairy, Bread & Eggs',
      iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_zg4idKN0gPq7Y-fgt7Fm7q3gNPNGlqNyIT7tLWnymMb5R67f1SavN5tf7Y3_Ow-Rqb-YyNz7t-Ez2gjLG7hNflWrNfnBQ5oIqzofkPGlW2N144GE2PlrkUi0fzd2sDemqJ_ZW3dm1SC5yW4W2xYCLSWoYSB6JDIQ-tmZiE3uH-7bl5Zo1hU3UEYwn_pifSWOXJz7dvVB1xeRF5XvnC6x9rcx1Va2JxEJzzEKp5vvODf10b3PAwZzMd2uxrRUSN-gMR57nnswuiA',
      subcategories: ['All', 'Milk & Curd', 'Farm Eggs', 'Bread & Pav', 'Butter & Ghee', 'Cheese & Paneer'],
      itemCount: 24,
      backgroundColorValue: 0xFFFEF3C7, // Warm Amber
    ),
    const Category(
      id: 'cat_produce',
      name: 'Fresh Fruits & Veggies',
      iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDoWVh64aiH6LnZNNtIkagQmHpT68RdceKHVcJKN0cqfQTJuObUvJwcSu-fTVWdS7p58ht9cV_xOWJ2QrC8X8nRh1n9Ohul9AhXHlIe__wpdLjbdzjSAPtxXmnCATiSitNDEIZNdq9jmj0SaK8z2ClReXee_v5287iZj_usAxDaGEbghFsFpN2tYbBihJRMlcfkJ96ZQAUmbXYnOenNy4kkdLQ2tf7q_gSUwffCAC3Zo5V-UaijLsbFQqY2z4oSkBeKYVdB6Fwkc-M',
      subcategories: ['All', 'Fresh Vegetables', 'Daily Fruits', 'Organic Herbs', 'Cut & Sprouts'],
      itemCount: 38,
      backgroundColorValue: 0xFFD1FAE5, // Fresh Emerald
    ),
    const Category(
      id: 'cat_snacks',
      name: 'Snacks & Munchies',
      iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAzT24iqkZd6yJlU5I9gM_Ct1CAjs8TIS4FiigbJTp-nsFxZ5VrabIFE48HKRZhDywu5i4Ll-U4fTjr51OkDXItn-tCWk8S7d74I_l55QaFGkHVU4thdnoAWclpZl45BljMEnU6G4-ZO0DMxjTQw4kKPgIZ8RSWYGWksEpBesm-rRjDHevlX5rP_lqg4X02gmZVgDueWIIy7fKePi191waIiteGiqaTEV2ZG49Uyx7HZWwqlu8rp4xH4gJ-Y15N29IwGtbHlihQEKU',
      subcategories: ['All', 'Chips & Crisps', 'Bhujia & Namkeen', 'Biscuits & Cookies', 'Chocolates'],
      itemCount: 45,
      backgroundColorValue: 0xFFFFEDD5, // Warm Orange
    ),
    const Category(
      id: 'cat_drinks',
      name: 'Cold Drinks & Juices',
      iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtb7hY35pcn7OcLcSgnzV1VL_itQwYY8h4qNEoDW1nhEH0Iy4Mh7jZQG83bTCaHyjiBnBWDITqtyh_qwfi6uQjuw2k5zvnmnbFLFRxgsiGDFwIX5_J8KkuGj6jXUE7-C9GuvXYg-d4HjcNwcDriWyLLeBGk1B1_Dl8yJfqmYjt3dMxbaTweMbdsL0kvr07bSMtdqrL22H1Urg2hA0c20SA7a7nu0MYFY0r-I3AdzFyLSZsvLIRmhdNYHWdhI7Majx6YvTklDySehA',
      subcategories: ['All', 'Soft Drinks', 'Real Fruit Juices', 'Energy Drinks', 'Mineral Water'],
      itemCount: 30,
      backgroundColorValue: 0xFFE0E7FF, // Soft Indigo
    ),
    const Category(
      id: 'cat_staples',
      name: 'Atta, Rice & Dals',
      iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_zg4idKN0gPq7Y-fgt7Fm7q3gNPNGlqNyIT7tLWnymMb5R67f1SavN5tf7Y3_Ow-Rqb-YyNz7t-Ez2gjLG7hNflWrNfnBQ5oIqzofkPGlW2N144GE2PlrkUi0fzd2sDemqJ_ZW3dm1SC5yW4W2xYCLSWoYSB6JDIQ-tmZiE3uH-7bl5Zo1hU3UEYwn_pifSWOXJz7dvVB1xeRF5XvnC6x9rcx1Va2JxEJzzEKp5vvODf10b3PAwZzMd2uxrRUSN-gMR57nnswuiA',
      subcategories: ['All', 'Wheat Atta', 'Basmati Rice', 'Toor & Moong Dal', 'Cooking Oils', 'Spices'],
      itemCount: 52,
      backgroundColorValue: 0xFFFEF9C3, // Pale Yellow
    ),
    const Category(
      id: 'cat_instant',
      name: 'Instant & Frozen',
      iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDoWVh64aiH6LnZNNtIkagQmHpT68RdceKHVcJKN0cqfQTJuObUvJwcSu-fTVWdS7p58ht9cV_xOWJ2QrC8X8nRh1n9Ohul9AhXHlIe__wpdLjbdzjSAPtxXmnCATiSitNDEIZNdq9jmj0SaK8z2ClReXee_v5287iZj_usAxDaGEbghFsFpN2tYbBihJRMlcfkJ96ZQAUmbXYnOenNy4kkdLQ2tf7q_gSUwffCAC3Zo5V-UaijLsbFQqY2z4oSkBeKYVdB6Fwkc-M',
      subcategories: ['All', 'Noodles & Pasta', 'Ready to Cook', 'Frozen Peas & Snacks', 'Ice Creams'],
      itemCount: 28,
      backgroundColorValue: 0xFFCFFAFE, // Cyan
    ),
    const Category(
      id: 'cat_cleaning',
      name: 'Cleaning & Household',
      iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAzT24iqkZd6yJlU5I9gM_Ct1CAjs8TIS4FiigbJTp-nsFxZ5VrabIFE48HKRZhDywu5i4Ll-U4fTjr51OkDXItn-tCWk8S7d74I_l55QaFGkHVU4thdnoAWclpZl45BljMEnU6G4-ZO0DMxjTQw4kKPgIZ8RSWYGWksEpBesm-rRjDHevlX5rP_lqg4X02gmZVgDueWIIy7fKePi191waIiteGiqaTEV2ZG49Uyx7HZWwqlu8rp4xH4gJ-Y15N29IwGtbHlihQEKU',
      subcategories: ['All', 'Detergents & Bars', 'Floor Cleaners', 'Pooja Essentials', 'Tissues'],
      itemCount: 34,
      backgroundColorValue: 0xFFF1F5F9, // Slate
    ),
    const Category(
      id: 'cat_care',
      name: 'Personal Care',
      iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtb7hY35pcn7OcLcSgnzV1VL_itQwYY8h4qNEoDW1nhEH0Iy4Mh7jZQG83bTCaHyjiBnBWDITqtyh_qwfi6uQjuw2k5zvnmnbFLFRxgsiGDFwIX5_J8KkuGj6jXUE7-C9GuvXYg-d4HjcNwcDriWyLLeBGk1B1_Dl8yJfqmYjt3dMxbaTweMbdsL0kvr07bSMtdqrL22H1Urg2hA0c20SA7a7nu0MYFY0r-I3AdzFyLSZsvLIRmhdNYHWdhI7Majx6YvTklDySehA',
      subcategories: ['All', 'Bath & Soaps', 'Hair Care', 'Oral Hygiene', 'Skincare'],
      itemCount: 40,
      backgroundColorValue: 0xFFFCE7F3, // Soft Pink
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
