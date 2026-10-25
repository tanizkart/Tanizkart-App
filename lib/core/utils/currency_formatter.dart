import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatWithDecimals(num amount) {
    if (amount % 1 == 0) {
      return format(amount);
    }
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(amount);
  }
}
