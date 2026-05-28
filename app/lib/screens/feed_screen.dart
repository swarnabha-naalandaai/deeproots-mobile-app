import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../post_types/config/post_type_registry.dart';
import '../post_types/screens/create_post_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/add_post_fab.dart';
import '../widgets/add_post_sheet.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/feed_card.dart';
import '../widgets/sort_bar.dart';

class FeedScreen extends StatefulWidget {
  final int navIndex;
  final ValueChanged<int> onNavSelect;

  const FeedScreen({
    super.key,
    this.navIndex = 0,
    this.onNavSelect = _noop,
  });

  static void _noop(int _) {}

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  PostType? _selected;

  void _onPostTypeSelected(BuildContext context, String title) {
    final config = PostTypeRegistry.findByDisplayName(title);
    if (config == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreatePostScreen(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selected == null
        ? mockFeed
        : mockFeed.where((p) => p.type == _selected).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AddPostFab(
          onTap: () => AddPostSheet.show(
            context,
            onSelect: (title) => _onPostTypeSelected(context, title),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: widget.navIndex,
        chatBadge: 3,
        onSelect: widget.onNavSelect,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(),
            SortBar(
              selected: _selected,
              onSelect: (t) => setState(() => _selected = t),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => FeedCard(post: filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
