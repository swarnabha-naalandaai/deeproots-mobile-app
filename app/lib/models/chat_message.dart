import 'package:flutter/material.dart';

enum MessageKind { outgoing, incoming, systemDay, systemEvent }

class ChatMessage {
  final MessageKind kind;
  final String text;
  final String? senderName;
  final String? senderInitial;
  final Color? senderAvatarColor;
  final String? time;
  final bool showAvatar;
  final bool showSenderName;

  const ChatMessage({
    required this.kind,
    required this.text,
    this.senderName,
    this.senderInitial,
    this.senderAvatarColor,
    this.time,
    this.showAvatar = false,
    this.showSenderName = false,
  });
}

const allFamilyMessages = <ChatMessage>[
  ChatMessage(kind: MessageKind.systemDay, text: 'TODAY'),
  ChatMessage(kind: MessageKind.systemEvent, text: 'Aparna Dey & 6 other joined the chat'),
  ChatMessage(kind: MessageKind.outgoing, text: 'Hi'),
  ChatMessage(
    kind: MessageKind.outgoing,
    text: 'I gotta show you a cool things I found maa!',
    time: '4.23 pm',
  ),
  ChatMessage(
    kind: MessageKind.incoming,
    text: 'What is it?',
    senderName: 'Maa (Aparna Dey)',
    senderInitial: 'M',
    senderAvatarColor: Color(0xFF3F4112),
    showAvatar: true,
    showSenderName: true,
  ),
  ChatMessage(
    kind: MessageKind.incoming,
    text: 'I gotta show you a cool things I found maa!',
    senderName: 'Maa (Aparna Dey)',
    senderInitial: 'M',
    senderAvatarColor: Color(0xFF3F4112),
    showSenderName: true,
    time: '4.23 pm',
  ),
];
