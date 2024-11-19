import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/chart_screen.dart';

void main() {
  runApp(MoneyManagerApp());
}

class MoneyManagerApp extends StatefulWidget {
  @override
  _MoneyManagerAppState createState() => _MoneyManagerAppState();
}

class _MoneyManagerAppState extends State<MoneyManagerApp> {
  int _selectedIndex = 0; // Add this variable to track the selected page
  double _income = 0.0; // Income shared across pages
  double _expense = 0.0; // Expense shared across pages

  // Function to update income and expense values
  void _updateChartData(double income, double expense) {
    setState(() {
      _income = income;
      _expense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex, // Use _selectedIndex to display the correct page
          children: [
            HomeScreen(updateChartData: _updateChartData),
            ChartScreen(income: _income, expense: _expense),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // Use _selectedIndex for navigation
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Update _selectedIndex when a tab is tapped
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Chart',
            ),
          ],
        ),
      ),
    );
  }
}
