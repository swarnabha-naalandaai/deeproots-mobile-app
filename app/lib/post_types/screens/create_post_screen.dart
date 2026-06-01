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

  void _onBulkChanged(Map<String, dynamic> fields) {
    setState(() {
      for (final entry in fields.entries) {
        if (_values.containsKey(entry.key)) {
          _values[entry.key] = entry.value;
        }
      }
    });
  }

  Future<void> _onBack() async {
    if (!_hasContent) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _DiscardDialog(category: widget.config.displayName),
    );
    if (discard == true && mounted) {
      Navigator.of(context).pop();
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
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
                  onBulkChanged: _onBulkChanged,
                ),
              ),
            ),
          ],
        ),
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
            onTap: _onBack,
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

class _DiscardDialog extends StatelessWidget {
  final String category;

  const _DiscardDialog({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 290,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _warningIcon(),
              const SizedBox(height: 12),
              Text(
                'Discard this ${category.toLowerCase()}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "The content you've added won't be saved.",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 23),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F1F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Discard',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 21 / 16,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Keep editing',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 21 / 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _warningIcon() {
    return CustomPaint(
      size: const Size(40.7, 35.25),
      painter: _TrianglePainter(),
      child: const SizedBox(
        width: 40.7,
        height: 35.25,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D1E09),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5DD85)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(2),
    );
    canvas.clipRRect(rrect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
