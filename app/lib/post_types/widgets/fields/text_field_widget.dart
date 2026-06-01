import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/form/field_label.dart';
import '../../../widgets/form/field_shell.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../config/field_config.dart';

class TextFieldWidget extends StatefulWidget {
  final TextFieldConfig config;
  final String value;
  final ValueChanged<String> onChanged;

  const TextFieldWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(() => widget.onChanged(_controller.text));
  }

  @override
  void didUpdateWidget(TextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
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
          child: TextField(
            controller: _controller,
            decoration: InputDecoration.collapsed(
              hintText: widget.config.hint,
              hintStyle: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
                letterSpacing: 0.02 * 16,
                color: FormTokens.hint,
              ),
            ),
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: 0.02 * 16,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
