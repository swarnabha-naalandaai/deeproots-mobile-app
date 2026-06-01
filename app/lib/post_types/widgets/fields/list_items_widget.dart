import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/form/field_label.dart';
import '../../../widgets/form/field_shell.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../config/field_config.dart';

class ListItemsWidget extends StatefulWidget {
  final ListItemsConfig config;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  const ListItemsWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ListItemsWidget> createState() => _ListItemsWidgetState();
}

class _ListItemsWidgetState extends State<ListItemsWidget> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(ListItemsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.length != _controllers.length) {
      _syncControllers();
    }
  }

  void _syncControllers() {
    while (_controllers.length > widget.value.length) {
      _controllers.removeLast().dispose();
      _focusNodes.removeLast().dispose();
    }
    for (var i = 0; i < widget.value.length; i++) {
      if (i < _controllers.length) {
        if (_controllers[i].text != widget.value[i]) {
          _controllers[i].text = widget.value[i];
        }
      } else {
        _controllers.add(TextEditingController(text: widget.value[i]));
        _focusNodes.add(FocusNode());
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onItemChanged(int index, String text) {
    final updated = List<String>.from(widget.value);
    updated[index] = text;
    widget.onChanged(updated);
  }

  void _removeItem(int index) {
    _controllers[index].dispose();
    _controllers.removeAt(index);
    _focusNodes[index].dispose();
    _focusNodes.removeAt(index);
    final updated = List<String>.from(widget.value)..removeAt(index);
    widget.onChanged(updated);
  }

  void _addItem() {
    final updated = List<String>.from(widget.value)..add('');
    _controllers.add(TextEditingController());
    final node = FocusNode();
    _focusNodes.add(node);
    widget.onChanged(updated);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.length > widget.value.length - 1) {
        node.requestFocus();
      }
    });
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
        for (var i = 0; i < widget.value.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _itemRow(i),
        ],
        if (widget.value.isNotEmpty) const SizedBox(height: 8),
        _addButton(),
      ],
    );
  }

  Widget _itemRow(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FieldShell(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              onChanged: (v) => _onItemChanged(index, v),
              maxLines: null,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 22 / 14,
                color: AppColors.ink,
              ),
              decoration: InputDecoration.collapsed(
                hintText: widget.config.hint,
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                  letterSpacing: 0.02 * 14,
                  color: FormTokens.hint,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _removeItem(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Icon(
              PhosphorIcons.x(),
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: _addItem,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          widget.config.addLabel,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: FormTokens.addLink,
          ),
        ),
      ),
    );
  }
}
