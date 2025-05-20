import 'package:application/dashboard/widget_container.dart';
import 'package:application/models/statement.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComponentDistribution extends StatefulWidget {
  const ComponentDistribution({super.key});

  @override
  State<ComponentDistribution> createState() => _ComponentDistributionState();
}

class _ComponentDistributionState extends State<ComponentDistribution> {
  /// Gets the ordered entries of the source distribution map.
  List<MapEntry<String, double>> _getOrderedEntries(
    Map<String, double> distribution,
  ) {
    final total = distribution.values.fold(0.0, (a, b) => a + b);
    final entries = distribution.entries.toList();

    entries.sort((a, b) => (b.value / total).compareTo(a.value / total));

    return entries;
  }

  /// Helper method to get the sections for the pie chart.
  List<PieChartSectionData> _getSections(
    List<MapEntry<String, double>> orderedEntries,
  ) {
    final total = orderedEntries.fold(0.0, (sum, entry) => sum + entry.value);

    return orderedEntries.map((entry) {
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
      Color(0xFF0D47A1), // Deep Blue (Blue[900])
      Color(0xFF1565C0), // Blue[800]
      Color(0xFF1976D2), // Blue[700]
      Color(0xFF1E88E5), // Blue[600]
      Color(0xFF2196F3), // Blue[500] - default blue
      Color(0xFF42A5F5), // Blue[400]
      Color(0xFF64B5F6), // Blue[300]
      Color(0xFF81D4FA), // Light Blue[300]
      Color(0xFF00BCD4), // Cyan[500]
      Color(0xFF26C6DA), // Cyan[400]
      Color(0xFF4DD0E1), // Cyan[300]
      Color(0xFF80DEEA), // Cyan[200]
    ];
    return colors[label.hashCode % colors.length];
  }

  /// This is the widget that holds the pie chart for the different grouped values.
  @override
  Widget build(BuildContext context) {
    /// Gets the user statement.
    final statement = Provider.of<Statement>(context);
    final orderedEntries = _getOrderedEntries(statement.sourceDistribution);

    return WidgetContainer(
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
                    sections: _getSections(orderedEntries),
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
                    "${statement.sourceDistribution.length} SOURCES",
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
                orderedEntries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        // Color indicator box.
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: _colorFromLabel(entry.key),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Label.
                        Expanded(
                          flex: 4,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        // Value.
                        SizedBox(
                          width: 120,
                          child: Text(
                            statement.formatter.format(entry.value),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Percentage.
                        SizedBox(
                          width: 60,
                          child: Text(
                            "${((entry.value / statement.networth) * 100).toStringAsFixed(2)}%",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFF81D4FA),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
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
