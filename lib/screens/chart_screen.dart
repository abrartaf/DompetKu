import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatefulWidget {
  final double income;
  final double expense;

  // Constructor to accept income and expense
  ChartScreen({required this.income, required this.expense});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _selectedPeriod = "Monthly"; // Default period
  DateTime _startDate = DateTime(2024, 11, 1);
  DateTime _endDate = DateTime(2024, 11, 30);

  // Handle period change and update date range
  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;

      if (period == "Monthly") {
        _startDate = DateTime(2024, 11, 1);
        _endDate = DateTime(2024, 11, 30);
      } 
    });
  }

  @override
  Widget build(BuildContext context) {
    double netIncome = widget.income - widget.expense; // Calculate net income

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

          // Donut Charts (Income and Expense)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDonutChart("Income", widget.income, Colors.green),
                  ),
                  Expanded(
                    child: _buildDonutChart("Expense", widget.expense, Colors.red),
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
                      "IDR ${netIncome.toStringAsFixed(0)}",
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
      ),
    );
  }

  // Build Period Selector Buttons
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

  // Build Donut Chart Widget
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
          "IDR ${value.toStringAsFixed(0)}",
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }

  // Get Month Name from Month Number
  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}
