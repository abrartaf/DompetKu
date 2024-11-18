import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];

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
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _editTransaction(String id, String newTitle, double newAmount, bool newIsIncome) {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      setState(() {
        _transactions[index] = Transaction(
          id: id,
          title: newTitle,
          amount: newAmount,
          date: DateTime.now(),
          isIncome: newIsIncome,
        );
      });
    }
  }

  void _openTransactionForm(BuildContext context, {Transaction? transactionToEdit}) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(
          _addTransaction,
          editTransaction: transactionToEdit,
          onEditTransaction: _editTransaction,
        );
      },
    );
  }

  double get _totalIncome {
    return _transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalExpenses {
    return _transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalBalance {
    return _totalIncome - _totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Manager'),
      ),
      body: Column(
        children: [
          Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryItem('Income', _totalIncome, Colors.green),
                  _buildSummaryItem('Expenses', _totalExpenses, Colors.red),
                  _buildSummaryItem('Balance', _totalBalance, Colors.blue),
                ],
              ),
            ),
          ),
          Expanded(
            child: TransactionList(
              transactions: _transactions,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          amount.toStringAsFixed(0),
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
