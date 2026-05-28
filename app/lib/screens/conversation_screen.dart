import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../theme/app_colors.dart';

class ConversationScreen extends StatefulWidget {
  final ChatThread thread;
  final int memberCount;
  final List<ChatMessage> initialMessages;

  const ConversationScreen({
    super.key,
    required this.thread,
    this.memberCount = 35,
    this.initialMessages = allFamilyMessages,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final List<ChatMessage> _messages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.initialMessages);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _now() {
    final t = TimeOfDay.now();
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.period == DayPeriod.am ? 'am' : 'pm';
    return '$h.$m $ap';
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        kind: MessageKind.outgoing,
        text: text,
        time: _now(),
      ));
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(thread: widget.thread, memberCount: widget.memberCount),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  border: Border.all(
                    color: AppColors.separator,
                    width: 0.4,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _WelcomeCard(name: widget.thread.name),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _MessageRow(msg: _messages[i]),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: _Composer(
                          controller: _controller,
                          onSend: _send,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ChatThread thread;
  final int memberCount;
  const _Header({required this.thread, required this.memberCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
      child: SizedBox(
        height: 39,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Icon(PhosphorIcons.caretLeft(), size: 24, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: thread.avatarColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    thread.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      height: 21 / 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    '$memberCount members',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      height: 20 / 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.archive(), size: 24, color: AppColors.textSecondary),
            const SizedBox(width: 15),
            Icon(PhosphorIcons.dotsThreeVertical(), size: 24, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  const _WelcomeCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Text(
            'Welcome to ‘$name’',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              height: 21 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Share updates, post old photos, and stay in touch with the people who share your roots. Drop a hello below 👋',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              height: 1.2,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemPill extends StatelessWidget {
  final String text;
  const _SystemPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.separator, width: 0.4),
        borderRadius: BorderRadius.circular(43),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          height: 1.1,
          fontWeight: FontWeight.w500,
          letterSpacing: 10 * 0.06,
          color: const Color(0xFF949494),
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final ChatMessage msg;
  const _MessageRow({required this.msg});

  @override
  Widget build(BuildContext context) {
    switch (msg.kind) {
      case MessageKind.systemDay:
      case MessageKind.systemEvent:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Center(child: _SystemPill(text: msg.text)),
        );
      case MessageKind.outgoing:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        height: 18 / 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 14 * 0.02,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if (msg.time != null) ...[
                const SizedBox(height: 8),
                Text(
                  msg.time!,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 12 * 0.06,
                    color: AppColors.separator,
                  ),
                ),
              ],
            ],
          ),
        );
      case MessageKind.incoming:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                child: msg.showAvatar
                    ? Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: msg.senderAvatarColor ?? AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          msg.senderInitial ?? '',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IntrinsicWidth(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(2),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg.showSenderName && msg.senderName != null)
                                Text(
                                  msg.senderName!,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    height: 18 / 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 14 * 0.02,
                                    color: const Color(0xFFA07A23),
                                  ),
                                ),
                              if (msg.showSenderName && msg.senderName != null)
                                const SizedBox(height: 4),
                              Text(
                                msg.text,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  height: 18 / 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 14 * 0.02,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (msg.time != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        msg.time!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          height: 1.1,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 12 * 0.06,
                          color: AppColors.separator,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _Composer extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.onSend});

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final textStyle = GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.1,
      letterSpacing: 14 * 0.06,
      color: AppColors.ink,
    );
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 47,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.separator, width: 0.4),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: widget.controller,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => widget.onSend(),
              cursorColor: AppColors.ink,
              style: textStyle,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Message your family',
                hintStyle: textStyle.copyWith(color: const Color(0xFF949494)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 47,
          height: 47,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.separator, width: 0.5),
          ),
          child: Text(
            '+',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              height: 36 / 28,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: widget.onSend,
          child: Container(
            width: 47,
            height: 47,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ink,
            ),
            child: Icon(
              hasText
                  ? PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill)
                  : PhosphorIcons.microphone(PhosphorIconsStyle.fill),
              size: 22,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
