import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/family_member.dart';

class FamilyNode extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback? onTap;
  final double size;
  final bool highlighted;

  const FamilyNode({
    super.key,
    required this.member,
    this.onTap,
    this.size = 76,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = member.relation == Relation.self;
    final deceasedOverlay = member.deceased && !member.isPlaceholder
        ? const Color(0x33C1A373) // rgba(193,163,115,0.2)
        : null;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE5D7CA),
        border: highlighted
            ? Border.all(color: const Color(0xFFA07A23), width: 2)
            : (isSelf ? Border.all(color: Colors.black, width: 2) : null),
        image: member.imageAsset != null
            ? DecorationImage(image: AssetImage(member.imageAsset!), fit: BoxFit.cover)
            : (member.imageUrl != null
                ? DecorationImage(image: NetworkImage(member.imageUrl!), fit: BoxFit.cover)
                : null),
      ),
      child: (member.imageAsset == null && member.imageUrl == null)
          ? Icon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
              size: size * 0.55,
              color: const Color(0xFF88623E),
            )
          : null,
    );

    if (highlighted) {
      avatar = SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              left: -8,
              top: -8,
              child: Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x66C1A373),
                ),
              ),
            ),
            avatar,
          ],
        ),
      );
    }

    if (deceasedOverlay != null) {
      avatar = Stack(
        children: [
          avatar,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: deceasedOverlay,
              ),
            ),
          ),
        ],
      );
    }

    if (member.deceased && !member.isPlaceholder) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            left: (size - 12) / 2,
            top: -8,
            child: Icon(
              PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
              size: 12,
              color: const Color(0xFFA07A23),
              shadows: const [
                Shadow(
                  color: Color(0xFFF6D046),
                  blurRadius: 8.4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (member.badgeCount > 0) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF7E2525),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${member.badgeCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            avatar,
            const SizedBox(height: 6),
            Text(
              member.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 16 / 12,
                color: Color(0xFF1D1E09),
              ),
            ),
            if (member.subtitle != null || member.lifespan != null)
              Text(
                member.subtitle ?? member.lifespan ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  height: 16 / 12,
                  color: Color(0xFF999999),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
