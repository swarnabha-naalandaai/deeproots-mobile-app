import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class RecordingColors {
  RecordingColors._();
  static const Color stopBg = Color(0xFF7E2525);
  static const Color barColor = Color(0xFFDAC9A3);
  static const Color recRed = Color(0xFFD32020);
  static const Color timerPillBg = Color(0xFFF4E4E4);
}

class RecordingHeader extends StatelessWidget {
  final VoidCallback onBack;

  const RecordingHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFB0A24A), width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Icon(PhosphorIcons.caretLeft(), size: 24, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Record the recipe',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class RecordingWaveform extends StatelessWidget {
  static const _barHeights = [17, 23, 31, 23, 17, 23, 17, 31, 23, 31, 17, 31, 23, 17];

  const RecordingWaveform({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 31,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _barHeights.length; i++) ...[
            Container(
              width: 6,
              height: _barHeights[i].toDouble(),
              decoration: BoxDecoration(
                color: RecordingColors.barColor,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            if (i != _barHeights.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class RecordingProcessingView extends StatelessWidget {
  final String title;

  const RecordingProcessingView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RecordingWaveform(),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Just a moment',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class RecordingReviewButtons extends StatelessWidget {
  final VoidCallback onReRecord;
  final VoidCallback onUse;

  const RecordingReviewButtons({
    super.key,
    required this.onReRecord,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onReRecord,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Re-record',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.1,
              color: AppColors.textTertiary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: onUse,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Use this recording',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RecordingStartButton extends StatelessWidget {
  final VoidCallback onTap;

  const RecordingStartButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: RecordingColors.stopBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 33,
              height: 33,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to start recording',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.1,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class RecordingStopButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color? textColor;

  const RecordingStopButton({super.key, required this.onTap, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: RecordingColors.stopBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to stop recording',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.1,
            color: textColor ?? AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

String formatRecordingTime(Duration elapsed) {
  final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

Map<String, dynamic> dummyRecipeExtraction() {
  return {
    'title': 'Aloo Paratha — my mother\'s way, with extra ghee',
    'caption':
        'Sunday breakfast at home, the kind that makes you sit and not move for two hours after.',
    'ingredients': <String>[
      'Wheat flour — 2 cups',
      'Potatoes — 4 medium, boiled',
      'Green chili — 1 finely chopped',
      'Jeera — 1 tsp, grated',
      'Coriander — small handful, chopped',
      'Cumin seeds — 1 tsp, roasted and crushed',
      'Red chilli powder — 1 tsp',
      'Amchur (dry mango powder) — 1 tsp',
    ],
    'steps': <String>[
      'Knead a soft dough with the flour, a pinch of salt, and water. Rest for 30 minutes.',
      'Mash the boiled potatoes till there are no lumps.',
      'Mix in green chili, ginger, coriander, all the spices and salt. Taste the filling — it should be slightly over-seasoned.',
      'Divide both dough and filling into equal portions, about ping-pong-ball sized.',
    ],
  };
}
