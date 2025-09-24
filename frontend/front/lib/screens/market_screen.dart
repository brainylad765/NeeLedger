import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_button.dart';

class MarketScreen extends StatelessWidget {
  static const String routeName = '/market';

  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buy/Sell Carbon Credits',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Current Market Price',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '\$25.00 per tCO₂e',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Buy 100 Credits',
                    onPressed: () {
                      transactionProvider.buyCredits(100);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bought 100 credits!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Sell 50 Credits',
                    onPressed: () {
                      transactionProvider.sellCredits(50);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sold 50 credits!')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: transactionProvider.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactionProvider.transactions[index];
                  return ListTile(
                    title: Text('${transaction.type} - ${transaction.amount} tCO₂e'),
                    subtitle: Text('Date: ${transaction.date}'),
                    trailing: Chip(
                      label: Text(transaction.status),
                      backgroundColor: transaction.status == 'completed' ? Colors.green : Colors.orange,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
