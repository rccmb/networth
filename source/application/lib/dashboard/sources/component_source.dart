import 'package:application/dashboard/widget_container.dart';
import 'package:application/models/statement.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComponentSource extends StatefulWidget {
  final String sourceName;
  final List<List<FlSpot>> spots;

  const ComponentSource({
    super.key,
    required this.sourceName,
    required this.spots,
  });

  @override
  State<ComponentSource> createState() => _ComponentSourceState();
}

class _ComponentSourceState extends State<ComponentSource> {
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

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final statement = Provider.of<Statement>(context);
    final double start =
        widget.spots[_selectedPeriod].length >= 2
            ? widget.spots[_selectedPeriod][1].y
            : 0;
    final double end =
        widget.spots[_selectedPeriod].isNotEmpty
            ? widget.spots[_selectedPeriod].last.y
            : 0;
    final double change = end - start;

    return WidgetContainer(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/logos/${widget.sourceName.toUpperCase()}.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sourceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      statement.formatter.format(end),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white54,
              ),
            ],
          ),

          if (_expanded) ...[
            const SizedBox(height: 16),

            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'START',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statement.formatter.format(start),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHANGE',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${change >= 0 ? "+" : ""}${statement.formatter.format(change)}",
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            change > 0
                                ? Colors.greenAccent
                                : (change < 0 ? Colors.redAccent : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 60,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            statement.formatter.format(spot.y),
                            TextStyle(color: spot.bar.color),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.spots[_selectedPeriod],
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.lightBlueAccent,
                      gradient: LinearGradient(
                        colors: [Colors.lightBlueAccent, Colors.blueAccent],
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

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
        ],
      ),
    );
  }
}
