import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String) deleteTransaction;
  final Function(Transaction) editTransaction;

  TransactionList({
    required this.transactions,
    required this.deleteTransaction,
    required this.editTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? Center(
            child: Text(
              'No transactions added yet!',
              style: TextStyle(fontSize: 18),
            ),
          )
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final tx = transactions[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        tx.isIncome ? Colors.green : Colors.red, // Set color based on type
                    radius: 30,
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Rp${tx.amount.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editTransaction(tx),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(context, tx.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // Show confirmation dialog before deleting a transaction
  void _showDeleteConfirmation(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              deleteTransaction(transactionId);
              Navigator.of(ctx).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
