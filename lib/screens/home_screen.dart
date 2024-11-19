import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  final Function(double, double) updateChartData;

  HomeScreen({required this.updateChartData});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];
  String _filter = "All"; // Filter state: "All", "Income", or "Expenses"

  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;

  // Add a new transaction
  void _addTransaction(String title, double amount, bool isIncome) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      isIncome: isIncome,
    );

    setState(() {
      _transactions.add(newTx);
      _updateChartData();
    });
  }

  // Edit an existing transaction
  void _editTransaction(String id, String newTitle, double newAmount, bool isIncome) {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      setState(() {
        _transactions[index] = Transaction(
          id: id,
          title: newTitle,
          amount: newAmount,
          date: DateTime.now(),
          isIncome: isIncome,
        );
        _updateChartData();
      });
    }
  }

  // Delete a transaction
  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
      _updateChartData();
    });
  }

  // Update chart data (income and expenses)
  void _updateChartData() {
    _totalIncome = _transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    _totalExpenses = _transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    widget.updateChartData(_totalIncome, _totalExpenses);
  }

  // Open the TransactionForm for adding or editing
  void _openTransactionForm(BuildContext context, {Transaction? transactionToEdit}) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(
          _addTransaction,
          transactionToEdit: transactionToEdit,
          onEditTransaction: _editTransaction,
        );
      },
    );
  }

  // Filtered transactions based on the selected filter
  List<Transaction> get _filteredTransactions {
    if (_filter == "All") {
      return _transactions;
    } else if (_filter == "Income") {
      return _transactions.where((tx) => tx.isIncome).toList();
    } else {
      return _transactions.where((tx) => !tx.isIncome).toList();
    }
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
              underline: SizedBox(), // Removes underline
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
          // Summary Bar
          Card(
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
                  _buildSummaryItem("Income", _totalIncome, Colors.green),
                  _buildSummaryItem("Expenses", _totalExpenses, Colors.red),
                  _buildSummaryItem(
                    "Balance",
                    _totalIncome - _totalExpenses,
                    (_totalIncome - _totalExpenses) >= 0
                        ? Colors.blue
                        : Colors.red,
                  ),
                ],
              ),
            ),
          ),

          // Transaction List
          Expanded(
            child: TransactionList(
              transactions: _filteredTransactions,
              deleteTransaction: _deleteTransaction,
              editTransaction: (tx) =>
                  _openTransactionForm(context, transactionToEdit: tx),
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
