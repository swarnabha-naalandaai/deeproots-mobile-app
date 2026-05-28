import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class AlbumGalleryScreen extends StatefulWidget {
  final String title;
  final List<String> images;
  final int initialIndex;

  const AlbumGalleryScreen({
    super.key,
    required this.title,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<AlbumGalleryScreen> createState() => _AlbumGalleryScreenState();
}

class _AlbumGalleryScreenState extends State<AlbumGalleryScreen> {
  late int _focused;
  late final PageController _pager;
  bool _gridView = false;

  @override
  void initState() {
    super.initState();
    _focused = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pager = PageController(initialPage: _focused);
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: widget.title,
              counter: _gridView ? '${widget.images.length} photos' : '${_focused + 1} / ${widget.images.length}',
              gridView: _gridView,
              onToggle: () => setState(() => _gridView = !_gridView),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: _gridView
                  ? _Grid(
                      images: widget.images,
                      onTap: (i) => setState(() {
                        _focused = i;
                        _gridView = false;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pager.hasClients) _pager.jumpToPage(i);
                        });
                      }),
                    )
                  : PageView.builder(
                      controller: _pager,
                      itemCount: widget.images.length,
                      onPageChanged: (i) => setState(() => _focused = i),
                      itemBuilder: (_, i) => InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: widget.images[i],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String counter;
  final bool gridView;
  final VoidCallback onToggle;
  final VoidCallback onBack;
  const _TopBar({
    required this.title,
    required this.counter,
    required this.gridView,
    required this.onToggle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(PhosphorIcons.caretLeft(), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  counter,
                  style: GoogleFonts.dmSans(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              gridView
                  ? PhosphorIcons.image(PhosphorIconsStyle.regular)
                  : PhosphorIcons.squaresFour(PhosphorIconsStyle.regular),
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final List<String> images;
  final ValueChanged<int> onTap;
  const _Grid({required this.images, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => onTap(i),
        child: Container(
          color: AppColors.textTertiary,
          child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover),
        ),
      ),
    );
  }
}
