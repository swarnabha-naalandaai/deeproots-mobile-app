import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/comment.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CommentsSheet extends StatefulWidget {
  final List<Comment> comments;
  const CommentsSheet({super.key, required this.comments});

  static Future<void> show(BuildContext context, {List<Comment>? comments}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x33000000),
      builder: (_) => CommentsSheet(comments: comments ?? mockComments),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _mentionMatches = const [];
  late List<Comment> _comments;
  final Set<String> _hiddenIds = <String>{};
  String? _replyParentId;
  String? _replyAuthorName;

  @override
  void initState() {
    super.initState();
    _comments = List<Comment>.of(widget.comments);
    _controller.addListener(_onTextChanged);
  }

  void _hide(String id) {
    setState(() => _hiddenIds.add(id));
  }

  Comment _toggle(Comment c) {
    final nowLiked = !c.liked;
    final delta = nowLiked ? 1 : -1;
    return c.copyWith(liked: nowLiked, likes: c.likes + delta);
  }

  void _toggleLike(String id) {
    setState(() {
      _comments = [
        for (final c in _comments)
          if (c.id == id)
            _toggle(c)
          else if (c.replies.any((r) => r.id == id))
            c.copyWith(replies: [
              for (final r in c.replies)
                if (r.id == id) _toggle(r) else r,
            ])
          else
            c,
      ];
    });
  }

  void _replyTo(String parentId, String authorName) {
    final token = '@${authorName.replaceAll(' ', '').toLowerCase()} ';
    final text = _controller.text;
    if (!text.contains(token)) {
      _controller.value = TextEditingValue(
        text: token + text,
        selection: TextSelection.collapsed(offset: token.length),
      );
    }
    setState(() {
      _replyParentId = parentId;
      _replyAuthorName = authorName;
    });
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _cancelReply() {
    setState(() {
      _replyParentId = null;
      _replyAuthorName = null;
    });
  }

  void _post() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final newComment = Comment(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      authorName: 'You',
      text: text,
      time: 'now',
    );
    setState(() {
      final parentId = _replyParentId;
      if (parentId != null) {
        _comments = [
          for (final c in _comments)
            if (c.id == parentId)
              c.copyWith(replies: [...c.replies, newComment])
            else
              c,
        ];
      } else {
        _comments = [..._comments, newComment];
      }
      _replyParentId = null;
      _replyAuthorName = null;
      _mentionMatches = const [];
    });
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final caret = _controller.selection.baseOffset;
    final endIdx = caret < 0 ? text.length : caret;
    final upToCaret = text.substring(0, endIdx);
    final atIdx = upToCaret.lastIndexOf('@');
    List<String> matches = const [];
    if (atIdx >= 0) {
      final query = upToCaret.substring(atIdx + 1).toLowerCase();
      final hasSpace = query.contains(' ');
      if (!hasSpace) {
        matches = mockMentionUsers
            .where((u) => u.toLowerCase().startsWith(query))
            .toList(growable: false);
      }
    }
    if (matches != _mentionMatches) {
      setState(() => _mentionMatches = matches);
    }
  }

  void _applyMention(String name) {
    final text = _controller.text;
    final caret = _controller.selection.baseOffset;
    final endIdx = caret < 0 ? text.length : caret;
    final atIdx = text.substring(0, endIdx).lastIndexOf('@');
    if (atIdx < 0) return;
    final mentionToken = '@${name.replaceAll(' ', '').toLowerCase()} ';
    final newText = text.replaceRange(atIdx, endIdx, mentionToken);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: atIdx + mentionToken.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                _Handle(),
                const SizedBox(height: 8),
                Text(
                  'Comments',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 18 / 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: () {
                    final visible = _comments
                        .where((c) => !_hiddenIds.contains(c.id))
                        .toList(growable: false);
                    if (visible.isEmpty) return const _EmptyState();
                    return _CommentList(
                      comments: visible,
                      hiddenIds: _hiddenIds,
                      onReply: _replyTo,
                      onHide: _hide,
                      onLike: _toggleLike,
                    );
                  }(),
                ),
                if (_mentionMatches.isNotEmpty)
                  _MentionRow(
                    users: _mentionMatches,
                    onPick: _applyMention,
                  ),
                if (_replyAuthorName != null)
                  _ReplyBanner(
                    authorName: _replyAuthorName!,
                    onCancel: _cancelReply,
                  ),
                _InputBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSend: _post,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'No comments yet',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 18 / 14,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _CommentList extends StatelessWidget {
  final List<Comment> comments;
  final Set<String> hiddenIds;
  final void Function(String parentId, String authorName) onReply;
  final ValueChanged<String> onHide;
  final ValueChanged<String> onLike;
  const _CommentList({
    required this.comments,
    required this.hiddenIds,
    required this.onReply,
    required this.onHide,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: comments.length,
      itemBuilder: (_, i) => _CommentTile(
        comment: comments[i],
        hiddenIds: hiddenIds,
        onReply: onReply,
        onHide: onHide,
        onLike: onLike,
      ),
    );
  }
}

class _CommentTile extends StatefulWidget {
  final Comment comment;
  final Set<String> hiddenIds;
  final void Function(String parentId, String authorName) onReply;
  final ValueChanged<String> onHide;
  final ValueChanged<String> onLike;
  const _CommentTile({
    required this.comment,
    required this.hiddenIds,
    required this.onReply,
    required this.onHide,
    required this.onLike,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    final visibleReplies = c.replies
        .where((r) => !widget.hiddenIds.contains(r.id))
        .toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommentAvatar(letter: c.authorInitial),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(c.authorName, style: AppTypography.authorName),
                        const SizedBox(width: 6),
                        Text(c.time, style: AppTypography.timestamp),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _CommentBody(text: c.text),
                    const SizedBox(height: 4),
                    _ActionRow(
                      onReply: () => widget.onReply(c.id, c.authorName),
                      onHide: () => widget.onHide(c.id),
                    ),
                    if (visibleReplies.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Text(
                          _expanded
                              ? 'Hide replies'
                              : 'View ${visibleReplies.length} more replies',
                          style: _actionStyle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _LikeColumn(
                count: c.likes,
                liked: c.liked,
                onTap: () => widget.onLike(c.id),
              ),
            ],
          ),
          if (_expanded && visibleReplies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 45, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final r in visibleReplies)
                    _ReplyRow(
                      reply: r,
                      onReply: () => widget.onReply(c.id, r.authorName),
                      onHide: () => widget.onHide(r.id),
                      onLike: () => widget.onLike(r.id),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReplyRow extends StatelessWidget {
  final Comment reply;
  final VoidCallback onReply;
  final VoidCallback onHide;
  final VoidCallback onLike;
  const _ReplyRow({
    required this.reply,
    required this.onReply,
    required this.onHide,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFD8D8D8),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              reply.authorInitial,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.0,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(reply.authorName, style: AppTypography.authorName),
                    const SizedBox(width: 6),
                    Text(reply.time, style: AppTypography.timestamp),
                  ],
                ),
                const SizedBox(height: 4),
                _CommentBody(text: reply.text),
                const SizedBox(height: 4),
                _ActionRow(onReply: onReply, onHide: onHide),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _LikeColumn(count: reply.likes, liked: reply.liked, onTap: onLike),
        ],
      ),
    );
  }
}

class _CommentAvatar extends StatelessWidget {
  final String letter;
  const _CommentAvatar({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 37,
      height: 37,
      decoration: const BoxDecoration(
        color: Color(0xFFD8D8D8),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _CommentBody extends StatelessWidget {
  final String text;
  const _CommentBody({required this.text});

  @override
  Widget build(BuildContext context) {
    final mention = RegExp(r'@\w+');
    final spans = <TextSpan>[];
    int last = 0;
    for (final m in mention.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(TextSpan(
        text: text.substring(m.start, m.end),
        style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.w700),
      ));
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return RichText(
      text: TextSpan(
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.1,
          color: AppColors.ink,
        ),
        children: spans,
      ),
    );
  }
}

final TextStyle _actionStyle = GoogleFonts.dmSans(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  height: 1.1,
  color: const Color(0xFF999999),
);

class _ActionRow extends StatelessWidget {
  final VoidCallback onReply;
  final VoidCallback onHide;
  const _ActionRow({required this.onReply, required this.onHide});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionText(label: 'Reply', onTap: onReply),
        const SizedBox(width: 12),
        _ActionText(label: 'Hide', onTap: onHide),
        const SizedBox(width: 12),
        _ActionText(label: 'See translation', onTap: () {}),
      ],
    );
  }
}

class _ActionText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionText({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(label, style: _actionStyle),
    );
  }
}

