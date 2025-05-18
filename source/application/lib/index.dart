import 'package:application/calculator/page_calculator.dart';
import 'package:application/navigation/app_drawer.dart';
import 'package:application/helper/data_chart.dart';
import 'package:application/home/component_distribution.dart';
import 'package:application/home/component_heatmap.dart';
import 'package:application/home/component_networth.dart';
import 'package:application/sources/component_source.dart';
import 'package:application/transactions/component_transaction_list.dart';
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
    _loadData();
  }

  /// Currently selected page.
  int _selectedPage = 0;

  /// Euro formatter.
  final _euroFormat = NumberFormat.simpleCurrency(locale: 'pt_PT', name: 'EUR');

  /// Current balance.
  double _currentBalance = 0.0;

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

  /// Daily total values.
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
    });
  }

  /// Method responsible for loading relevant data.
  Future<void> _loadData() async {
    await Future.wait([_loadChartData()]);
    setState(() {
      _isLoading = false;
    });
  }

  /// Change the page.
  void _onPageSelect(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Networth"),
        backgroundColor: const Color(0xFF040C15),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),

      drawer: AppDrawer(
        networth: _currentBalance,
        euroFormat: _euroFormat,
        onPageSelect: _onPageSelect,
      ),

      body: Builder(
        builder: (context) {
          if (_isLoading == true) {
            return Text("Loading...");
          } else {
            /// First page, Home.
            if (_selectedPage == 0) {
              return ListView(
                children: [
                  /// Networth widget.
                  ComponentNetworth(
                    currentBalance: _euroFormat.format(_currentBalance),
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
            else if (_selectedPage == 1) {
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
            /// Third page, Transactions
            else {
              return ComponentTransactionList(euroFormat: _euroFormat);
            }
          }
        },
      ),

      /// Bottom navigation bar has two options:
      /// - Home (Networth & Distribution)
      /// - Source Evolution (Individual Source Graphing)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Sources',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Transactions',
            backgroundColor: Colors.white,
          ),
        ],
        backgroundColor: const Color(0xFF040C15),
        currentIndex: _selectedPage,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.white70,
        onTap: _onPageSelect,
      ),
    );
  }
}
