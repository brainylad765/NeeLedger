import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  return formatter.format(amount);
}

String formatDate(String dateString) {
  final date = DateTime.parse(dateString);
  return DateFormat('MMM dd, yyyy').format(date);
}

bool isValidEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
}
