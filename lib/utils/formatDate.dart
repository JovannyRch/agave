import 'package:intl/intl.dart';

String formatDate(String? dateStr) {
  try {
    if (dateStr == null) return '';

    DateTime parsedDate = DateTime.parse(dateStr);

    String formattedDate = DateFormat("dd MMM y", 'es_ES').format(parsedDate);

    return formattedDate;
  } catch (e) {
    return dateStr ?? '';
  }
}
