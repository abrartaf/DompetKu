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
                    radius: 30,
                    child: FittedBox(
                      child: Text(
                        tx.amount.toStringAsFixed(2),
                        style: TextStyle(
                          color: tx.isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  title: Text(tx.title),
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
                        onPressed: () => deleteTransaction(tx.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
