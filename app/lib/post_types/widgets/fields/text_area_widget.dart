import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/form/field_label.dart';
import '../../../widgets/form/field_shell.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../config/field_config.dart';

class TextAreaWidget extends StatefulWidget {
  final TextAreaConfig config;
  final String value;
  final ValueChanged<String> onChanged;

  const TextAreaWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TextAreaWidget> createState() => _TextAreaWidgetState();
}

class _TextAreaWidgetState extends State<TextAreaWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(() => widget.onChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.config.label != null) ...[
          FieldLabel(widget.config.label!),
          const SizedBox(height: 8),
        ],
        FieldShell(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: widget.config.height,
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration.collapsed(
                hintText: widget.config.hint,
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: FormTokens.hint,
                ),
              ),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
