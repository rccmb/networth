import 'package:application/models/statement.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComponentSource extends StatelessWidget {
  final String sourceName;
  final List<FlSpot> spots;

  const ComponentSource({
    super.key,
    required this.sourceName,
    required this.spots,
  });

  @override
  Widget build(BuildContext context) {
    /// Gets the user statement.
    final statement = Provider.of<Statement>(context);

    final double start = spots.length >= 2 ? spots[1].y : 0;
    final double end = spots.isNotEmpty ? spots.last.y : 0;
    final double change = end - start;

    return Container(
      margin: const EdgeInsets.only(
        right: 15.0,
        left: 15.0,
        top: 5.0,
        bottom: 5.0,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xFF1E1E2C),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo container.
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
                    'assets/logos/${sourceName.toUpperCase()}.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Source name and value.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sourceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    statement.formatter.format(end),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Start and change values.
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
                              : (change < 0 ? Colors.red : Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Line Chart.
          SizedBox(
            height: 50,
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
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    barWidth: 3,
                    color: Colors.lightBlueAccent,
                    gradient: LinearGradient(
                      colors: [Colors.lightBlueAccent, Colors.blueAccent],
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.lightBlueAccent.withValues(alpha: 0.2),
                          Colors.lightBlueAccent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
