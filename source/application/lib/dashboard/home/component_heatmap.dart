import 'package:application/models/statement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ComponentHeatmap extends StatefulWidget {
  const ComponentHeatmap({super.key});

  @override
  State<ComponentHeatmap> createState() => _ComponentHeatmapState();
}

class _ComponentHeatmapState extends State<ComponentHeatmap> {
  /// Generates the last 210 days (30 weeks) grouped into weeks.
  List<List<DateTime>> generateTrackedWeeks() {
    final now = DateTime.now();
    final totalDays = 7 * 30;
    final startDate = now.subtract(Duration(days: totalDays - 1));
    final days = <DateTime>[];

    for (int i = 0; i < totalDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }

    final weeks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }

    return weeks;
  }

  /// Calculates the daily gains.
  Map<DateTime, double> calculateDailyGains(Map<DateTime, double> totals) {
    final sortedDates = totals.keys.toList()..sort();
    final Map<DateTime, double> gains = {};

    for (int i = 1; i < sortedDates.length; i++) {
      final today = sortedDates[i];
      final yesterday = sortedDates[i - 1];

      final todayValue = totals[today] ?? 0;
      final yesterdayValue = totals[yesterday] ?? 0;

      gains[today] = todayValue - yesterdayValue;
    }

    return gains;
  }

  /// Calculate the daily average.
  Map<String, double> calculateDailyStats(Map<DateTime, double> dailyGains) {
    double total = 0;
    int entryCount = 0;

    double minimum = double.infinity;
    double maximum = double.negativeInfinity;

    dailyGains.forEach((key, value) {
      total += value;
      entryCount += 1;
      if (maximum < value) maximum = value;
      if (minimum > value) minimum = value;
    });

    return {
      "average": total / entryCount,
      "maximum": maximum,
      "minimum": minimum,
    };
  }

  @override
  Widget build(BuildContext context) {
    /// Gets the user statement.
    final statement = Provider.of<Statement>(context);

    final weeks = generateTrackedWeeks();

    /// Calculates the daily gains. Ex: 17 / 05 / 2025 -> +120.00€
    final dailyGains = calculateDailyGains(statement.dailyTotals);
    final sortedDays =
        dailyGains.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Most recent first. Right square.

    /// Calculates the average, min & max of daily gains.
    final dailyStats = calculateDailyStats(dailyGains);

    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xFF1E1E2C),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title for the container.
          const Text(
            "Daily Delta",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 15.0),

          /// Daily delta chart. Heatmap.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  weeks.map((week) {
                    return Column(
                      children:
                          week.map((date) {
                            final day = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                            final yesterday = day.subtract(
                              const Duration(days: 1),
                            );

                            final todayVal = statement.dailyTotals[day];
                            final yesterdayVal =
                                statement.dailyTotals[yesterday];

                            Color color;
                            if (todayVal != null && yesterdayVal != null) {
                              final delta = todayVal - yesterdayVal;
                              if (delta > 0) {
                                color = Colors.green;
                              } else if (delta < 0) {
                                color = Colors.red;
                              } else {
                                color = Colors.grey.shade800;
                              }
                            } else {
                              color = Colors.grey.shade800;
                            }

                            return Container(
                              margin: const EdgeInsets.only(
                                left: 2.1,
                                top: 5.0,
                              ),
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }).toList(),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    "Average / Day",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      if (dailyStats["average"]! > 0) {
                        return Text(
                          "+${statement.formatter.format(dailyStats["average"]!)}",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      } else if (dailyStats["average"]! == 0) {
                        return Text(
                          statement.formatter.format(dailyStats["average"]!),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      } else {
                        return Text(
                          statement.formatter.format(dailyStats["average"]!),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Minimum",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      if (dailyStats["minimum"]! > 0) {
                        return Text(
                          "+${statement.formatter.format(dailyStats["minimum"]!)}",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      } else if (dailyStats["minimum"]! == 0) {
                        return Text(
                          statement.formatter.format(dailyStats["minimum"]!),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      } else {
                        return Text(
                          statement.formatter.format(dailyStats["minimum"]!),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Maximum",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      if (dailyStats["maximum"]! > 0) {
                        return Text(
                          "+${statement.formatter.format(dailyStats["maximum"]!)}",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      } else if (dailyStats["maximum"]! == 0) {
                        return Text(
                          statement.formatter.format(dailyStats["maximum"]!),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      } else {
                        return Text(
                          statement.formatter.format(dailyStats["maximum"]!),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Daily delta overview per day.
          ExpansionTile(
            title: Text(
              "Overview",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            collapsedIconColor: Colors.white54,
            iconColor: Colors.white70,
            textColor: Colors.white,
            childrenPadding: const EdgeInsets.only(top: 10, bottom: 4),
            children:
                sortedDays.map((date) {
                  final value = dailyGains[date]!;
                  final isPositive = value > 0;
                  final isNegative = value < 0;

                  final valueColor =
                      isPositive
                          ? Colors.greenAccent
                          : isNegative
                          ? Colors.redAccent
                          : Colors.grey;

                  final formatted =
                      isPositive
                          ? '+${statement.formatter.format(value)}'
                          : isNegative
                          ? '-${statement.formatter.format(value.abs())}'
                          : statement.formatter.format(0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -3),
                      leading: Icon(Icons.circle, size: 10, color: valueColor),
                      title: Text(
                        DateFormat.yMMMd().format(date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Text(
                        formatted,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
