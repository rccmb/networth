import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Statement extends ChangeNotifier {
  /// Formatter for usage in the application.
  NumberFormat formatter = NumberFormat.simpleCurrency(
    locale: 'pt_PT',
    name: 'EUR',
  );

  /// Current user networth.
  double networth = 0.0;

  /// Array with the data that will be displayed in the networth chart.
  List<List<FlSpot>> periodSpots = List.filled(6, []);

  /// Period changes for the networth texts. [PERIOD][START, NOW]. Stores all of the chart spots.
  final List<List<double>> periodChange = List.filled(6, [0, 0]);

  /// Source spots grouped by name to be used in individual sources.
  Map<String, List<FlSpot>> sourceSpotsByName = {};

  /// The distribution of wealth per source { SOURCE, WEALTH }, to be used in the pie chart.
  Map<String, double> sourceDistribution = {};

  /// Names of the sources, ex: Degiro, CGD, XTB...
  List<String> sourceNames = [];

  /// Daily total values. To be used in the daily delta heatmap.
  Map<DateTime, double> dailyTotals = {};
}
