import 'package:application/dashboard/page_dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
