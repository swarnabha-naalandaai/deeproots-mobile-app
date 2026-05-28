import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/form/field_label.dart';
import '../../../widgets/form/field_shell.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../config/field_config.dart';

class TagsWidget extends StatefulWidget {
  final TagsConfig config;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  const TagsWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TagsWidget> createState() => _TagsWidgetState();
}

class _TagsWidgetState extends State<TagsWidget> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    widget.onChanged([...widget.value, v]);
    _input.clear();
  }

  void _remove(String label) {
    widget.onChanged(widget.value.where((t) => t != label).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.config.label != null) ...[
          FieldLabel(widget.config.label!, bold: widget.value.isNotEmpty),
          const SizedBox(height: 8),
        ],
        FieldShell(
          child: TextField(
            controller: _input,
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
              fontWeight: FontWeight.w500,
              height: 1.1,
              color: AppColors.ink,
            ),
            onSubmitted: _add,
          ),
        ),
        if (widget.value.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [for (final t in widget.value) _chip(t)],
          ),
        ],
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      height: 24,
      padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
      decoration: BoxDecoration(
        color: AppColors.maroon,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 16 / 12,
              letterSpacing: 0.02 * 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _remove(label),
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.close, size: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
