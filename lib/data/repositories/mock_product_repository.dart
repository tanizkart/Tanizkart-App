import '../models/product_model.dart';

class MockProductRepository {
  static final List<Product> _products = [
    // -------------------------------------------------------------------------
    // 1. Dairy, Bread & Breakfast
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_amul_butter',
      name: 'Amul Salted Butter (Pasteurised)',
      brand: 'AMUL',
      packSize: '100 g Pack',
      price: 58.0,
      originalPrice: 60.0,
      discountPercent: 3,
      imageUrl: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_dairy',
      subcategory: 'Butter & Ghee',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 8420,
      description: 'The golden classic butter from Amul. Made from pure fresh milk cream, lightly salted, and perfect for hot parathas, toast, and baking.',
      nutritionalInfo: {
        'Energy': '722 kcal',
        'Total Fat': '80 g',
        'Saturated Fat': '51 g',
        'Sodium': '800 mg',
      },
      highlights: [
        '100% Pure Milk Cream',
        'Iconic Taste Since 1956',
        'Cold Chain Stored at 4°C',
        '10-Minute Dark Store Dispatch',
      ],
    ),
    Product(
      id: 'prod_amul_gold',
      name: 'Amul Gold Full Cream Fresh Milk',
      brand: 'AMUL',
      packSize: '500 ml Pouch',
      price: 34.0,
      originalPrice: 35.0,
      discountPercent: 3,
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_dairy',
      subcategory: 'Milk & Curd',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 12500,
      description: 'Rich full cream pasteurised milk with 6% fat and 9% SNF. Excellent for making thick curd, tea, creamy kheer, and daily family consumption.',
      nutritionalInfo: {
        'Energy': '87 kcal',
        'Milk Fat': '6.0 g',
        'Protein': '3.2 g',
        'Calcium': '150 mg',
      },
      highlights: [
        '6.0% Rich Milk Fat',
        'Pasteurised & Homogenised',
        'Direct from Local Dairy Plant',
      ],
    ),
    Product(
      id: 'prod_farm_eggs',
      name: 'Country Fresh Brown Farm Eggs',
      brand: 'EGG HUB',
      packSize: '6 pcs Pack',
      price: 54.0,
      originalPrice: 70.0,
      discountPercent: 23,
      imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_dairy',
      subcategory: 'Farm Eggs',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 3120,
      description: 'Farm-fresh country brown eggs rich in Omega-3 and natural high-bioavailable protein. Cleaned, graded, and packed in shock-proof pulp cartons.',
      nutritionalInfo: {
        'Protein': '6.3 g per egg',
        'Cholesterol': '186 mg',
        'Vitamin D': '1.1 mcg',
        'Iron': '0.9 mg',
      },
      highlights: [
        '100% Naturally Laid',
        'Antibiotic & Hormone Free',
        'Zero-Crack Guarantee',
      ],
    ),
    Product(
      id: 'prod_britannia_bread',
      name: 'Britannia 100% Whole Wheat Bread',
      brand: 'BRITANNIA',
      packSize: '400 g Loaf',
      price: 45.0,
      originalPrice: 50.0,
      discountPercent: 10,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_dairy',
      subcategory: 'Bread & Pav',
      deliveryTimeMins: 10,
      rating: 4.7,
      ratingCount: 2150,
      description: 'Healthy and wholesome bread baked with 100% whole wheat atta. Zero added maida and zero trans-fat for nutritious morning breakfasts.',
      nutritionalInfo: {
        'Energy': '245 kcal',
        'Dietary Fiber': '6.8 g',
        'Protein': '8.5 g',
      },
      highlights: [
        'Zero Added Maida',
        'High in Whole Wheat Fiber',
        'Freshly Baked Batch',
      ],
    ),
    Product(
      id: 'prod_nandini_ghee',
      name: 'Nandini Pure Cow Ghee',
      brand: 'NANDINI',
      packSize: '500 ml Jar',
      price: 320.0,
      originalPrice: 360.0,
      discountPercent: 11,
      imageUrl: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=500&q=80',
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
      id: 'prod_epigamia_yogurt',
      name: 'Epigamia Greek Yogurt Wild Blueberry',
      brand: 'EPIGAMIA',
      packSize: '100 g Cup',
      price: 48.0,
      originalPrice: 55.0,
      discountPercent: 13,
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_dairy',
      subcategory: 'Milk & Curd',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 890,
      description: 'Thick, creamy strained Greek yogurt layered with real sweet blueberries. Loaded with probiotics and 2x protein compared to regular curd.',
      nutritionalInfo: {
        'Protein': '6.0 g',
        'Energy': '96 kcal',
      },
      highlights: [
        'Real Blueberries',
        '2x Protein vs Dahi',
        'Live Probiotic Cultures',
      ],
    ),

