import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/form/form_tokens.dart';
import '../config/post_type_config.dart';
import '../widgets/form_renderer.dart';

class CreatePostScreen extends StatefulWidget {
  final PostTypeConfig config;
  final Map<String, dynamic>? initialValues;
  final String? headerOverride;

  const CreatePostScreen({
    super.key,
    required this.config,
    this.initialValues,
    this.headerOverride,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValues;
    _values = {
      for (final f in widget.config.fields)
        f.key: initial != null && initial.containsKey(f.key)
            ? initial[f.key]
            : f.defaultValue(),
    };
  }

  bool get _hasContent => widget.config.fields.any(
        (f) => f.hasValue(_values[f.key]),
      );

  void _onFieldChanged(String key, Object? value) {
    setState(() => _values[key] = value);
  }

  void _onPost() {
    FocusScope.of(context).unfocus();
    final handler = widget.config.onSubmit;
    if (handler != null) {
      handler(context, Map.unmodifiable(_values));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.config.submittedMessage),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: FormRenderer(
                  fields: widget.config.fields,
                  values: _values,
                  onChanged: _onFieldChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final active = _hasContent;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FormTokens.gold, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                PhosphorIcons.x(),
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.headerOverride ?? widget.config.headerTitle,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 21 / 16,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 37,
            child: Material(
              color: active ? AppColors.ink : const Color(0xFF999999),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: active ? _onPost : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      widget.config.postLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 21 / 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
