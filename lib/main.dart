import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated Firebase configuration file
import 'screens/home_screen.dart';
import 'screens/chart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the firebase_options.dart configuration
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Use platform-specific config
    );
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(MoneyManagerApp());
}

class MoneyManagerApp extends StatefulWidget {
  @override
  _MoneyManagerAppState createState() => _MoneyManagerAppState();
}

class _MoneyManagerAppState extends State<MoneyManagerApp> {
  int _selectedIndex = 0; // Tracks the currently selected page

  // Function to update income and expense values (used by HomeScreen)
  void _updateChartData(double income, double expense) {
    // Functionality preserved for potential future use
    debugPrint('Income: $income, Expense: $expense');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(updateChartData: _updateChartData), // Home Screen
            ChartScreen(), // Updated Chart Screen (fetches data dynamically)
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
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
