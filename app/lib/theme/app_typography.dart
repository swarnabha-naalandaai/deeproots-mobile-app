import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle logo = GoogleFonts.heptaSlab(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    color: AppColors.ink,
  );

  static TextStyle appBarTitle = logo;

  static TextStyle cardTitle = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static TextStyle authorName = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 18 / 14,
    color: AppColors.ink,
  );

  static TextStyle authorNameLg = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 21 / 16,
    color: AppColors.ink,
  );

  static TextStyle timestamp = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: AppColors.textSecondary,
  );

  static TextStyle description = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 18 / 14,
    color: AppColors.textSecondary,
  );

  static TextStyle meta = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textSecondary,
  );

  static TextStyle metaLabel = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.2 * 12,
    color: AppColors.textSecondary,
  );

  static TextStyle counterPill = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: 0.06 * 12,
    color: Colors.white,
  );

  static TextStyle typePill = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: 0.06 * 12,
    color: AppColors.typePillText,
  );

  static TextStyle tagPill = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.02 * 12,
    color: AppColors.textSecondary,
  );

  static TextStyle tabLabel = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 21 / 16,
    color: AppColors.textTertiary,
  );

  static TextStyle countLabel = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
    color: AppColors.textSecondary,
  );

  static TextStyle readMore = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 21 / 16,
    color: AppColors.textSecondary,
    decoration: TextDecoration.underline,
  );

  static TextStyle avatarLetter = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: Colors.white,
  );

  static TextStyle duration = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 19 / 14,
    color: AppColors.textTertiary,
  );

  static TextStyle annual = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 21 / 16,
    letterSpacing: 0.02 * 16,
    color: AppColors.ink,
  );

}
