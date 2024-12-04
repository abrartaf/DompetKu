import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as model; // Prefix the custom model
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  final Function(double, double) updateChartData;

  HomeScreen({required this.updateChartData});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = "All"; // Filter state: "All", "Income", or "Expenses"

  // Update chart data (income and expenses)
  void _updateChartData() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('transactions').get();

    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final isIncome = data['isIncome'] as bool;
      final amount = (data['amount'] as num).toDouble();

      if (isIncome) {
        totalIncome += amount;
      } else {
        totalExpenses += amount;
      }
    }

    widget.updateChartData(totalIncome, totalExpenses);
  }

  // Add a new transaction to Firestore
  void _addTransaction(String title, double amount, bool isIncome) {
    FirebaseFirestore.instance.collection('transactions').add({
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'date': DateTime.now(),
    });
    _updateChartData();
  }

  // Edit an existing transaction in Firestore
  void _editTransaction(String id, String newTitle, double newAmount, bool isIncome) {
    FirebaseFirestore.instance.collection('transactions').doc(id).update({
      'title': newTitle,
      'amount': newAmount,
      'isIncome': isIncome,
      'date': DateTime.now(),
    });
    _updateChartData();
  }

  // Delete a transaction from Firestore
  void _deleteTransaction(String id) {
    FirebaseFirestore.instance.collection('transactions').doc(id).delete();
    _updateChartData();
  }

  // Filtered transactions stream based on the selected filter
  Stream<List<model.Transaction>> get _filteredTransactionsStream {
    final collection = FirebaseFirestore.instance.collection('transactions');

    if (_filter == "Income") {
      return collection.where('isIncome', isEqualTo: true).snapshots().map(_mapToTransactionList);
    } else if (_filter == "Expenses") {
      return collection.where('isIncome', isEqualTo: false).snapshots().map(_mapToTransactionList);
    } else {
      return collection.snapshots().map(_mapToTransactionList);
    }
  }

  // Convert Firestore data to a list of Transaction objects
  List<model.Transaction> _mapToTransactionList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return model.Transaction(
        id: doc.id,
        title: data['title'],
        amount: (data['amount'] as num).toDouble(),
        isIncome: data['isIncome'] as bool,
        date: (data['date'] as Timestamp).toDate(),
      );
    }).toList();
  }

  // Open the TransactionForm for adding or editing
  void _openTransactionForm(BuildContext context, {model.Transaction? transactionToEdit}) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(
          transactionToEdit: transactionToEdit,
          onTransactionUpdated: _updateChartData,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _filter,
              icon: Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: Colors.blue,
              underline: SizedBox(),
              items: [
                DropdownMenuItem(
                  value: "All",
                  child: Text("All", style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: "Income",
                  child: Text("Income", style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: "Expenses",
                  child: Text("Expenses", style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<List<model.Transaction>>(
            stream: _filteredTransactionsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final transactions = snapshot.data ?? [];
              final totalIncome = transactions
                  .where((tx) => tx.isIncome)
                  .fold(0.0, (sum, tx) => sum + tx.amount);

              final totalExpenses = transactions
                  .where((tx) => !tx.isIncome)
                  .fold(0.0, (sum, tx) => sum + tx.amount);

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem("Income", totalIncome, Colors.green),
                      _buildSummaryItem("Expenses", totalExpenses, Colors.red),
                      _buildSummaryItem(
                        "Balance",
                        totalIncome - totalExpenses,
                        (totalIncome - totalExpenses) >= 0
                            ? Colors.blue
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<model.Transaction>>(
              stream: _filteredTransactionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data ?? [];
                return TransactionList(
                  transactions: transactions,
                  deleteTransaction: _deleteTransaction,
                  editTransaction: (tx) =>
                      _openTransactionForm(context, transactionToEdit: tx),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTransactionForm(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          amount.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
