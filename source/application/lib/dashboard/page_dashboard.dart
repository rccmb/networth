import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PageDashboard extends StatefulWidget {
  const PageDashboard({super.key});

  @override
  State<PageDashboard> createState() => _PageDashboardState();
}

class _PageDashboardState extends State<PageDashboard> {
  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  /// Euro formatter.
  final euroFormat = NumberFormat.simpleCurrency(locale: 'pt_PT', name: 'EUR');

  /// Current balance.
  String _currentBalance = "";

  /// Is the dashboard loading.
  bool _isLoading = true;

  /// Index of the selected period.
  /// 0 -> 1W, 1 -> 1M, 2 -> 3M, 4 -> YTD, 5 -> 1Y, 6 -> MAX
  int _selectedPeriod = 0;

  /// Array with the data that will be displayed in the chart.
  final List<List<FlSpot>> _periodSpots = List.filled(6, []);

  /// Period labels for the data to be displayed in the chart.
  final List<String> _periodLabels = ["1W", '1M', '3M', "YTD", '1Y', 'MAX'];

  /// Function to select the current period to display.
  void selectPeriod(int i) {
    setState(() {
      _selectedPeriod = i;
    });
  }

  /// Populating _periodSpots with the correct data.
  Future<void> _loadChartData() async {
    // Query supabase and order by date.
    final response = await Supabase.instance.client
        .from('daily_source_balance')
        .select()
        .order('date');

    // Group the data by run (run ID in supabase).
    final Map<int, List<Map<String, dynamic>>> groupedByRun = {};
    for (final row in response) {
      final runId = row['run_id'];
      if (runId == null || row['balance'] == null || row['date'] == null) {
        continue;
      }
      groupedByRun.putIfAbsent(runId, () => []).add(row);
    }

    // Consolidate by run id, add up the balances in this specific run id.
    final List<Map<String, dynamic>> points =
        groupedByRun.entries.map((entry) {
          final rows = entry.value;
          final timestamp = rows
              .map((e) => DateTime.parse(e['date']))
              .reduce((a, b) => a.isAfter(b) ? a : b);
          final total = rows.fold<double>(
            0,
            (sum, e) => sum + (e['balance'] as num).toDouble(),
          );
          return {'date': timestamp, 'y': total};
        }).toList();

    // Sort the points by date.
    points.sort((a, b) => a['date'].compareTo(b['date']));

    // Update the current balance.
    if (points.isNotEmpty) {
      final lastY = points.last['y'] as double;
      _currentBalance = euroFormat.format(lastY);
    }

    final Map<int, List<Map<String, dynamic>>> periodRawPoints = {
      0: [], // 1W
      1: [], // 1M
      2: [], // 3M
      3: [], // YTD
      4: [], // 1Y
      5: [], // MAX
    };

    final now = DateTime.now();

    // Populate the raw points, non FlSpots.
    for (final p in points) {
      final date = p['date'] as DateTime;

      if (date.isAfter(now.subtract(Duration(days: 7)))) {
        periodRawPoints[0]!.add(p);
      }
      if (date.isAfter(now.subtract(Duration(days: 30)))) {
        periodRawPoints[1]!.add(p);
      }
      if (date.isAfter(now.subtract(Duration(days: 90)))) {
        periodRawPoints[2]!.add(p);
      }
      if (date.year == now.year) {
        periodRawPoints[3]!.add(p);
      }
      if (date.isAfter(now.subtract(Duration(days: 365)))) {
        periodRawPoints[4]!.add(p);
      }
      periodRawPoints[5]!.add(p); // MAX
    }

    final Map<int, List<FlSpot>> tempSpots = {};

    // Turn the raw points to actual FlSpots.
    for (int i = 0; i < 6; i++) {
      final rawList = periodRawPoints[i]!;

      final List<FlSpot> spots = [FlSpot(0, 0)];
      for (int j = 0; j < rawList.length; j++) {
        final y = rawList[j]['y'] as double;
        spots.add(FlSpot(j.toDouble() + 1, y));
      }

      tempSpots[i] = spots;
    }

    setState(() {
      for (int i = 0; i < 6; i++) {
        _periodSpots[i] = tempSpots[i]!;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Networth")),
      body: Builder(
        builder: (context) {
          if (_isLoading == true) {
            return Text("Hol'up");
          } else {
            return Column(
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
                        Text(
                          _currentBalance.toString(),
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
                                  'TEMPLATE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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
                                  'TEMPLATE',
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
                          child: SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((touchedSpot) {
                                        if (touchedSpot.barIndex == 0) {
                                          return LineTooltipItem(
                                            euroFormat.format(touchedSpot.y),
                                            TextStyle(
                                              color: touchedSpot.bar.color,
                                            ),
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
                            return SizedBox(
                              width: 50.0,
                              child: TextButton(
                                onPressed: () => selectPeriod(i),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
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
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.white54,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
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
            );
          }
        },
      ),
    );
  }
}
