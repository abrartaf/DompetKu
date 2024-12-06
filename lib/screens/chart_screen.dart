import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _selectedPeriod = "Monthly"; // Default period
  DateTime _startDate = DateTime(2024, 12, 1);
  DateTime _endDate = DateTime(2024, 12, 30);

  // Fetch income and expense data from Firestore
  Stream<Map<String, double>> _fetchChartData() {
    return FirebaseFirestore.instance.collection('transactions').snapshots().map((snapshot) {
      double totalIncome = 0.0;
      double totalExpense = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final isIncome = data['isIncome'] as bool;
        final amount = (data['amount'] as num).toDouble();
        final date = (data['date'] as Timestamp).toDate();

        // Filter by date range
        if (date.isAfter(_startDate.subtract(Duration(days: 1))) &&
            date.isBefore(_endDate.add(Duration(days: 1)))) {
          if (isIncome) {
            totalIncome += amount;
          } else {
            totalExpense += amount;
          }
        }
      }

      return {'income': totalIncome, 'expense': totalExpense};
    });
  }

  // Update date range based on selected period
  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;

      if (period == "Monthly") {
        _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
        _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
      } else if (period == "Weekly") {
        _startDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        _endDate = _startDate.add(Duration(days: 6));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chart"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Period Selector
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeriodButton("Monthly"),
                _buildPeriodButton("Weekly"),
              ],
            ),
          ),

          // Date Range Display
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${_startDate.day} ${_monthName(_startDate.month)} ${_startDate.year} - ${_endDate.day} ${_monthName(_endDate.month)} ${_endDate.year}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          // StreamBuilder for Donut Charts
          Expanded(
            child: StreamBuilder<Map<String, double>>(
              stream: _fetchChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return Center(child: Text("No data available."));
                }

                final chartData = snapshot.data!;
                final income = chartData['income']!;
                final expense = chartData['expense']!;
                final netIncome = income - expense;

                return Column(
                  children: [
                    // Donut Charts
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildDonutChart("Income", income, Colors.green),
                            ),
                            Expanded(
                              child: _buildDonutChart("Expense", expense, Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Net Income Display
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Text(
                                "Net Income",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Rp ${netIncome.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: netIncome >= 0 ? Colors.blue : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _selectedPeriod == period ? Colors.blue : Colors.grey[300],
        ),
        onPressed: () => _changePeriod(period),
        child: Text(
          period,
          style: TextStyle(
            color: _selectedPeriod == period ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDonutChart(String title, double value, Color color) {
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: value,
                  color: color,
                  radius: 50,
                  title: "",
                ),
                PieChartSectionData(
                  value: value == 0 ? 1 : (10000000 - value),
                  color: Colors.grey[200],
                  radius: 50,
                  title: "",
                ),
              ],
              centerSpaceRadius: 30,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "Rp ${value.toStringAsFixed(0)}",
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}
