import 'package:flutter/material.dart';
import '../../models/family_member.dart';

class AddNode extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback? onTap;
  final double size;

  const AddNode({
    super.key,
    required this.member,
    this.onTap,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    final tint = member.placeholderTint ?? const Color(0xFFD8D8D8);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '+',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 48,
                  height: 32 / 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              member.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DM Sans',
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
