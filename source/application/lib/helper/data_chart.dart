import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<Map<String, dynamic>> generateMockStatements({
  int days = 730,
  double initialBalance = 3333.0, // Per source.
  List<String> sources = const ['DEGIRO', 'XTB', 'CGD'],
  double maxDailyChange = 0.05,
  int maxRunId = 1000,
}) {
  final random = Random();
  final List<Map<String, dynamic>> data = [];

  for (final source in sources) {
    DateTime date = DateTime.now().subtract(Duration(days: days));
    double balance = initialBalance;
    int runId = 1;

    for (int i = 0; i < days && runId <= maxRunId; i++) {
      final isDownturn = random.nextBool();

      final dailyGrowth = pow(1.08, 1 / 365.0); // About 8% Annual growth.
      final changePercent =
          (random.nextDouble() * maxDailyChange * 2) - maxDailyChange;
      final multiplier =
          (isDownturn ? (1.0 - changePercent) : (1.0 + changePercent)) *
          dailyGrowth;

      balance = (balance * multiplier).clamp(0.0, double.infinity);

      balance = double.parse(balance.toStringAsFixed(2));

      data.add({
        'id': 0, // Not important.
        'source': source,
        'balance': balance,
        'date': date.toIso8601String(),
        'run_id': runId++,
      });

      date = date.add(const Duration(days: 1));
    }
  }

  return data;
}

/// Function that will connect to the database and fetch chart data.
Future<
  ({
    double currentBalance,
    List<List<FlSpot>> periodSpots,
    List<List<double>> periodChange,
    Map<String, double> sourceDistribution,
    Map<String, List<FlSpot>> sourceSpotsByName,
    Map<String, List<List<FlSpot>>> sourcePeriodSpotsByName,
    Map<DateTime, double> dailyTotals,
  })
>
fetchAndProcessChartData() async {
  // final response = await Supabase.instance.client
  //     .from('daily_source_balance')
  //     .select()
  //     .order('date');

  final response = generateMockStatements();

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

  final Map<String, List<List<FlSpot>>> sourcePeriodSpotsByName = {};
  final Map<String, List<List<double>>> sourcePeriodChangesByName = {};

  for (final entry in sourceRawPoints.entries) {
    final source = entry.key;
    final data =
        entry.value..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
        );

    final now = DateTime.now();
    final periodRawPoints = {
      0: <Map<String, dynamic>>[], // 1W
      1: <Map<String, dynamic>>[], // 1M
      2: <Map<String, dynamic>>[], // 3M
      3: <Map<String, dynamic>>[], // YTD
      4: <Map<String, dynamic>>[], // 1Y
      5: <Map<String, dynamic>>[], // MAX
    };

    for (final point in data) {
      final date = point['date'] as DateTime;
      if (date.isAfter(now.subtract(Duration(days: 7)))) {
        periodRawPoints[0]!.add(point);
      }
      if (date.isAfter(now.subtract(Duration(days: 30)))) {
        periodRawPoints[1]!.add(point);
      }
      if (date.isAfter(now.subtract(Duration(days: 90)))) {
        periodRawPoints[2]!.add(point);
      }
      if (date.year == now.year) {
        periodRawPoints[3]!.add(point);
      }
      if (date.isAfter(now.subtract(Duration(days: 365)))) {
        periodRawPoints[4]!.add(point);
      }
      periodRawPoints[5]!.add(point); // MAX
    }

    final List<List<FlSpot>> periodSpots = List.filled(6, []);
    final List<List<double>> periodChange = List.generate(6, (_) => [0, 0]);

    for (int i = 0; i < 6; i++) {
      final rawList = periodRawPoints[i]!;
      final List<FlSpot> spots = [];

      for (int j = 0; j < rawList.length; j++) {
        final y = rawList[j]['balance'] as double;
        if (j == 0) periodChange[i][0] = y;
        if (j == rawList.length - 1) periodChange[i][1] = y;
        spots.add(FlSpot(j.toDouble(), y));
      }
      periodSpots[i] = spots;
    }

    sourcePeriodSpotsByName[source] = periodSpots;
    sourcePeriodChangesByName[source] = periodChange;
  }

  final Map<String, List<FlSpot>> sourceSpotsByName = {};

  for (final entry in sourceRawPoints.entries) {
    final source = entry.key;
    final data =
        entry.value..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
        );

    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]['balance']));
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

  final currentBalance = points.last['y'] as double;

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
    final List<FlSpot> spots = [];
    for (int j = 0; j < rawList.length; j++) {
      final y = rawList[j]['y'] as double;
      if (j == 0) periodChange[i][0] = y;
      if (j == rawList.length - 1) periodChange[i][1] = y;
      spots.add(FlSpot(j.toDouble(), y));
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

  final Map<DateTime, Map<String, dynamic>> latestRunPerDay = {};

  for (final entry in groupedByRun.entries) {
    final rows = entry.value;
    final latestTimestamp = rows
        .map((e) => DateTime.parse(e['date']))
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final day = DateTime(
      latestTimestamp.year,
      latestTimestamp.month,
      latestTimestamp.day,
    );

    final existing = latestRunPerDay[day];
    if (existing == null ||
        latestTimestamp.isAfter(existing['timestamp'] as DateTime)) {
      latestRunPerDay[day] = {'timestamp': latestTimestamp, 'rows': rows};
    }
  }

  final Map<DateTime, double> dailyTotals = {};

  for (final entry in latestRunPerDay.entries) {
    final rows = entry.value['rows'] as List<Map<String, dynamic>>;
    final day = entry.key;

    final total = rows.fold<double>(
      0,
      (sum, e) => sum + (e['balance'] as num).toDouble(),
    );

    dailyTotals[day] = total;
  }

  return (
    currentBalance: currentBalance,
    periodSpots: periodSpots,
    periodChange: periodChange,
    sourceDistribution: sourceDistribution,
    sourceSpotsByName: sourceSpotsByName,
    sourcePeriodSpotsByName: sourcePeriodSpotsByName,
    dailyTotals: dailyTotals,
  );
}
