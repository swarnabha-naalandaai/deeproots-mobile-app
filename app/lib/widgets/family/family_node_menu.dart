import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/family_member.dart';

class FamilyNodeMenu extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onAddRelative;
  final VoidCallback onViewTree;
  final VoidCallback onAddMemory;
  final VoidCallback onViewProfile;
  final VoidCallback onDismiss;

  const FamilyNodeMenu({
    super.key,
    required this.member,
    required this.onAddRelative,
    required this.onViewTree,
    required this.onAddMemory,
    required this.onViewProfile,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuItem(
          icon: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              '+',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                height: 1,
                color: Color(0xFF5F5F5F),
              ),
            ),
          ),
          label: 'Add relative',
          onTap: onAddRelative,
        ),
        const SizedBox(height: 8),
        _MenuItem(
          icon: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              PhosphorIcons.treeStructure(),
              size: 16,
              color: const Color(0xFF5F5F5F),
            ),
          ),
          label: 'View tree',
          onTap: onViewTree,
        ),
        const SizedBox(height: 8),
        _MenuItem(
          icon: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              PhosphorIcons.filmReel(),
              size: 16,
              color: const Color(0xFF5F5F5F),
            ),
          ),
          label: 'Add memory',
          onTap: onAddMemory,
        ),
        const SizedBox(height: 8),
        _MenuItem(
          icon: _MemberAvatar(member: member),
          label: 'View profile',
          onTap: onViewProfile,
        ),
      ],
    ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final FamilyMember member;
  const _MemberAvatar({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE5D7CA),
        image: member.imageAsset != null
            ? DecorationImage(
                image: AssetImage(member.imageAsset!),
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Color(0x33C1A373),
                  BlendMode.srcOver,
                ),
              )
            : (member.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(member.imageUrl!),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                      Color(0x33C1A373),
                      BlendMode.srcOver,
                    ),
                  )
                : null),
      ),
      child: (member.imageAsset == null && member.imageUrl == null)
          ? Icon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
              size: 18,
              color: const Color(0xFF88623E),
            )
          : null,
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Widget icon;
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 18 / 14,
                color: Color(0xFF1D1E09),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
