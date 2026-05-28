import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final int chatBadge;
  final String? avatarUrl;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.chatBadge = 0,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            offset: Offset(0, -1),
            blurRadius: 14,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: PhosphorIcons.house(
              selectedIndex == 0 ? PhosphorIconsStyle.fill : PhosphorIconsStyle.regular,
            ),
            onTap: () => onSelect(0),
          ),
          _ChatIcon(
            active: selectedIndex == 1,
            badge: chatBadge,
            onTap: () => onSelect(1),
          ),
          _NavIcon(
            icon: PhosphorIcons.treeStructure(
              selectedIndex == 2 ? PhosphorIconsStyle.fill : PhosphorIconsStyle.regular,
            ),
            onTap: () => onSelect(2),
          ),
          _NavIcon(
            icon: PhosphorIcons.magnifyingGlass(
              selectedIndex == 3 ? PhosphorIconsStyle.fill : PhosphorIconsStyle.regular,
            ),
            onTap: () => onSelect(3),
          ),
          _AvatarItem(
            active: selectedIndex == 4,
            avatarUrl: avatarUrl,
            onTap: () => onSelect(4),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Icon(icon, size: 28, color: AppColors.ink),
      ),
    );
  }
}

class _ChatIcon extends StatelessWidget {
  final bool active;
  final int badge;
  final VoidCallback onTap;
  const _ChatIcon({required this.active, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              PhosphorIcons.chatTeardropDots(
                active ? PhosphorIconsStyle.fill : PhosphorIconsStyle.regular,
              ),
              size: 28,
              color: AppColors.ink,
            ),
            if (badge > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
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

class _AvatarItem extends StatelessWidget {
  final bool active;
  final String? avatarUrl;
  final VoidCallback onTap;
  const _AvatarItem({required this.active, required this.avatarUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.chipBg,
          image: avatarUrl == null
              ? null
              : DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover),
          border: active ? Border.all(color: AppColors.ink, width: 2) : null,
        ),
        child: avatarUrl == null
            ? const Icon(Icons.person, size: 20, color: AppColors.textTertiary)
            : null,
      ),
    );
  }
}
