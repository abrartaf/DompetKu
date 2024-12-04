import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore; // Prefix Firestore import
import '../models/transaction.dart' as model; // Prefix the custom Transaction model

class TransactionForm extends StatefulWidget {
  final model.Transaction? transactionToEdit; // Use the custom Transaction model
  final Function()? onTransactionUpdated; // Callback to refresh the parent state

  TransactionForm({
    this.transactionToEdit,
    this.onTransactionUpdated,
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

    // Pre-fill the form if editing an existing transaction
    if (widget.transactionToEdit != null) {
      _titleController.text = widget.transactionToEdit!.title;
      _amountController.text = widget.transactionToEdit!.amount.toString();
      _isIncome = widget.transactionToEdit!.isIncome;
    }
  }

  // Submit transaction data to Firestore
  void _submitData() async {
    final enteredTitle = _titleController.text.trim();
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      // Show error if input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid title and amount')),
      );
      return;
    }

    try {
      final transactionsCollection = firestore.FirebaseFirestore.instance.collection('transactions');

      if (widget.transactionToEdit != null) {
        // Update existing transaction
        await transactionsCollection.doc(widget.transactionToEdit!.id).update({
          'title': enteredTitle,
          'amount': enteredAmount,
          'isIncome': _isIncome,
          'date': DateTime.now(),
        });
      } else {
        // Add new transaction
        await transactionsCollection.add({
          'title': enteredTitle,
          'amount': enteredAmount,
          'isIncome': _isIncome,
          'date': DateTime.now(),
        });
      }

      // Notify parent to refresh the state
      if (widget.onTransactionUpdated != null) {
        widget.onTransactionUpdated!();
      }

      // Close the modal
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save transaction: $error')),
      );
    }
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
