import 'package:application/models/statement.dart';
import 'package:application/navigation/app_drawer.dart';
import 'package:application/dashboard/home/component_distribution.dart';
import 'package:application/dashboard/home/component_heatmap.dart';
import 'package:application/dashboard/home/component_networth.dart';
import 'package:application/dashboard/sources/component_source.dart';
import 'package:application/dashboard/transactions/component_transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageDashboard extends StatefulWidget {
  const PageDashboard({super.key});

  @override
  State<PageDashboard> createState() => _PageDashboardState();
}

class _PageDashboardState extends State<PageDashboard> {
  int _selectedPage = 0;

  void _onPageSelect(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Gets the user statement.
    final statement = Provider.of<Statement>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color(0xFF040C15),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            children: const [
              TextSpan(text: 'Net', style: TextStyle(color: Colors.white)),
              TextSpan(
                text: 'Worth',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ],
          ),
        ),
      ),

      drawer: AppDrawer(onPageSelect: _onPageSelect),

      body: Builder(
        builder: (context) {
          /// First page, Home.
          if (_selectedPage == 0) {
            return ListView(
              children: [
                /// Networth widget.
                ComponentNetworth(),

                /// Distribution widget.
                ComponentDistribution(),

                // Heatmap widget.
                ComponentHeatmap(),
              ],
            );
          }
          /// Second page, Source Evolution
          else if (_selectedPage == 1) {
            return ListView.builder(
              itemCount: statement.sourceNames.length,

              itemBuilder: (BuildContext context, int index) {
                final sourceName = statement.sourceNames[index];
                final spots = statement.sourceSpotsByName[sourceName]!;

                /// Returns a container with the statistics of a specific source.
                return ComponentSource(sourceName: sourceName, spots: spots);
              },
            );
          }
          /// Third page, Transactions
          else {
            return ComponentTransactionList();
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