    // -------------------------------------------------------------------------
    // 2. Fresh Fruits & Vegetables (Farm Direct)
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_onion',
      name: 'Fresh Red Onion (Pyaz)',
      brand: 'FARM FRESH',
      packSize: '1 kg Net',
      price: 36.0,
      originalPrice: 50.0,
      discountPercent: 28,
      imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_produce',
      subcategory: 'Fresh Vegetables',
      deliveryTimeMins: 10,
      rating: 4.7,
      ratingCount: 6540,
      description: 'Firm and pungently aromatic red onions directly sourced from verified Andhra farms. Hand-sorted for premium size and minimal waste.',
      nutritionalInfo: {
        'Calories': '40 kcal',
        'Carbs': '9.3 g',
        'Fiber': '1.7 g',
      },
      highlights: [
        'Farm-Direct Quality',
        'Hand-Graded Bulbs',
        'Clean & Dry Outer Skin',
      ],
    ),
    Product(
      id: 'prod_tomato',
      name: 'Fresh Hybrid Vine Tomatoes (Tamatar)',
      brand: 'FARM FRESH',
      packSize: '1 kg Net',
      price: 28.0,
      originalPrice: 40.0,
      discountPercent: 30,
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_produce',
      subcategory: 'Fresh Vegetables',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 4210,
      description: 'Juicy, plump, firm red hybrid tomatoes picked at peak maturity. Ideal for gravies, sambar, salads, and everyday cooking.',
      nutritionalInfo: {
        'Vitamin C': '28% DV',
        'Lycopene': 'Rich Antioxidant',
        'Calories': '18 kcal',
      },
      highlights: [
        'Naturally Vine-Ripened',
        'Firm Flesh for Cooking',
        'Washed & Cleaned Pack',
      ],
    ),
    Product(
      id: 'prod_alphonso_mango',
      name: 'Alphonso Mango (Hapus) - Farm Direct',
      brand: 'ORCHARD SELECT',
      packSize: '1 kg Box (3-4 pcs)',
      price: 280.0,
      originalPrice: 350.0,
      discountPercent: 20,
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_produce',
      subcategory: 'Daily Fruits',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 1850,
      description: 'Naturally carbide-free ripened king of fruits with sublime sweetness and golden saffron pulp. Tree-harvested from coastal orchards.',
      nutritionalInfo: {
        'Vitamin A': '25% DV',
        'Sugars': '14 g',
        'Calories': '60 kcal',
      },
      highlights: [
        '100% Carbide Free',
        'Intense Fragrance & Sweetness',
        'Protective Foam Padded Box',
      ],
    ),
    Product(
      id: 'prod_apple',
      name: 'Shimla Royal Delicious Red Apples',
      brand: 'FARM FRESH',
      packSize: '500 g (4 pcs)',
      price: 95.0,
      originalPrice: 120.0,
      discountPercent: 21,
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_produce',
      subcategory: 'Daily Fruits',
      deliveryTimeMins: 10,
      rating: 4.6,
      ratingCount: 1420,
      description: 'Crisp, sweet, and juicy handpicked Himachal apples with radiant red blush. Wax-free and washed for immediate snacking.',
      nutritionalInfo: {
        'Dietary Fiber': '4.4 g',
        'Calories': '95 kcal',
      },
      highlights: [
        'Zero Wax Coating',
        'Crisp & Juicy Texture',
        'Himachal Orchard Harvest',
      ],
    ),
    Product(
      id: 'prod_coconut',
      name: 'Fresh Sweet Tender Coconut (Water Included)',
      brand: 'COCO FRESH',
      packSize: '1 pc (250-300 ml)',
      price: 52.0,
      originalPrice: 65.0,
      discountPercent: 20,
      imageUrl: 'https://images.unsplash.com/photo-1544378730-8b5104b18790?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_produce',
      subcategory: 'Daily Fruits',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 5200,
      description: 'Natural isotonic electrolyte water directly from fresh green coconuts. Sweet, cooling, and trimmed for easy sipping at home.',
      nutritionalInfo: {
        'Potassium': '600 mg',
        'Hydration': '100% Natural',
      },
      highlights: [
        'Natural Electrolytes',
        'Sweet Refreshing Water',
        'Pre-Trimmed Ready to Cut',
      ],
    ),

    // -------------------------------------------------------------------------
    // 3. Instant Food, Munchies & Chips
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_maggi',
      name: 'Maggi 2-Minute Masala Instant Noodles',
      brand: 'MAGGI',
      packSize: '70 g Pack',
      price: 14.0,
      originalPrice: 15.0,
      discountPercent: 7,
      imageUrl: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_instant',
      subcategory: 'Maggi & Noodles',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 15400,
      description: 'India’s favorite instant noodles infused with the secret blend of 10 roasted spices. Fortified with iron for quick savory comfort.',
      nutritionalInfo: {
        'Iron': '18% RDA',
        'Energy': '312 kcal',
        'Protein': '7.0 g',
      },
      highlights: [
        'Authentic Masala Taste Maker',
        'Cooks in Just 2 Minutes',
        'Fortified with Iron',
      ],
    ),
    Product(
      id: 'prod_lays_masala',
      name: "Lay's India's Magic Masala Potato Chips",
      brand: "LAY'S",
      packSize: '50 g Pouch',
      price: 20.0,
      originalPrice: 20.0,
      discountPercent: 0,
      imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_snacks',
      subcategory: 'Chips & Crisps',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 9400,
      description: 'Finely sliced crisp farm potatoes dusted with hot and tangy Indian spices like coriander, cumin, dry mango, and chilli powder.',
      nutritionalInfo: {
        'Energy': '270 kcal',
        'Fat': '16.5 g',
        'Carbohydrates': '26 g',
      },
      highlights: [
        'Crispy Thin Cut Potatoes',
        'Iconic Blue Masala Flavor',
        'Perfect Tea-Time Crunch',
      ],
    ),
    Product(
      id: 'prod_kurkure',
      name: 'Kurkure Masala Munch Crispy Namkeen',
      brand: 'KURKURE',
      packSize: '82 g Pack',
      price: 20.0,
      originalPrice: 20.0,
      discountPercent: 0,
      imageUrl: 'https://images.unsplash.com/photo-1600952841320-db92ec4047ca?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_snacks',
      subcategory: 'Chips & Crisps',
      deliveryTimeMins: 10,
      rating: 4.7,
      ratingCount: 6800,
      description: 'Crunchy twists made from rice, corn, and gram flour tossed in spicy chatpata masalas. The quintessential Indian party snack.',
      nutritionalInfo: {
        'Energy': '450 kcal',
        'Protein': '5.2 g',
      },
      highlights: [
        'Chatpata Spice Blend',
        'Twisted Crispy Crunch',
        '100% Vegetarian Snack',
      ],
    ),
    Product(
      id: 'prod_bhujia',
      name: "Haldiram's Nagpur Aloo Bhujia",
      brand: "HALDIRAM'S",
      packSize: '200 g Pack',
      price: 52.0,
      originalPrice: 60.0,
      discountPercent: 13,
      imageUrl: 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_snacks',
      subcategory: 'Bhujia & Namkeen',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 5200,
      description: 'Crisp sev made with selected mashed potatoes, tepary bean flour, and a punchy sprinkle of mint, red chilli, and clove spices.',
      nutritionalInfo: {
        'Energy': '570 kcal',
        'Protein': '9.0 g',
      },
      highlights: [
        'Mild Mint & Potato Flavor',
        'Signature Crispy Texture',
        'No Artificial Preservatives',
      ],
    ),

    // -------------------------------------------------------------------------
    // 4. Cold Drinks & Beverages
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_coca_cola',
      name: 'Coca-Cola Original Soft Drink (Can)',
      brand: 'COCA-COLA',
      packSize: '300 ml Can',
      price: 40.0,
      originalPrice: 40.0,
      discountPercent: 0,
      imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_drinks',
      subcategory: 'Soft Drinks',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 11200,
      description: 'Refreshing crisp fizzy cola served ice-cold from our sub-4°C cooler. Pairs deliciously with meals, pizzas, and party snacks.',
      nutritionalInfo: {
        'Energy': '132 kcal',
        'Carbohydrates': '33 g',
        'Fat': '0 g',
      },
      highlights: [
        'Ice-Cold Direct from Hub',
        'Authentic Refreshing Taste',
        '100% Recyclable Can',
      ],
    ),
    Product(
      id: 'prod_thums_up',
      name: 'Thums Up Extra Strong Fizzy Cola',
      brand: 'THUMS UP',
      packSize: '750 ml Bottle',
      price: 45.0,
      originalPrice: 45.0,
      discountPercent: 0,
      imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_drinks',
      subcategory: 'Soft Drinks',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 7800,
      description: 'Taste the thunder with powerful carbonation and bold spicy cola taste. Chilled and carbonated to perfection.',
      nutritionalInfo: {
        'Energy': '40 kcal per 100ml',
        'Caffeine': 'Infused Punch',
      },
      highlights: [
        'Stronger Carbonation',
        'Bold Intense Flavor',
        'Delivered Chilled',
      ],
    ),

    // -------------------------------------------------------------------------
    // 5. Atta, Rice, Oils & Staples
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_aashirvaad_atta',
      name: 'Aashirvaad Shudh Chakki Whole Wheat Atta',
      brand: 'AASHIRVAAD',
      packSize: '5 kg Bag',
      price: 245.0,
      originalPrice: 285.0,
      discountPercent: 14,
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_staples',
      subcategory: 'Wheat Atta',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 9200,
      description: 'Crafted from heavy golden wheat grains sourced from MP fields. Slow chakki-ground to preserve bran fiber, delivering fluffy and soft rotis.',
      nutritionalInfo: {
        'Dietary Fiber': '11 g',
        'Energy': '365 kcal',
        'Protein': '11.8 g',
      },
      highlights: [
        '100% Whole Wheat Grains',
        'Traditional Chakki Process',
        'Super Soft Roti Texture',
      ],
    ),
    Product(
      id: 'prod_fortune_oil',
      name: 'Fortune Sunlite Refined Sunflower Oil',
      brand: 'FORTUNE',
      packSize: '1 Litre Pouch',
      price: 138.0,
      originalPrice: 170.0,
      discountPercent: 19,
      imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_staples',
      subcategory: 'Cooking Oils',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 6400,
      description: 'Light, healthy and clear sunflower oil fortified with Vitamins A & D. High smoke point ideal for daily cooking and deep frying.',
      nutritionalInfo: {
        'Fat': '100 g',
        'Vitamin A': '750 mcg',
        'Vitamin D': '11.25 mcg',
      },
      highlights: [
        'Fortified with Vitamins A & D',
        'High Smoke Point',
        'Triple Refined Purity',
      ],
    ),
    Product(
      id: 'prod_nandini_ghee',
      name: 'Nandini Pure Cow Desi Ghee',
      brand: 'NANDINI',
      packSize: '500 ml Jar',
      price: 310.0,
      originalPrice: 355.0,
      discountPercent: 12,
      imageUrl: 'https://images.unsplash.com/photo-1631451095765-2c91616fc9e6?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_staples',
      subcategory: 'Butter & Ghee',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 4800,
      description: 'Golden granular desi cow ghee churned using time-tested methods. Imparts traditional richness and divine aroma to sweets and daily meals.',
      nutritionalInfo: {
        'Milk Fat': '99.7%',
        'Energy': '897 kcal',
      },
      highlights: [
        'Danedar Golden Granules',
        'Agmark Special Grade',
        'Pure Cow Milk Aroma',
      ],
    ),
    Product(
      id: 'prod_basmati_rice',
      name: 'India Gate Feast Rozzana Basmati Rice',
      brand: 'INDIA GATE',
      packSize: '1 kg Pouch',
      price: 92.0,
      originalPrice: 125.0,
      discountPercent: 26,
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_staples',
      subcategory: 'Basmati Rice',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 3800,
      description: 'Aged long basmati grains with natural delicate aroma and fluffy non-sticky texture. Perfect for biryani, pulao, and everyday rice bowls.',
      nutritionalInfo: {
        'Carbohydrates': '78 g',
        'Protein': '8.2 g',
      },
      highlights: [
        'Naturally Aged Grains',
        'Slender & Non-Sticky',
        'Delicate Fragrant Aroma',
      ],
    ),

    // -------------------------------------------------------------------------
    // 6. Chocolates & Sweet Tooth
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_cadbury_silk',
      name: 'Cadbury Dairy Milk Silk Chocolate Bar',
      brand: 'CADBURY',
      packSize: '60 g Bar',
      price: 80.0,
      originalPrice: 85.0,
      discountPercent: 6,
      imageUrl: 'https://images.unsplash.com/photo-1549007994-cb92caebd54b?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_sweets',
      subcategory: 'Chocolates',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 8900,
      description: 'Creamier, smoother, and velvet-textured milk chocolate that melts luxuriously on your tongue. Packed in an ice-insulated thermal pouch.',
      nutritionalInfo: {
        'Energy': '532 kcal',
        'Cocoa Solids': 'Rich Blend',
      },
      highlights: [
        'Pure Velvet Silk Texture',
        'Sub-4°C Melt-Proof Delivery',
        'Classic Cadbury Formula',
      ],
    ),
    Product(
      id: 'prod_7',
      name: 'Milky Mist Paneer Special',
      brand: 'MILKY MIST',
      packSize: '200 g Pack',
      price: 89.0,
      originalPrice: 105.0,
      discountPercent: 15,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtb7hY35pcn7OcLcSgnzV1VL_itQwYY8h4qNEoDW1nhEH0Iy4Mh7jZQG83bTCaHyjiBnBWDITqtyh_qwfi6uQjuw2k5zvnmnbFLFRxgsiGDFwIX5_J8KkuGj6jXUE7-C9GuvXYg-d4HjcNwcDriWyLLeBGk1B1_Dl8yJfqmYjt3dMxbaTweMbdsL0kvr07bSMtdqrL22H1Urg2hA0c20SA7a7nu0MYFY0r-I3AdzFyLSZsvLIRmhdNYHWdhI7Majx6YvTklDySehA',
      categoryId: 'cat_dairy',
      subcategory: 'Cheese & Paneer',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 780,
    ),

    // -------------------------------------------------------------------------
    // Fresh Fruits & Veggies (cat_produce) - Image 4 exact reference items
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_8',
      name: 'Brown Coconut (Kobbarikaya)',
      brand: 'FARM FRESH',
      packSize: '1 pc',
      price: 49.0,
      originalPrice: 56.0,
      discountPercent: 12,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDoWVh64aiH6LnZNNtIkagQmHpT68RdceKHVcJKN0cqfQTJuObUvJwcSu-fTVWdS7p58ht9cV_xOWJ2QrC8X8nRh1n9Ohul9AhXHlIe__wpdLjbdzjSAPtxXmnCATiSitNDEIZNdq9jmj0SaK8z2ClReXee_v5287iZj_usAxDaGEbghFsFpN2tYbBihJRMlcfkJ96ZQAUmbXYnOenNy4kkdLQ2tf7q_gSUwffCAC3Zo5V-UaijLsbFQqY2z4oSkBeKYVdB6Fwkc-M',
      categoryId: 'cat_produce',
      subcategory: 'Daily Fruits',
      deliveryTimeMins: 8,
      rating: 4.8,
      ratingCount: 1120,
    ),
    Product(
      id: 'prod_9',
      name: 'Pomegranate Peeled (Danimma Ginjalu)',
      brand: 'FARM FRESH',
      packSize: '100 g',
      price: 63.0,
      originalPrice: 74.0,
      discountPercent: 15,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAU9YiVdYAbKY0nJ8HqVfs8-nF7qU6qsCGCGrLhx0Ri2qZwVDzw29O9Yp4i1SCGJP5tXNTcvNrWecoS902HdBHbc9IInME1S0VbbdX4UlZ0MAg-D6jhLsJ4PEGqdpskUrfVhXN42Q76Fwh3OrS1jWXiV3i9yzUI0VDgOnCqZgo4EvKSlyKGDoi5voPXFpEDWxGZcw67WTUD6vYoCsY-Ixc6JNbDUfBHmrIkohERLDBioMEfOTCbNtKnCBbENEyHApYGyl-tXILNU94',
      categoryId: 'cat_produce',
      subcategory: 'Cut & Sprouts',
      deliveryTimeMins: 8,
      rating: 4.9,
      ratingCount: 940,
    ),
    Product(
      id: 'prod_10',
      name: 'Mini Orange (Narinja Pandu)',
      brand: 'CITRUS VALLEY',
      packSize: '250 g',
      price: 121.0,
      originalPrice: 141.0,
      discountPercent: 14,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDoWVh64aiH6LnZNNtIkagQmHpT68RdceKHVcJKN0cqfQTJuObUvJwcSu-fTVWdS7p58ht9cV_xOWJ2QrC8X8nRh1n9Ohul9AhXHlIe__wpdLjbdzjSAPtxXmnCATiSitNDEIZNdq9jmj0SaK8z2ClReXee_v5287iZj_usAxDaGEbghFsFpN2tYbBihJRMlcfkJ96ZQAUmbXYnOenNy4kkdLQ2tf7q_gSUwffCAC3Zo5V-UaijLsbFQqY2z4oSkBeKYVdB6Fwkc-M',
      categoryId: 'cat_produce',
      subcategory: 'Daily Fruits',
      deliveryTimeMins: 8,
      rating: 4.7,
      ratingCount: 610,
    ),
    Product(
      id: 'prod_11',
      name: 'Pineapple Cut (Anasa Mukkalu)',
      brand: 'FARM FRESH',
      packSize: '200 g',
      price: 60.0,
      originalPrice: 73.0,
      discountPercent: 18,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAU9YiVdYAbKY0nJ8HqVfs8-nF7qU6qsCGCGrLhx0Ri2qZwVDzw29O9Yp4i1SCGJP5tXNTcvNrWecoS902HdBHbc9IInME1S0VbbdX4UlZ0MAg-D6jhLsJ4PEGqdpskUrfVhXN42Q76Fwh3OrS1jWXiV3i9yzUI0VDgOnCqZgo4EvKSlyKGDoi5voPXFpEDWxGZcw67WTUD6vYoCsY-Ixc6JNbDUfBHmrIkohERLDBioMEfOTCbNtKnCBbENEyHApYGyl-tXILNU94',
      categoryId: 'cat_produce',
      subcategory: 'Cut & Sprouts',
      deliveryTimeMins: 8,
      rating: 4.8,
      ratingCount: 450,
    ),
    Product(
      id: 'prod_12',
      name: 'Fresh Hybrid Tomato',
      brand: 'ORGANIC FARMS',
      packSize: '500 g',
      price: 24.0,
      originalPrice: 30.0,
      discountPercent: 20,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDoWVh64aiH6LnZNNtIkagQmHpT68RdceKHVcJKN0cqfQTJuObUvJwcSu-fTVWdS7p58ht9cV_xOWJ2QrC8X8nRh1n9Ohul9AhXHlIe__wpdLjbdzjSAPtxXmnCATiSitNDEIZNdq9jmj0SaK8z2ClReXee_v5287iZj_usAxDaGEbghFsFpN2tYbBihJRMlcfkJ96ZQAUmbXYnOenNy4kkdLQ2tf7q_gSUwffCAC3Zo5V-UaijLsbFQqY2z4oSkBeKYVdB6Fwkc-M',
      categoryId: 'cat_produce',
      subcategory: 'Fresh Vegetables',
      deliveryTimeMins: 10,
      rating: 4.6,
      ratingCount: 1890,
    ),
    Product(
      id: 'prod_13',
      name: 'Fresh Green Coriander',
      brand: 'HERB GARDEN',
      packSize: '100 g Bunch',
      price: 15.0,
      originalPrice: 20.0,
      discountPercent: 25,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDoWVh64aiH6LnZNNtIkagQmHpT68RdceKHVcJKN0cqfQTJuObUvJwcSu-fTVWdS7p58ht9cV_xOWJ2QrC8X8nRh1n9Ohul9AhXHlIe__wpdLjbdzjSAPtxXmnCATiSitNDEIZNdq9jmj0SaK8z2ClReXee_v5287iZj_usAxDaGEbghFsFpN2tYbBihJRMlcfkJ96ZQAUmbXYnOenNy4kkdLQ2tf7q_gSUwffCAC3Zo5V-UaijLsbFQqY2z4oSkBeKYVdB6Fwkc-M',
      categoryId: 'cat_produce',
      subcategory: 'Organic Herbs',
      deliveryTimeMins: 10,
      rating: 4.7,
      ratingCount: 520,
    ),

    // -------------------------------------------------------------------------
    // Atta, Rice & Dals (cat_staples)
    // -------------------------------------------------------------------------
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
      id: 'prod_14',
      name: 'Aashirvaad Shudh Chakki Atta',
      brand: 'AASHIRVAAD',
      packSize: '5 kg Bag',
      price: 245.0,
      originalPrice: 280.0,
      discountPercent: 12,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_zg4idKN0gPq7Y-fgt7Fm7q3gNPNGlqNyIT7tLWnymMb5R67f1SavN5tf7Y3_Ow-Rqb-YyNz7t-Ez2gjLG7hNflWrNfnBQ5oIqzofkPGlW2N144GE2PlrkUi0fzd2sDemqJ_ZW3dm1SC5yW4W2xYCLSWoYSB6JDIQ-tmZiE3uH-7bl5Zo1hU3UEYwn_pifSWOXJz7dvVB1xeRF5XvnC6x9rcx1Va2JxEJzzEKp5vvODf10b3PAwZzMd2uxrRUSN-gMR57nnswuiA',
      categoryId: 'cat_staples',
      subcategory: 'Wheat Atta',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 4500,
    ),
    Product(
      id: 'prod_15',
      name: 'Daawat Rozana Super Basmati Rice',
      brand: 'DAAWAT',
      packSize: '1 kg Pouch',
      price: 98.0,
      originalPrice: 125.0,
      discountPercent: 21,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_zg4idKN0gPq7Y-fgt7Fm7q3gNPNGlqNyIT7tLWnymMb5R67f1SavN5tf7Y3_Ow-Rqb-YyNz7t-Ez2gjLG7hNflWrNfnBQ5oIqzofkPGlW2N144GE2PlrkUi0fzd2sDemqJ_ZW3dm1SC5yW4W2xYCLSWoYSB6JDIQ-tmZiE3uH-7bl5Zo1hU3UEYwn_pifSWOXJz7dvVB1xeRF5XvnC6x9rcx1Va2JxEJzzEKp5vvODf10b3PAwZzMd2uxrRUSN-gMR57nnswuiA',
      categoryId: 'cat_staples',
      subcategory: 'Basmati Rice',
      deliveryTimeMins: 10,
      rating: 4.7,
      ratingCount: 1600,
    ),

    // -------------------------------------------------------------------------
    // Snacks & Munchies (cat_snacks)
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_16',
      name: 'Lay\'s India\'s Magic Masala Chips',
      brand: 'LAY\'S',
      packSize: '73 g',
      price: 30.0,
      originalPrice: 35.0,
      discountPercent: 14,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAzT24iqkZd6yJlU5I9gM_Ct1CAjs8TIS4FiigbJTp-nsFxZ5VrabIFE48HKRZhDywu5i4Ll-U4fTjr51OkDXItn-tCWk8S7d74I_l55QaFGkHVU4thdnoAWclpZl45BljMEnU6G4-ZO0DMxjTQw4kKPgIZ8RSWYGWksEpBesm-rRjDHevlX5rP_lqg4X02gmZVgDueWIIy7fKePi191waIiteGiqaTEV2ZG49Uyx7HZWwqlu8rp4xH4gJ-Y15N29IwGtbHlihQEKU',
      categoryId: 'cat_snacks',
      subcategory: 'Chips & Crisps',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 3800,
    ),
    Product(
      id: 'prod_17',
      name: 'Cadbury Dairy Milk Silk Chocolate',
      brand: 'CADBURY',
      packSize: '60 g Bar',
      price: 75.0,
      originalPrice: 85.0,
      discountPercent: 12,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAzT24iqkZd6yJlU5I9gM_Ct1CAjs8TIS4FiigbJTp-nsFxZ5VrabIFE48HKRZhDywu5i4Ll-U4fTjr51OkDXItn-tCWk8S7d74I_l55QaFGkHVU4thdnoAWclpZl45BljMEnU6G4-ZO0DMxjTQw4kKPgIZ8RSWYGWksEpBesm-rRjDHevlX5rP_lqg4X02gmZVgDueWIIy7fKePi191waIiteGiqaTEV2ZG49Uyx7HZWwqlu8rp4xH4gJ-Y15N29IwGtbHlihQEKU',
      categoryId: 'cat_snacks',
      subcategory: 'Chocolates',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 5100,
    ),

    // -------------------------------------------------------------------------
    // Cold Drinks & Juices (cat_drinks)
    // -------------------------------------------------------------------------
    Product(
      id: 'prod_18',
      name: 'Thums Up Charged Cola',
      brand: 'COCA-COLA',
      packSize: '750 ml Bottle',
      price: 40.0,
      originalPrice: 45.0,
      discountPercent: 11,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtb7hY35pcn7OcLcSgnzV1VL_itQwYY8h4qNEoDW1nhEH0Iy4Mh7jZQG83bTCaHyjiBnBWDITqtyh_qwfi6uQjuw2k5zvnmnbFLFRxgsiGDFwIX5_J8KkuGj6jXUE7-C9GuvXYg-d4HjcNwcDriWyLLeBGk1B1_Dl8yJfqmYjt3dMxbaTweMbdsL0kvr07bSMtdqrL22H1Urg2hA0c20SA7a7nu0MYFY0r-I3AdzFyLSZsvLIRmhdNYHWdhI7Majx6YvTklDySehA',
      categoryId: 'cat_drinks',
      subcategory: 'Soft Drinks',
      deliveryTimeMins: 10,
      rating: 4.8,
      ratingCount: 3100,
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

  static List<Product> searchProducts(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];
    return _products.where((p) {
      return p.name.toLowerCase().contains(clean) ||
          p.brand.toLowerCase().contains(clean) ||
          p.subcategory.toLowerCase().contains(clean);
    }).toList();
  }

  static List<Product> getBestsellers() {
    return _products.where((p) => p.ratingCount >= 6000).toList();
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
    }
    return list;
  }
}

enum ProductSortOption {
  popular('Popularity'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  discount('Highest Discount');

  final String label;
  const ProductSortOption(this.label);
}
