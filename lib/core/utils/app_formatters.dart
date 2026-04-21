import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs ',
    decimalDigits: 2,
  );

  static String money(num amount) => _currency.format(amount);

  static String shortDate(DateTime date) => DateFormat('dd MMM').format(date);
}

