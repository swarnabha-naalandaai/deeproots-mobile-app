import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/chat_thread.dart';
import '../theme/app_colors.dart';
import '../widgets/add_post_fab.dart';
import '../widgets/add_post_sheet.dart';
import '../widgets/bottom_nav.dart';
import '../post_types/config/post_type_registry.dart';
import '../post_types/screens/create_post_screen.dart';
import 'conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  final int navIndex;
  final ValueChanged<int> onNavSelect;

  const ChatScreen({
    super.key,
    required this.navIndex,
    required this.onNavSelect,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AddPostFab(
          onTap: () => AddPostSheet.show(
            context,
            onSelect: (title) {
              final config = PostTypeRegistry.findByDisplayName(title);
              if (config == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(config: config),
                ),
              );
            },
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
            const _ChatHeader(),
            const _SearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: mockChats.length,
                itemBuilder: (ctx, i) => InkWell(
                  onTap: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(thread: mockChats[i]),
                    ),
                  ),
                  child: _ChatTile(thread: mockChats[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(PhosphorIcons.caretLeft(), size: 24, color: AppColors.textSecondary),
          Text(
            'Chats',
            style: GoogleFonts.heptaSlab(
              fontSize: 24,
              height: 30 / 24,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          Icon(PhosphorIcons.dotsThreeVertical(), size: 24, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 47,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.magnifyingGlass(), size: 20, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              'Search',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.1,
                letterSpacing: 14 * 0.06,
                color: const Color(0xFF949494),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatThread thread;
  const _ChatTile({required this.thread});

  @override
  Widget build(BuildContext context) {
    final unread = thread.unread > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: thread.avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    height: 21 / 16,
                    fontWeight: thread.unreadStyle ? FontWeight.w700 : FontWeight.w400,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  thread.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    height: 20 / 12,
                    fontWeight: thread.unreadStyle
                        ? (thread.name == 'All-Family' ? FontWeight.w600 : FontWeight.w500)
                        : FontWeight.w400,
                    color: thread.unreadStyle ? AppColors.ink : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (unread)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  thread.time,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    letterSpacing: 12 * 0.06,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.maroon,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${thread.unread}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
