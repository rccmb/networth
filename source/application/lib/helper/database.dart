import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Function that will connect to the database and fetch chart data.
Future<
  ({
    String currentBalance,
    List<List<FlSpot>> periodSpots,
    List<List<double>> periodChange,
    Map<String, double> sourceDistribution,
    Map<String, List<FlSpot>> sourceSpotsByName,
  })
>
fetchAndProcessChartData(NumberFormat euroFormat) async {
  final response = await Supabase.instance.client
      .from('daily_source_balance')
      .select()
      .order('date');

  final Map<String, List<Map<String, dynamic>>> sourceRawPoints = {};
  for (final row in response) {
    final source = row['source'];
    final dateStr = row['date'];
    final balance = row['balance'];

    if (source == null || balance == null || dateStr == null) continue;

    final date = DateTime.parse(dateStr);
    sourceRawPoints.putIfAbsent(source, () => []).add({
      'date': date,
      'balance': (balance as num).toDouble(),
    });
  }

  final Map<String, List<FlSpot>> sourceSpotsByName = {};

  for (final entry in sourceRawPoints.entries) {
    final source = entry.key;
    final data =
        entry.value..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
        );

    final List<FlSpot> spots = [FlSpot(0, 0)];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble() + 1, data[i]['balance']));
    }
    sourceSpotsByName[source] = spots;
  }

  final Map<int, List<Map<String, dynamic>>> groupedByRun = {};
  for (final row in response) {
    final runId = row['run_id'];
    if (runId == null || row['balance'] == null || row['date'] == null) {
      continue;
    }
    groupedByRun.putIfAbsent(runId, () => []).add(row);
  }

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
        }).toList()
        ..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
        );

  final currentBalance =
      points.isNotEmpty
          ? euroFormat.format(points.last['y'] as double)
          : euroFormat.format(0);

  final Map<int, List<Map<String, dynamic>>> periodRawPoints = {
    0: [], // 1W
    1: [], // 1M
    2: [], // 3M
    3: [], // YTD
    4: [], // 1Y
    5: [], // MAX
  };

  final now = DateTime.now();

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

  final List<List<FlSpot>> periodSpots = List.filled(6, []);
  final List<List<double>> periodChange = List.generate(6, (_) => [0, 0]);

  for (int i = 0; i < 6; i++) {
    final rawList = periodRawPoints[i]!;
    final List<FlSpot> spots = [FlSpot(0, 0)];
    for (int j = 0; j < rawList.length; j++) {
      final y = rawList[j]['y'] as double;
      if (j == 0) periodChange[i][0] = y;
      if (j == rawList.length - 1) periodChange[i][1] = y;
      spots.add(FlSpot(j.toDouble() + 1, y));
    }
    periodSpots[i] = spots;
  }

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

  final Map<String, double> sourceDistribution = {};
  for (final row in groupedByRun[latestRunId]!) {
    final source = row['source'] as String?;
    final balance = row['balance'];
    if (source == null || balance == null) continue;
    sourceDistribution[source] =
        (sourceDistribution[source] ?? 0) + (balance as num).toDouble();
  }

  return (
    currentBalance: currentBalance,
    periodSpots: periodSpots,
    periodChange: periodChange,
    sourceDistribution: sourceDistribution,
    sourceSpotsByName: sourceSpotsByName,
  );
}
