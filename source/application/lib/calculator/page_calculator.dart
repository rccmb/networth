import 'package:application/navigation/app_drawer.dart';
import 'package:flutter/material.dart';

class PageCalculator extends StatefulWidget {
  const PageCalculator({super.key});

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
      drawer: AppDrawer(),
    );
  }
}
