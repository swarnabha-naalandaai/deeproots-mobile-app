import 'package:flutter/material.dart';

class ChatThread {
  final String name;
  final String preview;
  final String time;
  final int unread;
  final Color avatarColor;
  final bool unreadStyle;

  const ChatThread({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.avatarColor,
    required this.unreadStyle,
  });
}

const mockChats = <ChatThread>[
  ChatThread(
    name: 'All-Family',
    preview: 'Maa: Wow! This looks fantastic',
    time: '7.43 pm',
    unread: 2,
    avatarColor: Color(0xFF3E3E3E),
    unreadStyle: true,
  ),
  ChatThread(
    name: 'Immediate family',
    preview: "Shashwat: He’s been asking about Dada’s ca…",
    time: '',
    unread: 0,
    avatarColor: Color(0xFF88623E),
    unreadStyle: false,
  ),
  ChatThread(
    name: 'The Funny Cousins',
    preview: "Aryan: Hey, let’s make this together.",
    time: '4.23 pm',
    unread: 12,
    avatarColor: Color(0xFF204E74),
    unreadStyle: true,
  ),
];
