import 'package:application/helper/database.dart';
import 'package:application/home/component_distribution.dart';
import 'package:application/home/component_heatmap.dart';
import 'package:application/home/component_networth.dart';
import 'package:application/sources/component_source.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  /// Currently selected page.
  int _selectedPage = 0;

  /// Change the page.
  void _onPageSelect(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  /// Euro formatter.
  final _euroFormat = NumberFormat.simpleCurrency(locale: 'pt_PT', name: 'EUR');

  /// Current balance.
  String _currentBalance = "";

  /// Is the dashboard loading.
  bool _isLoading = true;

  /// Array with the data that will be displayed in the chart.
  final List<List<FlSpot>> _periodSpots = List.filled(6, []);

  /// Source spots grouped by name to be used in individual sources.
  Map<String, List<FlSpot>> _sourceSpotsByName = {};

  /// Names of the sources.
  List<String> _sourceNames = [];

  /// Period changes for the networth texts. [PERIOD][START, NOW].
  final List<List<double>> _periodChange = List.filled(6, [0, 0]);

  /// The distribution of wealth per source { SOURCE, WEALTH }
  Map<String, double> _sourceDistribution = {};

  Map<DateTime, double> _dailyTotals = {};

  /// Populating _periodSpots with the correct data.
  Future<void> _loadChartData() async {
    final result = await fetchAndProcessChartData(_euroFormat);

    setState(() {
      _currentBalance = result.currentBalance;
      _sourceDistribution = result.sourceDistribution;
      _sourceSpotsByName = result.sourceSpotsByName;
      _sourceNames = _sourceSpotsByName.keys.toList();
      for (int i = 0; i < 6; i++) {
        _periodSpots[i] = result.periodSpots[i];
        _periodChange[i] = result.periodChange[i];
      }
      _dailyTotals = result.dailyTotals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Networth")),
      body: Builder(
        builder: (context) {
          if (_isLoading == true) {
            return Text("Loading...");
          } else {
            /// First page, Home.
            if (_selectedPage != 1) {
              return ListView(
                children: [
                  /// Networth widget.
                  ComponentNetworth(
                    currentBalance: _currentBalance,
                    euroFormat: _euroFormat,
                    periodSpots: _periodSpots,
                    periodChange: _periodChange,
                  ),

                  /// Distribution widget.
                  ComponentDistribution(
                    sourceDistribution: _sourceDistribution,
                    euroFormat: _euroFormat,
                  ),

                  // Heatmap widget.
                  ComponentHeatmap(
                    dailyTotals: _dailyTotals,
                    euroFormat: _euroFormat,
                  ),
                ],
              );
            }
            /// Second page, Source Evolution
            else {
              return ListView.builder(
                itemCount: _sourceNames.length,
                itemBuilder: (BuildContext context, int index) {
                  final sourceName = _sourceNames[index];
                  final spots = _sourceSpotsByName[sourceName]!;
                  return ComponentSource(
                    sourceName: sourceName,
                    spots: spots,
                    euroFormat: _euroFormat,
                  );
                },
              );
            }
          }
        },
      ),

      /// Bottom navigation bar has two options:
      /// - Home (Networth & Distribution)
      /// - Source Evolution (Individual Source Graphing)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Sources',
          ),
        ],
        currentIndex: _selectedPage,
        selectedItemColor: Colors.lightBlueAccent,
        onTap: _onPageSelect,
      ),
    );
  }
}
