import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      alignment: Alignment.center,
      child: Text('Deeproots', style: AppTypography.logo),
    );
  }
}
