import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Function(String, double, bool) addTransaction;
  final Transaction? editTransaction;
  final Function(String, String, double, bool)? onEditTransaction;

  TransactionForm(
    this.addTransaction, {
    this.editTransaction,
    this.onEditTransaction,
  });

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = true;

  @override
  void initState() {
    super.initState();
    if (widget.editTransaction != null) {
      _titleController.text = widget.editTransaction!.title;
      _amountController.text = widget.editTransaction!.amount.toString();
      _isIncome = widget.editTransaction!.isIncome;
    }
  }

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }

    if (widget.editTransaction != null) {
      widget.onEditTransaction!(
        widget.editTransaction!.id,
        enteredTitle,
        enteredAmount,
        _isIncome,
      );
    } else {
      widget.addTransaction(enteredTitle, enteredAmount, _isIncome);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // Toggle buttons for Income and Expense
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isIncome ? Colors.green : Colors.grey, // Corrected styling
                  ),
                  onPressed: () {
                    setState(() {
                      _isIncome = true;
                    });
                  },
                  child: Text('Income'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isIncome ? Colors.red : Colors.grey, // Corrected styling
                  ),
                  onPressed: () {
                    setState(() {
                      _isIncome = false;
                    });
                  },
                  child: Text('Expense'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: Text(widget.editTransaction != null
                  ? 'Edit Transaction'
                  : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
