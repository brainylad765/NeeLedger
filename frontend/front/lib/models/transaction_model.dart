class Transaction {
  final String id;
  final double amount;
  final String type; // 'buy', 'sell', 'transfer'
  final String date;
  final String status; // 'pending', 'completed', 'failed'

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      date: json['date'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'date': date,
      'status': status,
    };
  }
}
