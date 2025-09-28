import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class ProfileTransactionItem extends StatelessWidget {
  final Transaction transaction;

  const ProfileTransactionItem({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBuy = transaction.type == 'buy';
    final displayAmount = transaction.amount;
    final amountColor = isBuy ? Colors.green : Colors.red;
    final amountPrefix = isBuy ? '+' : '-';
    final amountText = '$amountPrefix₹${displayAmount.toStringAsFixed(2)}';
    
    // Parse and format the date/time
    DateTime transactionDate;
    String formattedDate;
    String formattedTime;
    
    try {
      transactionDate = DateTime.parse(transaction.date);
      formattedDate = DateFormat('MMM dd, yyyy').format(transactionDate);
      formattedTime = DateFormat('HH:mm').format(transactionDate);
    } catch (e) {
      // Fallback if date parsing fails
      formattedDate = transaction.date;
      formattedTime = '';
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Transaction Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                  color: amountColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Type
                    Text(
                      isBuy ? 'Credits Purchased' : 'Credits Sold',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Date and Time
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (formattedTime.isNotEmpty) ...[
                          Text(
                            ' • ',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(transaction.status).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        transaction.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(transaction.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Amount with Google Pay Style
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Text(
                    '${displayAmount.toStringAsFixed(1)} tCO₂e',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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