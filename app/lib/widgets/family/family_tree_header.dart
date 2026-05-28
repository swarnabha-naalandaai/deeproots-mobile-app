import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FamilyTreeHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final ValueChanged<String>? onSearch;

  const FamilyTreeHeader({
    super.key,
    this.onBack,
    this.onMenu,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 47,
        child: Row(
          children: [
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  PhosphorIcons.caretLeft(),
                  size: 24,
                  color: const Color(0xFF5F5F5F),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 47,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F1F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.magnifyingGlass(),
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onSubmitted: onSearch,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 14 * 0.06,
                          color: Color(0xFF1D1E09),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search “cousins”, “Delhi”, “1990s”',
                          hintStyle: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF949494),
                            letterSpacing: 14 * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onMenu,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  PhosphorIcons.dotsThreeVertical(),
                  size: 24,
                  color: const Color(0xFF5F5F5F),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
