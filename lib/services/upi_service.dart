import 'package:url_launcher/url_launcher.dart';

class UpiService {
  static Future<void> pay({
    required String payeeName,
    required String upiId,
    required double amount,
    required String note,
  }) async {
    final uri = Uri.parse(
      'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}'
      '&am=${amount.toStringAsFixed(2)}&tn=${Uri.encodeComponent(note)}&cu=INR',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('No UPI app found on this device.');
    }
  }
}

