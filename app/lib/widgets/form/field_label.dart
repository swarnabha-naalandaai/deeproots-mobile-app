import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  final bool bold;

  const FieldLabel(this.text, {super.key, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        height: 1.1,
        color: AppColors.textPrimary,
      ),
    );
  }
}
