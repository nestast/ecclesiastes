import 'package:flutter/material.dart';

class DashboardTheme {
  DashboardTheme._();

  static const navy = Color(0xFF004A99);
  static const blue = Color(0xFF1565C0);
  static const background = Color(0xFFF4F6F9);
  static const cardRadius = 16.0;

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