class _LikeColumn extends StatelessWidget {
  final int count;
  final bool liked;
  final VoidCallback onTap;
  const _LikeColumn({
    required this.count,
    required this.liked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Icon(
              liked
                  ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                  : PhosphorIcons.heart(),
              size: 20,
              color: liked ? const Color(0xFFD32020) : AppColors.textSecondary,
            ),
            const SizedBox(height: 0),
            Text(
              '$count',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 16 / 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MentionRow extends StatelessWidget {
  final List<String> users;
  final ValueChanged<String> onPick;
  const _MentionRow({required this.users, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _MentionChip(name: users[i], onTap: () => onPick(users[i])),
      ),
    );
  }
}

class _MentionChip extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _MentionChip({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(initial, style: AppTypography.avatarLetter),
          ),
          const SizedBox(width: 8),
          Text(name, style: AppTypography.authorName),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.dmSans(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
      letterSpacing: 17 * 0.06,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: const BoxDecoration(
              color: Color(0xFFD8D8D8),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(PhosphorIcons.user(), size: 22, color: AppColors.ink),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 47,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.separator, width: 0.4),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: textStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Share your thoughts too...',
                    hintStyle: textStyle.copyWith(
                      color: const Color(0xFF949494),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) {
              if (value.text.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: onSend,
                  borderRadius: BorderRadius.circular(9999),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      PhosphorIcons.arrowBendUpRight(),
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReplyBanner extends StatelessWidget {
  final String authorName;
  final VoidCallback onCancel;
  const _ReplyBanner({required this.authorName, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: const Color(0xFFF6F2FA),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Replying to $authorName',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCancel,
            child: Icon(PhosphorIcons.x(), size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
