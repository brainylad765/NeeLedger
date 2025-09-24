import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text('${transaction.type} - ${transaction.amount} tCO₂e'),
        subtitle: Text('Date: ${transaction.date}'),
        trailing: Chip(
          label: Text(transaction.status),
          backgroundColor: _getStatusColor(transaction.status),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
