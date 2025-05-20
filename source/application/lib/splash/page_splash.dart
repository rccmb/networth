import 'package:application/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:application/models/statement.dart';
import 'package:application/helper/data_chart.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageSplash extends StatefulWidget {
  const PageSplash({super.key});

  @override
  State<PageSplash> createState() => _PageSplashState();
}

class _PageSplashState extends State<PageSplash> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load secrets.
    final jsonSecrets = await rootBundle.loadString('assets/secrets.json');
    final secrets = json.decode(jsonSecrets);

    // Initialize Supabase.
    await Supabase.initialize(
      url: secrets["supabase_url"],
      anonKey: secrets["supabase_key"],
    );

    // Build Statement and populate it.
    final statement = Statement();
    final chartResult = await fetchAndProcessChartData();

    statement.networth = chartResult.currentBalance;
    statement.sourceDistribution = chartResult.sourceDistribution;
    statement.sourceNames = chartResult.sourceSpotsByName.keys.toList();
    statement.sourcePeriodSpotsByName = chartResult.sourcePeriodSpotsByName;
    statement.dailyTotals = chartResult.dailyTotals;

    for (int i = 0; i < 6; i++) {
      statement.periodSpots[i] = chartResult.periodSpots[i];
      statement.periodChange[i] = chartResult.periodChange[i];
    }

    // Wait a little so spinner isn't just a flash
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to main app with statement provided
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider.value(
              value: statement,
              child: const MainApp(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF040C15),
      body: Center(child: CircularProgressIndicator(color: Colors.cyan)),
    );
  }
}
