import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../screens/recipe_record_screen.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../config/field_config.dart';

class RecipeRecordWidget extends StatelessWidget {
  final RecipeRecordConfig config;
  final RecipeRecordResult? value;
  final ValueChanged<RecipeRecordResult?> onChanged;
  final void Function(Map<String, dynamic> fields)? onBulkChanged;

  const RecipeRecordWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
    this.onBulkChanged,
  });

  Future<void> _openVoiceRecord(BuildContext context) async {
    final result = await RecipeRecordScreen.open(context);
    if (result == null) return;
    onChanged(result);
    if (result.extractedFields.isNotEmpty && onBulkChanged != null) {
      onBulkChanged!(result.extractedFields);
    }
  }

  void _showVideoStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video recording coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (value != null) return _extractedBanner(context);
    return _recordButtons(context);
  }

  Widget _recordButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _pillBtn(
                icon: PhosphorIcons.sparkle(),
                label: config.voiceLabel,
                onTap: () => _openVoiceRecord(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _pillBtn(
                icon: PhosphorIcons.videoCamera(),
                label: config.videoLabel,
                onTap: () => _showVideoStub(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          config.subtitle,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            height: 20 / 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _pillBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: FormTokens.recordBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 21 / 14,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _extractedBanner(BuildContext context) {
    final dur = value!.duration;
    final m = dur.inMinutes;
    final s = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    final timeStr = '$m:$s';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 16),
      decoration: BoxDecoration(
        color: FormTokens.recordBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(PhosphorIcons.sparkle(), size: 20, color: AppColors.ink),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Extracted from your $timeStr voice recording. Edit anything before posting.',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 21 / 16,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
