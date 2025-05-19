import 'package:application/models/statement.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComponentNetworth extends StatefulWidget {
  const ComponentNetworth({super.key});

  @override
  State<ComponentNetworth> createState() => _ComponentNetworthState();
}

class _ComponentNetworthState extends State<ComponentNetworth> {
  /// Index of the selected period.
  /// 0 -> 1W, 1 -> 1M, 2 -> 3M, 4 -> YTD, 5 -> 1Y, 6 -> MAX
  int _selectedPeriod = 0;

  /// Period labels for the data to be displayed in the chart.
  final List<String> _periodLabels = ["1W", '1M', '3M', "YTD", '1Y', 'MAX'];

  /// Function to change the selected period.
  void selectPeriod(int i) {
    setState(() {
      _selectedPeriod = i;
    });
  }

  /// This is the widget that holds the portfolio value graph, with time period selects.
  @override
  Widget build(BuildContext context) {
    /// Gets the user statement.
    final statement = Provider.of<Statement>(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Portfolio Value Graph
            const Text(
              "You are worth",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            /// Total Portfolio Value.
            Text(
              statement.formatter.format(statement.networth),
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            /// Porfolio value comparison.
            Row(
              children: [
                /// Portfolio value at the beginning of the time period.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERIOD START',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      statement.formatter.format(
                        statement.periodChange[_selectedPeriod][0],
                      ),
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
                      'PERIOD CHANGE',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        if (statement.periodChange[_selectedPeriod][1] -
                                statement.periodChange[_selectedPeriod][0] >
                            0) {
                          return Text(
                            "+${statement.formatter.format(statement.periodChange[_selectedPeriod][1] - statement.periodChange[_selectedPeriod][0])}",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 16,
                            ),
                          );
                        }
                        if (statement.periodChange[_selectedPeriod][1] -
                                statement.periodChange[_selectedPeriod][0] ==
                            0) {
                          return Text(
                            statement.formatter.format(
                              statement.periodChange[_selectedPeriod][1] -
                                  statement.periodChange[_selectedPeriod][0],
                            ),
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          );
                        }
                        return Text(
                          statement.formatter.format(
                            statement.periodChange[_selectedPeriod][1] -
                                statement.periodChange[_selectedPeriod][0],
                          ),
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Line chart where the changing portfolio value is displayed.
            Padding(
              padding: EdgeInsets.all(11),
              child: SizedBox(
                height: 75,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((touchedSpot) {
                            if (touchedSpot.barIndex == 0) {
                              return LineTooltipItem(
                                statement.formatter.format(touchedSpot.y),
                                TextStyle(color: touchedSpot.bar.color),
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                    ),
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
                        spots: statement.periodSpots[_selectedPeriod],
                        barWidth: 3,
                        isCurved: false,
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
                              Colors.lightBlueAccent.withValues(alpha: 0.2),
                              Colors.lightBlueAccent.withValues(alpha: 0.0),
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

            const SizedBox(height: 24),

            /// This is the row for the period labels selection.
            /// Generates a list of text buttons for each of the period labels.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_periodLabels.length, (i) {
                final isSelected = i == _selectedPeriod;
                return SizedBox(
                  width: 50.0,
                  child: TextButton(
                    onPressed: () => selectPeriod(i),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor:
                          isSelected ? Colors.blueAccent : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      _periodLabels[i],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
