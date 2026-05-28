import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PostMenu {
  PostMenu._();

  static Future<void> show(
    BuildContext context, {
    required GlobalKey anchorKey,
    required bool isMine,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onAddToCollection,
    VoidCallback? onChangePrivacy,
    VoidCallback? onShare,
    VoidCallback? onReport,
  }) {
    final renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Future.value();
    final pos = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenW = MediaQuery.of(context).size.width;
    final top = pos.dy + size.height - 28;
    final right = screenW - (pos.dx + size.width) - 8;

    return showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ),
            Positioned(
              top: top,
              right: right,
              child: _MenuCard(
                isMine: isMine,
                onEdit: () {
                  Navigator.of(ctx).pop();
                  onEdit?.call();
                },
                onDelete: () {
                  Navigator.of(ctx).pop();
                  onDelete?.call();
                },
                onAddToCollection: () {
                  Navigator.of(ctx).pop();
                  onAddToCollection?.call();
                },
                onChangePrivacy: () {
                  Navigator.of(ctx).pop();
                  onChangePrivacy?.call();
                },
                onShare: () {
                  Navigator.of(ctx).pop();
                  onShare?.call();
                },
                onReport: () {
                  Navigator.of(ctx).pop();
                  onReport?.call();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddToCollection;
  final VoidCallback onChangePrivacy;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const _MenuCard({
    required this.isMine,
    required this.onEdit,
    required this.onDelete,
    required this.onAddToCollection,
    required this.onChangePrivacy,
    required this.onShare,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final items = isMine
        ? <Widget>[
            _MenuItem(
              icon: PhosphorIcons.pencilSimple(),
              label: 'Edit',
              onTap: onEdit,
            ),
            _MenuItem(
              icon: PhosphorIcons.trashSimple(),
              label: 'Delete',
              onTap: onDelete,
            ),
            _MenuItem(
              icon: PhosphorIcons.plus(),
              label: 'Add to collection',
              onTap: onAddToCollection,
            ),
            _MenuItem(
              icon: PhosphorIcons.lockKey(),
              label: 'Change privacy',
              onTap: onChangePrivacy,
            ),
          ]
        : <Widget>[
            _MenuItem(
              icon: PhosphorIcons.share(),
              label: 'Share post',
              onTap: onShare,
            ),
            _MenuItem(
              icon: PhosphorIcons.plus(),
              label: 'Add to collection',
              onTap: onAddToCollection,
            ),
            _ReportItem(onTap: onReport),
          ];

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              items[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 16,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1D1E09)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 16 / 12,
                color: Color(0xFF1D1E09),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 16,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              size: 16,
              color: const Color(0xFFD32020),
            ),
            const SizedBox(width: 8),
            const Text(
              'Report',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 16 / 12,
                color: Color(0xFFD32020),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
