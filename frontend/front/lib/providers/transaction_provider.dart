import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  double get totalCredits => _transactions
      .where((t) => t.status == 'completed')
      .fold(0.0, (sum, t) => sum + (t.type == 'buy' ? t.amount : -t.amount));

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void setTransactions(List<Transaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }

  void buyCredits(double amount) {
    // Simulate buying credits
    final transaction = Transaction(
      id: DateTime.now().toString(),
      amount: amount,
      type: 'buy',
      date: DateTime.now().toIso8601String(),
      status: 'completed',
    );
    addTransaction(transaction);
  }

  void sellCredits(double amount) {
    // Simulate selling credits
    final transaction = Transaction(
      id: DateTime.now().toString(),
      amount: amount,
      type: 'sell',
      date: DateTime.now().toIso8601String(),
      status: 'completed',
    );
    addTransaction(transaction);
  }
}
