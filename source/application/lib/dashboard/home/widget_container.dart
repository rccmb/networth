import 'package:flutter/material.dart';

class WidgetContainer extends StatelessWidget {
  final Widget child;

  const WidgetContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF12121D),
            Color(0xFF1A1A2B),
            Color(0xFF202030),
            Color(0xFF272738),
            Color(0xFF2F2F44),
          ],
          stops: [0.0, 0.3, 0.55, 0.75, 1.0],
        ),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 0.1,
          ),
        ],
      ),
      child: child,
    );
  }
}
