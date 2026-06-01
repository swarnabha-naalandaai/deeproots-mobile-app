import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileImageCropScreen extends StatefulWidget {
  final String imagePath;

  const ProfileImageCropScreen({super.key, required this.imagePath});

  static Future<String?> show(BuildContext context, String imagePath) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ProfileImageCropScreen(imagePath: imagePath)),
    );
  }

  @override
  State<ProfileImageCropScreen> createState() => _ProfileImageCropScreenState();
}

class _ProfileImageCropScreenState extends State<ProfileImageCropScreen> {
  final _cropController = CropController();
  late final Future<Uint8List> _imageBytes;
  bool _cropping = false;

  @override
  void initState() {
    super.initState();
    _imageBytes = File(widget.imagePath).readAsBytes();
  }

  Future<void> _onCropped(Uint8List cropped) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/profile_crop_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(cropped);
    if (mounted) Navigator.of(context).pop(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F0),
      body: SafeArea(
        child: Column(
          children: [
            _toolbar(),
            Expanded(
              child: FutureBuilder<Uint8List>(
                future: _imageBytes,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA07A23),
                        strokeWidth: 2,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Crop(
                      image: snapshot.data!,
                      controller: _cropController,
                      onCropped: _onCropped,
                      aspectRatio: 1,
                      withCircleUi: true,
                      baseColor: const Color(0xFFF0F1F0),
                      maskColor: const Color(0xFFF0F1F0).withValues(alpha: 0.7),
                      cornerDotBuilder: (size, edgeAlignment) => const SizedBox.shrink(),
                      interactive: true,
                      fixCropRect: true,
                    ),
                  );
                },
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                PhosphorIcons.x(),
                size: 22,
                color: const Color(0xFF3E3E3E),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Crop photo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1E09),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: GestureDetector(
        onTap: _cropping
            ? null
            : () {
                setState(() => _cropping = true);
                _cropController.crop();
              },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: _cropping ? const Color(0xFF3E3E3E) : const Color(0xFF1D1E09),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: _cropping
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
