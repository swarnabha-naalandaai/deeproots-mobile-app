import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class _PostOption {
  final IconData? icon;
  final Widget? customIcon;
  final String title;
  final String subtitle;
  const _PostOption({
    this.icon,
    this.customIcon,
    required this.title,
    required this.subtitle,
  });
}

class _TraditionIcon extends StatelessWidget {
  const _TraditionIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: _TraditionPainter(),
    );
  }
}

class _TraditionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5F5F5F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.33333;

    final path = Path()
      ..moveTo(23.3333, 19.6676)
      ..cubicTo(27, 15.6673, 22.1565, 2.72926, 21, 3.66765)
      ..cubicTo(19.8435, 4.60605, 16.6667, 9.66732, 16.6667, 14.0007)
      ..cubicTo(16.6667, 18.334, 17.5358, 18.6079, 18.3347, 19.9676)
      ..moveTo(18.3347, 19.9676)
      ..cubicTo(13.0375, 22.9777, 8.53899, 20.8374, 4.25918, 19.9676)
      ..cubicTo(2.72903, 19.9676, 8.15913, 30.4623, 15.6699, 34.001)
      ..lineTo(25.2402, 33.8792)
      ..cubicTo(32.287, 30.1283, 36.6749, 19.4012, 35.9148, 19.9676)
      ..cubicTo(25.6667, 23.6676, 24.1654, 20.201, 20.6667, 18.3343)
      ..cubicTo(19.8718, 18.9975, 19.095, 19.5356, 18.3347, 19.9676);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AddPostSheet extends StatelessWidget {
  final ValueChanged<String>? onSelect;
  const AddPostSheet({super.key, this.onSelect});

  static Future<void> show(BuildContext context, {ValueChanged<String>? onSelect}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x26000000),
      builder: (_) => AddPostSheet(onSelect: onSelect),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = <_PostOption>[
      _PostOption(icon: PhosphorIcons.bookOpen(), title: 'Story', subtitle: 'Memories worth retelling'),
      _PostOption(icon: PhosphorIcons.chefHat(), title: 'Recipe', subtitle: 'Family dishes worth keeping'),
      const _PostOption(customIcon: _TraditionIcon(), title: 'Tradition', subtitle: 'What we do, year after year'),
      _PostOption(icon: PhosphorIcons.images(), title: 'Photo Album', subtitle: 'Events, festivals, gatherings'),
      _PostOption(icon: PhosphorIcons.files(), title: 'Documents', subtitle: 'Letters, certificates, heirlooms'),
      _PostOption(icon: PhosphorIcons.confetti(), title: 'Life Update', subtitle: 'A quick note'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      padding: const EdgeInsets.only(top: 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFD3D2CE),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'What would you like to share?',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _row(context, options[0], options[1]),
                    const SizedBox(height: 12),
                    _row(context, options[2], options[3]),
                    const SizedBox(height: 12),
                    _row(context, options[4], options[5]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, _PostOption a, _PostOption b) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _Card(option: a, onTap: () => _tap(context, a.title))),
          const SizedBox(width: 12),
          Expanded(child: _Card(option: b, onTap: () => _tap(context, b.title))),
        ],
      ),
    );
  }

  void _tap(BuildContext context, String title) {
    Navigator.of(context).pop();
    onSelect?.call(title);
  }
}

class _Card extends StatelessWidget {
  final _PostOption option;
  final VoidCallback onTap;
  const _Card({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9F8F7),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF9C8F8F), width: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              option.customIcon ??
                  Icon(option.icon, size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                option.title,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 21 / 16,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option.subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
