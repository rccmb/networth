import 'package:application/navigation/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PageCalculator extends StatefulWidget {
  final double networth;
  final NumberFormat euroFormat;

  const PageCalculator({
    super.key,
    required this.networth,
    required this.euroFormat,
  });

  @override
  State<PageCalculator> createState() => _PageCalculatorState();
}

class _PageCalculatorState extends State<PageCalculator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040C15),
      appBar: AppBar(
        backgroundColor: const Color(0xFF040C15),
        title: const Text('Calculator', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        networth: widget.networth,
        euroFormat: widget.euroFormat,
      ),
    );
  }
}
