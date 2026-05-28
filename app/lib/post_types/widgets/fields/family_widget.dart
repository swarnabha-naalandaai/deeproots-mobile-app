import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/form/field_label.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../config/field_config.dart';

class FamilyWidget extends StatefulWidget {
  final FamilyConfig config;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  const FamilyWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  State<FamilyWidget> createState() => _FamilyWidgetState();
}

class _FamilyWidgetState extends State<FamilyWidget> {
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _editing = false;

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _editing = true;
      _input.text = '@';
      _input.selection = TextSelection.collapsed(offset: _input.text.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _commit(String value) {
    final cleaned = value.replaceFirst(RegExp(r'^@+'), '').trim();
    setState(() {
      _editing = false;
      _input.clear();
    });
    if (cleaned.isEmpty || widget.value.contains(cleaned)) return;
    widget.onChanged([...widget.value, cleaned]);
  }

  void _remove(String name) {
    widget.onChanged(widget.value.where((n) => n != name).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.config.label != null) ...[
          FieldLabel(widget.config.label!, bold: widget.value.isNotEmpty),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in widget.value) _chip(name),
            _addOrInput(),
          ],
        ),
      ],
    );
  }

  Widget _chip(String name) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: FormTokens.chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 21 / 16,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _remove(name),
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.close, size: 16, color: Color(0xFF5F5F5F)),
          ),
        ],
      ),
    );
  }

  Widget _addOrInput() {
    if (_editing) return _inputPill();
    return Material(
      color: FormTokens.chipBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _start,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          alignment: Alignment.center,
          child: Text(
            widget.value.isEmpty ? widget.config.emptyLabel : '+',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 21 / 16,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputPill() {
    return Container(
      height: 44,
      constraints: const BoxConstraints(minWidth: 44, maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: FormTokens.chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicWidth(
        child: TextField(
          controller: _input,
          focusNode: _focus,
          autofocus: true,
          textAlign: TextAlign.center,
          cursorColor: AppColors.ink,
          decoration: const InputDecoration.collapsed(hintText: ''),
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 21 / 16,
            color: AppColors.ink,
          ),
          onSubmitted: _commit,
          onTapOutside: (_) => _commit(_input.text),
        ),
      ),
    );
  }
}
