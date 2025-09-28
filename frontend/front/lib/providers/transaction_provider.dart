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
    final now = DateTime.now();
    final transaction = Transaction(
      id: now.millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'buy',
      date: now.toIso8601String(),
      status: 'completed',
    );
    addTransaction(transaction);
  }

  void sellCredits(double amount) {
    // Simulate selling credits
    final now = DateTime.now();
    final transaction = Transaction(
      id: now.millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'sell',
      date: now.toIso8601String(),
      status: 'completed',
    );
    addTransaction(transaction);
  }
  
  // Add some sample transactions for demo purposes
  void addSampleTransactions() {
    final now = DateTime.now();
    final sampleTransactions = [
      Transaction(
        id: '${now.millisecondsSinceEpoch - 86400000}',
        amount: 150.0,
        type: 'buy',
        date: now.subtract(const Duration(days: 1)).toIso8601String(),
        status: 'completed',
      ),
      Transaction(
        id: '${now.millisecondsSinceEpoch - 172800000}',
        amount: 75.0,
        type: 'sell',
        date: now.subtract(const Duration(days: 2)).toIso8601String(),
        status: 'completed',
      ),
      Transaction(
        id: '${now.millisecondsSinceEpoch - 259200000}',
        amount: 200.0,
        type: 'buy',
        date: now.subtract(const Duration(days: 3)).toIso8601String(),
        status: 'pending',
      ),
    ];
    
    for (final transaction in sampleTransactions) {
      if (!_transactions.any((t) => t.id == transaction.id)) {
        _transactions.add(transaction);
      }
    }
    notifyListeners();
  }
}
