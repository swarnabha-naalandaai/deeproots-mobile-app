import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/form/field_label.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../../widgets/form/pill_button.dart';
import '../../../widgets/recording_sheet.dart';
import '../../../widgets/voice_preview_bar.dart';
import '../../config/field_config.dart';
import '../../models/recorded_voice_note.dart';

class VoiceNotesWidget extends StatelessWidget {
  final VoiceNotesConfig config;
  final List<RecordedVoiceNote> value;
  final ValueChanged<List<RecordedVoiceNote>> onChanged;

  const VoiceNotesWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  Future<void> _record(BuildContext context) async {
    final result = await RecordingSheet.show(
      context,
      title: config.recordTitle,
    );
    if (result == null || result.path == null) return;
    onChanged([
      ...value,
      RecordedVoiceNote(
        path: result.path!,
        duration: result.duration,
        createdAt: DateTime.now(),
        transcript: result.transcript,
      ),
    ]);
  }

  void _remove(RecordedVoiceNote note) {
    onChanged(value.where((n) => n != note).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.label != null) ...[
          FieldLabel(config.label!, bold: value.isNotEmpty),
          const SizedBox(height: 12),
        ],
        PillButton(
          background: FormTokens.fieldBg,
          icon: PhosphorIcons.microphone(),
          label: config.addLabel,
          onTap: () => _record(context),
        ),
        for (final note in value) ...[
          const SizedBox(height: 8),
          VoicePreviewBar(
            filePath: note.path,
            totalHint: note.duration,
            onClose: () => _remove(note),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              formatRelativeTime(note.createdAt),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
