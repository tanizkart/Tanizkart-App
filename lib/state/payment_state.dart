import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedUpiItem {
  final String id;
  final String vpa;
  final String providerName; // Google Pay, PhonePe, Paytm, etc.
  final bool isDefault;

  const SavedUpiItem({
    required this.id,
    required this.vpa,
    required this.providerName,
    this.isDefault = false,
  });

  SavedUpiItem copyWith({bool? isDefault}) {
    return SavedUpiItem(
      id: id,
      vpa: vpa,
      providerName: providerName,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class SavedCardItem {
  final String id;
  final String bankName;
  final String maskedNumber; // e.g. "•••• 4821"
  final String expiryDate; // e.g. "08/28"
  final String network; // Visa, MasterCard, RuPay
  final String cardHolder;
  final bool isDefault;

  SavedCardItem({
    required this.id,
    String? bankName,
    String? bank,
    String? maskedNumber,
    String? last4,
    String? expiryDate,
    String? expiryMonth,
    String? expiryYear,
    String? network,
    String? brand,
    this.cardHolder = 'Yaswanth K.',
    this.isDefault = false,
  })  : bankName = bankName ?? bank ?? 'HDFC Bank',
        maskedNumber = maskedNumber ?? (last4 != null ? '•••• $last4' : '•••• 4821'),
        expiryDate = expiryDate ?? (expiryMonth != null && expiryYear != null ? '$expiryMonth/${expiryYear.length == 4 ? expiryYear.substring(2) : expiryYear}' : '12/28'),
        network = network ?? brand ?? 'Visa';

  String get brand => network;
  String get bank => bankName;
  String get expiryMonth => expiryDate.contains('/') ? expiryDate.split('/')[0] : '12';
  String get expiryYear => expiryDate.contains('/') ? expiryDate.split('/')[1] : '28';

  SavedCardItem copyWith({bool? isDefault}) {
    return SavedCardItem(
      id: id,
      bankName: bankName,
      maskedNumber: maskedNumber,
      expiryDate: expiryDate,
      network: network,
      cardHolder: cardHolder,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class PaymentState extends ChangeNotifier {
  static const String _prefDefaultMethod = 'taniz_default_payment_method';

  int _selectedMethodIndex = 0; // 0: UPI, 1: Cards, 2: COD

  final List<SavedUpiItem> _savedUpi = [
    const SavedUpiItem(
      id: 'upi_1',
      vpa: 'yaswanth@okaxis',
      providerName: 'Google Pay',
      isDefault: true,
    ),
    const SavedUpiItem(
      id: 'upi_2',
      vpa: '9848022338@paytm',
      providerName: 'Paytm UPI',
      isDefault: false,
    ),
  ];

  final List<SavedCardItem> _savedCards = [
    SavedCardItem(
      id: 'card_1',
      bankName: 'HDFC Bank Millennia',
      maskedNumber: '•••• 4821',
      expiryDate: '09/28',
      network: 'Visa',
      isDefault: true,
    ),
    SavedCardItem(
      id: 'card_2',
      bankName: 'ICICI Bank Coral',
      maskedNumber: '•••• 7129',
      expiryDate: '11/27',
      network: 'MasterCard',
      isDefault: false,
    ),
  ];

  PaymentState() {
    _loadPreferences();
  }

  int get selectedMethodIndex => _selectedMethodIndex;
  List<SavedUpiItem> get savedUpi => List.unmodifiable(_savedUpi);
  List<SavedUpiItem> get savedUpiList => List.unmodifiable(_savedUpi);
  List<SavedCardItem> get savedCards => List.unmodifiable(_savedCards);

  String get defaultMethodTitle {
    switch (_selectedMethodIndex) {
      case 0:
        final defUpi = _savedUpi.firstWhere((u) => u.isDefault, orElse: () => _savedUpi.first);
        return 'UPI (${defUpi.vpa})';
      case 1:
        final defCard = _savedCards.firstWhere((c) => c.isDefault, orElse: () => _savedCards.first);
        return '${defCard.bankName} (${defCard.maskedNumber})';
      case 2:
      default:
        return 'Pay on Delivery (Cash / UPI)';
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_prefDefaultMethod);
      if (savedIndex != null && savedIndex >= 0 && savedIndex <= 2) {
        _selectedMethodIndex = savedIndex;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setDefaultMethod(int index) async {
    if (index < 0 || index > 2) return;
    _selectedMethodIndex = index;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefDefaultMethod, index);
    } catch (_) {}
  }

  void addCard(SavedCardItem card) {
    _savedCards.add(card);
    notifyListeners();
  }

  void addUpi(String vpa, [String providerName = 'UPI App']) {
    final newItem = SavedUpiItem(
      id: 'upi_${DateTime.now().millisecondsSinceEpoch}',
      vpa: vpa.trim(),
      providerName: providerName,
      isDefault: _savedUpi.isEmpty,
    );
    _savedUpi.add(newItem);
    notifyListeners();
  }

  void removeUpi(String id) {
    _savedUpi.removeWhere((item) => item.id == id);
    if (_savedUpi.isNotEmpty && !_savedUpi.any((u) => u.isDefault)) {
      _savedUpi[0] = _savedUpi[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  void setDefaultUpi(String id) {
    for (int i = 0; i < _savedUpi.length; i++) {
      _savedUpi[i] = _savedUpi[i].copyWith(isDefault: _savedUpi[i].id == id);
    }
    _selectedMethodIndex = 0;
    notifyListeners();
  }

  void addTokenizedCard({
    required String bankName,
    required String lastFourDigits,
    required String expiryDate,
    required String network,
  }) {
    final newCard = SavedCardItem(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankName,
      maskedNumber: '•••• $lastFourDigits',
      expiryDate: expiryDate,
      network: network,
      isDefault: _savedCards.isEmpty,
    );
    _savedCards.add(newCard);
    notifyListeners();
  }

  void removeCard(String id) {
    _savedCards.removeWhere((item) => item.id == id);
    if (_savedCards.isNotEmpty && !_savedCards.any((c) => c.isDefault)) {
      _savedCards[0] = _savedCards[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  void setDefaultCard(String id) {
    for (int i = 0; i < _savedCards.length; i++) {
      _savedCards[i] = _savedCards[i].copyWith(isDefault: _savedCards[i].id == id);
    }
    _selectedMethodIndex = 1;
    notifyListeners();
  }
}
