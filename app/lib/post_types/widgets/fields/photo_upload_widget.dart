import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/form/field_label.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../config/field_config.dart';

class PhotoUploadWidget extends StatefulWidget {
  final PhotoUploadConfig config;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  const PhotoUploadWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addPhoto() async {
    if (widget.config.source == UploadSource.files) {
      final result = await FilePicker.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty) return;
      final paths = result.files
          .map((f) => f.path)
          .whereType<String>()
          .toList();
      widget.onChanged([...widget.value, ...paths]);
      return;
    }
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    widget.onChanged([...widget.value, ...picked.map((x) => x.path)]);
  }

  bool _isImage(String path) {
    final ext = p.extension(path).toLowerCase();
    return const {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.heic'}
        .contains(ext);
  }

  void _remove(String path) {
    widget.onChanged(widget.value.where((p) => p != path).toList());
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.config.label != null) ...[
          FieldLabel(widget.config.label!, bold: photos.isNotEmpty),
          const SizedBox(height: 12),
        ],
        if (photos.isEmpty) _empty() else _grid(photos),
      ],
    );
  }

  Widget _empty() {
    return InkWell(
      onTap: _addPhoto,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 223,
        decoration: BoxDecoration(
          color: FormTokens.fieldBg,
          border: Border.all(color: FormTokens.fieldBorder, width: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.config.emptyIcon ?? PhosphorIcons.image(),
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              widget.config.emptyTitle,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: 0.02 * 16,
                color: FormTokens.hint,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.config.emptySubtitle,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.1,
                letterSpacing: 0.02 * 16,
                color: FormTokens.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(List<String> photos) {
    final items = <Widget>[
      for (final path in photos) _tile(path),
      _addTile(),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: items,
    );
  }

  Widget _addTile() {
    return InkWell(
      onTap: _addPhoto,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: FormTokens.fieldBg,
          border: Border.all(color: FormTokens.fieldBorder, width: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '+',
          style: GoogleFonts.dmSans(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            height: 1.1,
            letterSpacing: 0.02 * 36,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _tile(String path) {
    final isImage = widget.config.source == UploadSource.images || _isImage(path);
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: isImage
              ? Image.file(File(path), fit: BoxFit.cover)
              : Container(
                  color: FormTokens.fieldBg,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.fileText(),
                          size: 32, color: AppColors.textSecondary),
                      const SizedBox(height: 6),
                      Text(
                        p.basename(path),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _remove(path),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
