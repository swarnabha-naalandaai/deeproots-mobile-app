import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/feed_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DeeprootsApp());
}

class DeeprootsApp extends StatelessWidget {
  const DeeprootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deeproots',
      theme: AppTheme.light(),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _navIndex = 0;

  void _select(int i) => setState(() => _navIndex = i);

  @override
  Widget build(BuildContext context) {
    if (_navIndex == 1) {
      return ChatScreen(navIndex: _navIndex, onNavSelect: _select);
    }
    return FeedScreen(navIndex: _navIndex, onNavSelect: _select);
  }
}
