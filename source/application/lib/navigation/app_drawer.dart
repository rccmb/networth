import 'package:application/calculator/page_calculator.dart';
import 'package:application/index.dart';
import 'package:application/navigation/route_builder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDrawer extends StatelessWidget {
  final double networth;
  final NumberFormat euroFormat;
  final void Function(int)? onPageSelect;

  const AppDrawer({
    super.key,
    required this.networth,
    required this.euroFormat,
    this.onPageSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF040C15),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF040C15)),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.area_chart, color: Colors.white),
            title: const Text(
              'Dashboard',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              if (onPageSelect != null) {
                // If not in the initial page, bottom navigation, go to it.
                onPageSelect!(0);
              } else {
                Navigator.pushReplacement(
                  context,
                  createSlideRoute(PageDashboard()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate, color: Colors.white),
            title: const Text(
              'Calculator',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                createSlideRoute(
                  PageCalculator(networth: networth, euroFormat: euroFormat),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
