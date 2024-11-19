import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Function(String, double, bool) addTransaction;
  final Transaction? transactionToEdit; // Optional transaction to edit
  final Function(String, String, double, bool)? onEditTransaction;

  TransactionForm(
    this.addTransaction, {
    this.transactionToEdit,
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

    if (widget.transactionToEdit != null) {
      _titleController.text = widget.transactionToEdit!.title;
      _amountController.text = widget.transactionToEdit!.amount.toString();
      _isIncome = widget.transactionToEdit!.isIncome;
    }
  }

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }

    if (widget.transactionToEdit != null) {
      widget.onEditTransaction!(
        widget.transactionToEdit!.id,
        enteredTitle,
        enteredAmount,
        _isIncome,
      );
    } else {
      widget.addTransaction(enteredTitle, enteredAmount, _isIncome);
    }

    Navigator.of(context).pop(); // Close the modal
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaction Type:'),
                ToggleButtons(
                  isSelected: [_isIncome, !_isIncome],
                  onPressed: (index) {
                    setState(() {
                      _isIncome = index == 0; // Index 0 -> Income, Index 1 -> Expense
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: Colors.blue,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Income'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Expense'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitData,
              child: Text(widget.transactionToEdit != null
                  ? 'Edit Transaction'
                  : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
