import 'package:flutter/material.dart';

class TaggedPeopleSheet extends StatelessWidget {
  final List<String> names;
  const TaggedPeopleSheet({super.key, required this.names});

  static Future<void> show(BuildContext context, List<String> names) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x80000000),
      builder: (_) => TaggedPeopleSheet(names: names),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Tagged people',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 18 / 14,
                color: Color(0xFF1D1E09),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < names.length; i++) ...[
                  if (i > 0) const SizedBox(height: 20),
                  _PersonRow(name: names[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final String name;
  const _PersonRow({required this.name});

  String get _initial =>
      name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 37,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD8D8D8),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initial,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.0,
                      color: Color(0xFF1D1E09),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 18 / 14,
                    color: Color(0xFF1D1E09),
                  ),
                ),
              ],
            ),
            _VisitProfileButton(onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _VisitProfileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _VisitProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF3E3E3E),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Text(
          'VISIT PROFILE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: 12,
            height: 16 / 12,
            letterSpacing: 0.06 * 12,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
