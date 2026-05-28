import 'package:flutter/material.dart';

class FormTokens {
  FormTokens._();

  static const Color gold = Color(0xFFB0A24A);
  static const Color fieldBg = Color(0xFFF6F6F6);
  static const Color chipBg = Color(0xFFF5F4EE);
  static const Color fieldBorder = Color(0xFF999999);
  static const Color hint = Color(0xFF949494);
  static const Color recordBg = Color(0xFFE5E1CA);
}

String formatRelativeTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
