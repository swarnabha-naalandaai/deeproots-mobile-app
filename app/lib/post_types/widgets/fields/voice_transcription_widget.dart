import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../../widgets/form/pill_button.dart';
import '../../../widgets/recording_sheet.dart';
import '../../../widgets/voice_preview_bar.dart';
import '../../config/field_config.dart';
import '../../models/recorded_voice_note.dart';

class VoiceTranscriptionWidget extends StatelessWidget {
  final VoiceTranscriptionConfig config;
  final RecordedVoiceNote? value;
  final ValueChanged<RecordedVoiceNote?> onChanged;

  const VoiceTranscriptionWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  Future<void> _record(BuildContext context) async {
    final result = await RecordingSheet.show(
      context,
      title: config.recordTitle,
      transcribe: config.transcribe,
    );
    if (result == null || result.path == null) return;
    onChanged(RecordedVoiceNote(
      path: result.path!,
      duration: result.duration,
      createdAt: DateTime.now(),
      transcript: result.transcript,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final note = value;
    if (note != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VoicePreviewBar(
            filePath: note.path,
            totalHint: note.duration,
            onClose: () => onChanged(null),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              formatRelativeTime(note.createdAt),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PillButton(
          background: FormTokens.recordBg,
          icon: PhosphorIcons.microphone(),
          label: config.recordLabel,
          onTap: () => _record(context),
        ),
        const SizedBox(height: 8),
        Text(
          config.helperText,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: FormTokens.fieldBorder,
          ),
        ),
      ],
    );
  }
}
