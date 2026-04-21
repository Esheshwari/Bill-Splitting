import 'package:flutter/material.dart';

class GradientShell extends StatelessWidget {
  const GradientShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0F1720), Color(0xFF122634), Color(0xFF213945)]
              : const [Color(0xFFF7F2E8), Color(0xFFE3F4EF), Color(0xFFF9FBFF)],
        ),
      ),
      child: child,
    );
  }
}

