import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  // Factory constructor to create a Transaction object from Firestore data
  factory Transaction.fromFirestore(Map<String, dynamic> data, String id) {
    return Transaction(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      isIncome: data['isIncome'] ?? false,
    );
  }

  // Method to convert Transaction object to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'isIncome': isIncome,
    };
  }
}
