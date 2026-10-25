import '../models/product_model.dart';

class MockProductRepository {
  static final List<Product> _products = [
    Product(
      id: 'prod_1',
      name: 'Amul Taaza Homogenised Toned Milk',
      brand: 'AMUL',
      packSize: '500 ml',
      price: 28.0,
      originalPrice: 32.0,
      discountPercent: 12,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtb7hY35pcn7OcLcSgnzV1VL_itQwYY8h4qNEoDW1nhEH0Iy4Mh7jZQG83bTCaHyjiBnBWDITqtyh_qwfi6uQjuw2k5zvnmnbFLFRxgsiGDFwIX5_J8KkuGj6jXUE7-C9GuvXYg-d4HjcNwcDriWyLLeBGk1B1_Dl8yJfqmYjt3dMxbaTweMbdsL0kvr07bSMtdqrL22H1Urg2hA0c20SA7a7nu0MYFY0r-I3AdzFyLSZsvLIRmhdNYHWdhI7Majx6YvTklDySehA',
      categoryId: 'cat_dairy',
      subcategory: 'Milk & Curd',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 1420,
      description: 'Fresh toned milk homogenised for uniform taste and thickness. Processed with ultra-high temperature technology to preserve nutrients and freshness. Direct from local dairy warehouse.',
      nutritionalInfo: {
        'Energy': '58 kcal',
        'Protein': '3.0 g',
        'Carbohydrate': '4.7 g',
        'Calcium': '120 mg',
      },
      highlights: [
        'Homogenised & Pasteurised',
        'Direct from Tanizkart Dark Store',
        'Strict Cold-Chain Assurance at 4°C',
        'Guaranteed Fresh Stock'
      ],
    ),
    Product(
      id: 'prod_2',
      name: 'Country Fresh Brown Farm Eggs',
      brand: 'EGG HUB',
      packSize: '6 pcs Pack',
      price: 58.0,
      originalPrice: 75.0,
      discountPercent: 23,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAU9YiVdYAbKY0nJ8HqVfs8-nF7qU6qsCGCGrLhx0Ri2qZwVDzw29O9Yp4i1SCGJP5tXNTcvNrWecoS902HdBHbc9IInME1S0VbbdX4UlZ0MAg-D6jhLsJ4PEGqdpskUrfVhXN42Q76Fwh3OrS1jWXiV3i9yzUI0VDgOnCqZgo4EvKSlyKGDoi5voPXFpEDWxGZcw67WTUD6vYoCsY-Ixc6JNbDUfBHmrIkohERLDBioMEfOTCbNtKnCBbENEyHApYGyl-tXILNU94',
      categoryId: 'cat_dairy',
      subcategory: 'Farm Eggs',
      deliveryTimeMins: 10,
      rating: 4.7,
      ratingCount: 890,
      description: 'Grain-fed country brown eggs rich in Omega-3 and natural protein. Inspected and securely packed in protective pulp cartons for zero crack delivery.',
      nutritionalInfo: {
        'Protein': '6.3 g per egg',
        'Cholesterol': '186 mg',
        'Vitamin D': '1.1 mcg',
        'Iron': '0.9 mg',
      },
      highlights: [
        '100% Naturally Laid',
        'Zero Hormone & Antibiotic Free',
        'Quality-Inspected Pack of 6',
      ],
    ),
    Product(
      id: 'prod_3',
      name: 'Britannia 100% Whole Wheat Bread',
      brand: 'BRITANNIA',
      packSize: '400 g Loaf',
      price: 45.0,
      originalPrice: 50.0,
      discountPercent: 10,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_zg4idKN0gPq7Y-fgt7Fm7q3gNPNGlqNyIT7tLWnymMb5R67f1SavN5tf7Y3_Ow-Rqb-YyNz7t-Ez2gjLG7hNflWrNfnBQ5oIqzofkPGlW2N144GE2PlrkUi0fzd2sDemqJ_ZW3dm1SC5yW4W2xYCLSWoYSB6JDIQ-tmZiE3uH-7bl5Zo1hU3UEYwn_pifSWOXJz7dvVB1xeRF5XvnC6x9rcx1Va2JxEJzzEKp5vvODf10b3PAwZzMd2uxrRUSN-gMR57nnswuiA',
      categoryId: 'cat_dairy',
      subcategory: 'Bread & Pav',
      deliveryTimeMins: 10,
      rating: 4.6,
      ratingCount: 650,
      description: 'Soft and wholesome bread baked with 100% whole wheat flour. Zero added maida, rich in dietary fiber for a healthy daily breakfast.',
      nutritionalInfo: {
        'Energy': '245 kcal',
        'Dietary Fiber': '6.8 g',
        'Protein': '8.5 g',
      },
      highlights: [
        '100% Whole Wheat Flour',
        'Zero Maida & Zero Palm Oil',
        'Baked Fresh Every Morning',
      ],
    ),
    Product(
      id: 'prod_4',
      name: 'Fortune Sunlite Refined Sunflower Oil',
      brand: 'FORTUNE',
      packSize: '1 Litre Pouch',
      price: 145.0,
      originalPrice: 175.0,
      discountPercent: 17,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAMsF8D-Q3y_3N-Z0g6V8u3E04nNfnBQ5oIqzofkPGlW2N144GE2PlrkUi0fzd2sDemqJ_ZW3dm1SC5yW4W2xYCLSWoYSB6JDIQ-tmZiE3uH-7bl5Zo1hU3UEYwn_pifSWOXJz7dvVB1xeRF5XvnC6x9rcx1Va2JxEJzzEKp5vvODf10b3PAwZzMd2uxrRUSN-gMR57nnswuiA',
      categoryId: 'cat_staples',
      subcategory: 'Cooking Oils',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 2150,
      description: 'Light and non-greasy refined sunflower oil enriched with Vitamin A and Vitamin D. Ideal for daily cooking, deep frying, and sauteing.',
      nutritionalInfo: {
        'Fat': '100 g',
        'Vitamin A': '750 mcg',
        'Vitamin D': '11.25 mcg',
      },
      highlights: [
        'High Smoke Point',
        'Fortified with Vitamins A & D',
        'Triple Refined Purity',
      ],
    ),
    Product(
      id: 'prod_5',
      name: 'Nandini Pure Cow Ghee',
      brand: 'NANDINI',
      packSize: '500 ml Jar',
      price: 320.0,
      originalPrice: 360.0,
      discountPercent: 11,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtb7hY35pcn7OcLcSgnzV1VL_itQwYY8h4qNEoDW1nhEH0Iy4Mh7jZQG83bTCaHyjiBnBWDITqtyh_qwfi6uQjuw2k5zvnmnbFLFRxgsiGDFwIX5_J8KkuGj6jXUE7-C9GuvXYg-d4HjcNwcDriWyLLeBGk1B1_Dl8yJfqmYjt3dMxbaTweMbdsL0kvr07bSMtdqrL22H1Urg2hA0c20SA7a7nu0MYFY0r-I3AdzFyLSZsvLIRmhdNYHWdhI7Majx6YvTklDySehA',
      categoryId: 'cat_dairy',
      subcategory: 'Butter & Ghee',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 3200,
      description: 'Traditional aroma and golden granular texture crafted from pure fresh cow milk. Adds rich flavor and nutrition to daily rotis, dals, and sweets.',
      nutritionalInfo: {
        'Energy': '897 kcal',
        'Milk Fat': '99.7 g',
      },
      highlights: [
        'Granular Danedar Texture',
        'Rich Authentic Aroma',
        'Agmark Special Grade',
      ],
    ),
    Product(
      id: 'prod_6',
      name: 'Epigamia Greek Yogurt Wild Blueberry',
      brand: 'EPIGAMIA',
      packSize: '100 g Cup',
      price: 48.0,
      originalPrice: 55.0,
      discountPercent: 13,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_zg4idKN0gPq7Y-fgt7Fm7q3gNPNGlqNyIT7tLWnymMb5R67f1SavN5tf7Y3_Ow-Rqb-YyNz7t-Ez2gjLG7hNflWrNfnBQ5oIqzofkPGlW2N144GE2PlrkUi0fzd2sDemqJ_ZW3dm1SC5yW4W2xYCLSWoYSB6JDIQ-tmZiE3uH-7bl5Zo1hU3UEYwn_pifSWOXJz7dvVB1xeRF5XvnC6x9rcx1Va2JxEJzzEKp5vvODf10b3PAwZzMd2uxrRUSN-gMR57nnswuiA',
      categoryId: 'cat_dairy',
      subcategory: 'Milk & Curd',
      deliveryTimeMins: 10,
      rating: 4.7,
      ratingCount: 520,
      description: 'Thick, creamy Greek yogurt loaded with real blueberry chunks. High in protein, low in fat, with live probiotics for gut wellness.',
      nutritionalInfo: {
        'Protein': '6.0 g',
        'Energy': '96 kcal',
      },
      highlights: [
        'Real Blueberry Compote',
        '2x Protein vs Regular Dahi',
        'Probiotic Gut Health',
      ],
    ),
  ];

  static List<Product> getAllProducts() => List.unmodifiable(_products);

  static Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Product> getProductsByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  static List<Product> getBestsellers() {
    return _products.take(4).toList();
  }

  static List<Product> sortProducts(List<Product> products, ProductSortOption sortOption) {
    final list = List<Product>.from(products);
    switch (sortOption) {
      case ProductSortOption.popular:
        list.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
        break;
      case ProductSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.discount:
        list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case ProductSortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }
}

enum ProductSortOption {
  popular('Popularity'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  discount('Highest Discount'),
  rating('Customer Rating');

  final String label;
  const ProductSortOption(this.label);
}
