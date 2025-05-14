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

  // /// Currently selected page.
  // int _selectedPage = 0;

  // /// Change the page.
  // void _onPageSelect(int index) {
  //   setState(() {
  //     _selectedPage = index;
  //   });
  // }

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

  /// Period changes for the networth texts. [PERIOD][START, NOW].
  final List<List<double>> _periodChange = List.filled(6, [0, 0]);

  /// The distribution of wealth per source { SOURCE, WEALTH }
  Map<String, double> _sourceDistribution = {};

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

        if (j == 0) {
          // First spot.
          _periodChange[i][0] = y;
        }
        if (j == rawList.length - 1) {
          // Last spot.
          _periodChange[i][1] = y;
        }

        spots.add(FlSpot(j.toDouble() + 1, y));
      }

      tempSpots[i] = spots;
    }

    // Get the latest run (most recent date across all rows).
    final latestRunId =
        groupedByRun.entries.reduce((a, b) {
          final dateA = a.value
              .map((e) => DateTime.parse(e['date']))
              .reduce((a, b) => a.isAfter(b) ? a : b);
          final dateB = b.value
              .map((e) => DateTime.parse(e['date']))
              .reduce((a, b) => a.isAfter(b) ? a : b);
          return dateA.isAfter(dateB) ? a : b;
        }).key;

    // Map a source with a corresponding value.
    final Map<String, double> sourceDistribution = {};
    for (final row in groupedByRun[latestRunId]!) {
      final source = row['source'] as String?;
      final balance = row['balance'];
      if (source == null || balance == null) continue;
      sourceDistribution[source] =
          (sourceDistribution[source] ?? 0) + (balance as num).toDouble();
    }

    setState(() {
      _sourceDistribution = sourceDistribution;
      for (int i = 0; i < 6; i++) {
        _periodSpots[i] = tempSpots[i]!;
      }
      _isLoading = false;
    });
  }

  /// Helper method to get the sections for the pie chart.
  List<PieChartSectionData> _getSections() {
    final total = _sourceDistribution.values.fold(0.0, (a, b) => a + b);

    return _sourceDistribution.entries.map((entry) {
      final percentage = entry.value / total;
      final isSmall = percentage < 0.05; // hide text for very small slices

      return PieChartSectionData(
        color: _colorFromLabel(entry.key),
        value: percentage * 100,
        radius: 30,
        title: "",
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// Helper method to get the color for the pie chart.
  Color _colorFromLabel(String label) {
    final colors = [
      Colors.blue,
      Colors.redAccent,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pinkAccent,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[label.hashCode % colors.length];
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
            return ListView(
              children: [
                /// This is the container that holds the portfolio value graph, with time period selects.
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
                        /// Portfolio Value Graph
                        const Text(
                          "Networth",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// Total Portfolio Value.
                        Text(
                          _currentBalance.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Porfolio value comparison.
                        Row(
                          children: [
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
                                  euroFormat.format(
                                    _periodChange[_selectedPeriod][0],
                                  ),
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
                                  'CHANGE',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Builder(
                                  builder: (context) {
                                    if (_periodChange[_selectedPeriod][1] -
                                            _periodChange[_selectedPeriod][0] >
                                        0) {
                                      return Text(
                                        "+ ${euroFormat.format(_periodChange[_selectedPeriod][1] - _periodChange[_selectedPeriod][0])}",
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 16,
                                        ),
                                      );
                                    }
                                    if (_periodChange[_selectedPeriod][1] -
                                            _periodChange[_selectedPeriod][0] ==
                                        0) {
                                      return Text(
                                        euroFormat.format(
                                          _periodChange[_selectedPeriod][1] -
                                              _periodChange[_selectedPeriod][0],
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      );
                                    }
                                    return Text(
                                      euroFormat.format(
                                        _periodChange[_selectedPeriod][1] -
                                            _periodChange[_selectedPeriod][0],
                                      ),
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    );
                                  },
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

                /// This is the container that holds the pie chart for the different grouped values.
                Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xFF1E1E2C),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title of the pie chart.
                      const Text(
                        "Distribution",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// The actual pie chart.
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: _getSections(),
                                sectionsSpace: 3,
                                centerSpaceRadius: 50,
                                pieTouchData: PieTouchData(enabled: true),
                                centerSpaceColor: const Color(0xFF1E1E2C),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${_sourceDistribution.length} SOURCES",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),

                      /// Legend for the pie chart.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            _sourceDistribution.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: _colorFromLabel(entry.key),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${entry.key} — ${euroFormat.format(entry.value)}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),

      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.bar_chart),
      //       label: 'Sources',
      //     ),
      //   ],
      //   currentIndex: _selectedPage,
      //   selectedItemColor: Colors.amber[800],
      //   onTap: _onPageSelect,
      // ),
    );
  }
}
