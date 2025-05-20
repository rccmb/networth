import 'package:flutter/material.dart';

class WidgetContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const WidgetContainer({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    /// The ripple effect needs to be drawn on an Ink.
    final decoratedContent = Ink(
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
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );

    /// Return the static.
    if (onTap == null) return decoratedContent;

    /// Return with the ripple (touched).
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.cyan.withValues(alpha: 0.2),
        highlightColor: Colors.transparent,
        child: decoratedContent,
      ),
    );
  }
}
