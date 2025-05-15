import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComponentDistribution extends StatefulWidget {
  final Map<String, double> sourceDistribution;
  final NumberFormat euroFormat;

  const ComponentDistribution({
    super.key,
    required this.sourceDistribution,
    required this.euroFormat,
  });

  @override
  State<ComponentDistribution> createState() => _ComponentDistributionState();
}

class _ComponentDistributionState extends State<ComponentDistribution> {
  /// Helper method to get the sections for the pie chart.
  List<PieChartSectionData> _getSections() {
    final total = widget.sourceDistribution.values.fold(0.0, (a, b) => a + b);

    return widget.sourceDistribution.entries.map((entry) {
      final percentage = entry.value / total;

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

  /// This is the widget that holds the pie chart for the different grouped values.
  @override
  Widget build(BuildContext context) {
    return Container(
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
                    "${widget.sourceDistribution.length} SOURCES",
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
                widget.sourceDistribution.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
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
                          "${entry.key} — ${widget.euroFormat.format(entry.value)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
