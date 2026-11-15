import 'package:cloud_firestore/cloud_firestore.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime? parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return DateTime.parse(value.trim());
    } catch (_) {
      return null;
    }
  }

  static DateTime? fromTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return parseDate(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static dynamic toTimestamp(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}
