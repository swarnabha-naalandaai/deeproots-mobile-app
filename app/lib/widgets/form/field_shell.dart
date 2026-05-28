import 'package:flutter/material.dart';
import 'form_tokens.dart';

class FieldShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const FieldShell({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FormTokens.fieldBg,
        border: Border.all(color: FormTokens.fieldBorder, width: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}
