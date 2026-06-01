import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/family_member.dart';

class _ProfilePost {
  final String imageUrl;
  final IconData badge;
  const _ProfilePost({required this.imageUrl, required this.badge});
}

class ProfileScreen extends StatefulWidget {
  final FamilyMember member;
  final bool isSelf;

  const ProfileScreen({super.key, required this.member, this.isSelf = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tabIdx = 0;

  static final List<_ProfilePost> _wallPosts = [
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.bookOpen,
    ),
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.chefHat,
    ),
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.bookOpen,
    ),
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.images,
    ),
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1605196560547-b2f7281b8355?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.images,
    ),
    _ProfilePost(
      imageUrl: '',
      badge: PhosphorIconsRegular.files,
    ),
  ];

  static final List<_ProfilePost> _tagPosts = [
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1605196560547-b2f7281b8355?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.images,
    ),
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.images,
    ),
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.bookOpen,
    ),
  ];

  static final List<_ProfilePost> _collectionPosts = [
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.chefHat,
    ),
    _ProfilePost(
      imageUrl:
          'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=400&h=400&fit=crop',
      badge: PhosphorIconsRegular.bookOpen,
    ),
  ];

  List<_ProfilePost> get _currentPosts {
    switch (_tabIdx) {
      case 1:
        return _tagPosts;
      case 2:
        return _collectionPosts;
      default:
        return _wallPosts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final displayName =
        widget.isSelf ? '${m.name} (you)' : m.name;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            _topBar(displayName),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF999999),
                    width: 0.4,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    _identityBlock(m),
                    const SizedBox(height: 12),
                    _tabsRow(),
                    const SizedBox(height: 4),
                    Expanded(child: _grid()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(String name) {
    final m = widget.member;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                PhosphorIcons.caretLeft(),
                size: 24,
                color: const Color(0xFF5F5F5F),
              ),
            ),
            const SizedBox(width: 8),
            _avatar(m, 36),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 21 / 16,
                  color: Color(0xFF1D1E09),
                ),
              ),
            ),
            Icon(
              PhosphorIcons.dotsThreeVertical(),
              size: 24,
              color: const Color(0xFF5F5F5F),
            ),
          ],
        ),
      ),
    );
  }

  Widget _identityBlock(FamilyMember m) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          SizedBox(
            width: 102,
            height: 103,
            child: _avatar(m, 102),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 232,
            child: Column(
              children: [
                Text(
                  m.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 21 / 16,
                    color: Color(0xFF1D1E09),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_wallPosts.length} posts',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                    color: Color(0xFF5F5F5F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(FamilyMember m, double size) {
    final imgProvider = m.imageProvider;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE5D7CA),
        image: imgProvider != null
            ? DecorationImage(image: imgProvider, fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imgProvider == null
          ? Icon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
              size: size * 0.45,
              color: const Color(0xFF88623E),
            )
          : null,
    );
  }

  Widget _tabsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _tab(0, PhosphorIcons.gridFour())),
          Expanded(child: _tab(1, PhosphorIcons.identificationBadge())),
          Expanded(child: _tab(2, PhosphorIcons.bookmarkSimple())),
        ],
      ),
    );
  }

  Widget _tab(int idx, IconData icon) {
    final active = _tabIdx == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _tabIdx = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xFF1D1E09) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 24,
          color: active ? const Color(0xFF1D1E09) : const Color(0xFF5F5F5F),
        ),
      ),
    );
  }

  Widget _grid() {
    final posts = _currentPosts;
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'Nothing here yet',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Color(0xFF5F5F5F),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 137.33 / 125,
      ),
      itemCount: posts.length,
      itemBuilder: (_, i) => _cell(posts[i]),
    );
  }

  Widget _cell(_ProfilePost p) {
    return Stack(
      children: [
        Positioned.fill(
          child: p.imageUrl.isEmpty
              ? Container(color: const Color(0xFF6D4949))
              : CachedNetworkImage(
                  imageUrl: p.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: const Color(0xFFE5E1CA)),
                  errorWidget: (_, __, ___) =>
                      Container(color: const Color(0xFF6D4949)),
                ),
        ),
        Positioned(
          top: 4.4,
          right: 4.4,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF1D1E09),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(p.badge, size: 14.4, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
