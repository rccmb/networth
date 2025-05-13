import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PageDashboard extends StatefulWidget {
  const PageDashboard({super.key});

  @override
  State<PageDashboard> createState() => _PageDashboardState();
}

class _PageDashboardState extends State<PageDashboard> {
  /// Index of the selected period.
  /// 0 -> 1M, 1 -> 3M, 2 -> 1Y, 3 -> MAX
  int _selectedPeriod = 0;

  void selectPeriod(int i) {
    setState(() {
      _selectedPeriod = i;
    });
  }

  final List<List<FlSpot>> _periodSpots = [
    [
      FlSpot(0, 2),
      FlSpot(1, 2.5),
      FlSpot(2, 2.3),
      FlSpot(3, 2.8),
      FlSpot(4, 2.6),
    ], // 1M
    [
      FlSpot(0, 1),
      FlSpot(1, 3),
      FlSpot(2, 2),
      FlSpot(3, 4),
      FlSpot(4, 3.5),
      FlSpot(5, 4.2),
    ], // 3M
    [
      FlSpot(0, 1),
      FlSpot(1, 1.5),
      FlSpot(2, 1.4),
      FlSpot(3, 3.4),
      FlSpot(4, 2),
      FlSpot(5, 2.2),
      FlSpot(6, 1.8),
    ], // 1Y
    [
      FlSpot(0, 0),
      FlSpot(1, 5),
      FlSpot(2, 3),
      FlSpot(3, 6),
      FlSpot(4, 4),
      FlSpot(5, 7),
      FlSpot(6, 5),
    ], // MAX
  ];

  final List<String> _periodLabels = ['1M', '3M', '1Y', 'MAX'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Networth")),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15.0),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: const Color(0xFF1E1E2C),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Total Portfolio Value.
                  const Text(
                    '£5,812.56',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Porfolio value comparison.
                  Row(
                    children: const [
                      /// Portfolio value at the beginning of the time period.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '£5,625.57',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),

                      SizedBox(width: 30),

                      /// Portfolio value change at the end of the time period.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '+£184.13 (3.27%)',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Line chart where the changing portfolio value is displayed.
                  Padding(
                    padding: EdgeInsets.all(11),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            /// Data to be used in the chart, each "point".
                            /// Also handles styling.
                            LineChartBarData(
                              spots: _periodSpots[_selectedPeriod],
                              isCurved: true,
                              color: Colors.lightBlueAccent,
                              gradient: LinearGradient(
                                colors: [
                                  ColorTween(
                                    begin: Colors.lightBlue,
                                    end: Colors.lightBlueAccent,
                                  ).lerp(1)!,
                                  ColorTween(
                                    begin: Colors.blue,
                                    end: Colors.blueAccent,
                                  ).lerp(1)!,
                                ],
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.lightBlueAccent.withValues(
                                      alpha: 0.2,
                                    ),
                                    Colors.lightBlueAccent.withValues(
                                      alpha: 0.0,
                                    ),
                                  ],
                                ),
                              ),
                              dotData: FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// This is the row for the period labels selection.
                  /// Generates a list of text buttons for each of the period labels.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_periodLabels.length, (i) {
                      final isSelected = i == _selectedPeriod;
                      return TextButton(
                        onPressed: () => selectPeriod(i),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              isSelected
                                  ? Colors.blueAccent
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          _periodLabels[i],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
