import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/family_member.dart';
import '../models/family_tree_mock.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/family/add_node.dart';
import '../widgets/family/connector_lines.dart';
import '../widgets/family/dot_grid_background.dart';
import '../widgets/family/family_node.dart';
import '../widgets/family/family_member_profile_sheet.dart';
import '../widgets/family/family_node_menu.dart';
import '../widgets/family/family_tree_header.dart';
import '../widgets/family/time_travel_bar.dart';
import 'add_relative_screen.dart';
import 'profile_screen.dart';

class _SearchEntry {
  final String label;
  final List<FamilyMember> members;

  const _SearchEntry(this.label, this.members);
}

class FamilyTreeScreen extends StatefulWidget {
  final int navIndex;
  final ValueChanged<int> onNavSelect;

  const FamilyTreeScreen({
    super.key,
    this.navIndex = 2,
    this.onNavSelect = _noop,
  });

  static void _noop(int _) {}

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  static const double _canvasWidth = 412;
  static const double _canvasHeight = 917;

  FamilyMember? _selectedMember;
  Offset? _menuPosition;
  Offset? _nodeScreenPosition;
  double _nodeScale = 1.0;

  final TransformationController _transformCtrl = TransformationController();
  final TextEditingController _searchCtrl = TextEditingController();
  List<_SearchEntry> _searchResults = [];
  bool _isSearching = false;

  static const Map<String, Offset> _nodePositions = {
    'anant': Offset(-41 - 17, 167.5),
    'prerna': Offset(97 - 17, 167.5),
    'ashish': Offset(107 - 17, 334),
    'aparna': Offset(240 - 17, 334),
    'meera': Offset(396 - 17, 334),
    'riya': Offset(107 - 17, 485),
  };

  late final List<_SearchEntry> _searchCorpus = [
    _SearchEntry('cousins', [FamilyTreeMock.meera]),
    _SearchEntry('first cousins', [FamilyTreeMock.meera]),
    _SearchEntry('paternal cousins', [FamilyTreeMock.anant, FamilyTreeMock.prerna]),
    _SearchEntry('maternal cousins', [FamilyTreeMock.aparna]),
    _SearchEntry('grandparents', [FamilyTreeMock.anant, FamilyTreeMock.prerna]),
    _SearchEntry('parents', [FamilyTreeMock.ashish, FamilyTreeMock.aparna]),
    _SearchEntry('siblings', [FamilyTreeMock.riya]),
    _SearchEntry('uncle', [FamilyTreeMock.ashish]),
    _SearchEntry('aunt', [FamilyTreeMock.meera]),
    ...FamilyTreeMock.all
        .where((m) => !m.isPlaceholder)
        .map((m) => _SearchEntry(m.name, [m])),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  void _onNodeTap(FamilyMember member, Offset nodeCanvasTopLeft) {
    final matrix = _transformCtrl.value;
    final scaled = MatrixUtils.transformPoint(matrix, nodeCanvasTopLeft);
    final scale = matrix.getMaxScaleOnAxis();

    setState(() {
      if (_selectedMember?.id == member.id) {
        _selectedMember = null;
        _menuPosition = null;
        _nodeScreenPosition = null;
      } else {
        _selectedMember = member;
        _nodeScreenPosition = scaled;
        _nodeScale = scale;

        final nodeScreenH = 100 * scale;
        final screenW = MediaQuery.of(context).size.width;
        const menuW = 180.0;
        var dx = scaled.dx;
        if (dx + menuW > screenW - 12) dx = screenW - menuW - 12;
        if (dx < 12) dx = 12;
        _menuPosition = Offset(dx, scaled.dy + nodeScreenH);
      }
    });
  }

  void _dismissMenu() {
    setState(() {
      _selectedMember = null;
      _menuPosition = null;
      _nodeScreenPosition = null;
    });
  }

  void _openAddRelative(
    BuildContext context, {
    required Relation relation,
    String? subjectName,
    String pronounPossessive = 'her',
  }) {
    _dismissMenu();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddRelativeScreen(
          relation: relation,
          subjectName: subjectName,
          pronounPossessive: pronounPossessive,
        ),
      ),
    );
  }

  void _openAddRelativeForMember(BuildContext context, FamilyMember m) {
    _dismissMenu();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x26000000),
      builder: (_) => FamilyMemberProfileSheet(member: m, initialTab: 1),
    );
  }

  void _openAddMemory(BuildContext context, FamilyMember m) {
    _dismissMenu();
    showFamilyMemberProfileSheet(context, m);
  }

  void _openViewProfile(BuildContext context, FamilyMember m) {
    _dismissMenu();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          member: m,
          isSelf: m.id == FamilyTreeMock.riya.id,
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    final q = query.toLowerCase();
    final matches = _searchCorpus.where((entry) {
      return _fuzzyMatch(entry.label.toLowerCase(), q);
    }).toList();
    setState(() {
      _searchResults = matches;
      _isSearching = true;
    });
  }

  bool _fuzzyMatch(String text, String query) {
    int qi = 0;
    for (int i = 0; i < text.length && qi < query.length; i++) {
      if (text[i] == query[qi]) qi++;
    }
    return qi == query.length;
  }

  void _navigateToMember(FamilyMember member) {
    final pos = _nodePositions[member.id];
    if (pos == null) return;

    _searchCtrl.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
    FocusScope.of(context).unfocus();

    final viewSize = MediaQuery.of(context).size;
    const nodeW = 100.0;
    const nodeH = 100.0;
    final targetX = pos.dx + nodeW / 2;
    final targetY = pos.dy + nodeH / 2;
    final scale = 1.5;
    final dx = viewSize.width / 2 - targetX * scale;
    final dy = viewSize.height / 2 - targetY * scale;

    final m = Matrix4.identity();
    m.storage[0] = scale;
    m.storage[5] = scale;
    m.storage[12] = dx;
    m.storage[13] = dy;
    _transformCtrl.value = m;
  }

  void _onSearchResultTap(_SearchEntry entry) {
    _navigateToMember(entry.members.first);
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  Widget _heart({required double left, required double top}) {
    return Positioned(
      left: left,
      top: top,
      child: Icon(
        PhosphorIcons.heart(PhosphorIconsStyle.fill),
        size: 12,
        color: const Color(0xFF7E2525),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F0),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FamilyTreeHeader(
              searchController: _searchCtrl,
              onSearchChanged: _onSearchChanged,
              onMenu: () => _snack(context, 'Menu'),
            ),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: DotGridBackground()),

                  InteractiveViewer(
                      transformationController: _transformCtrl,
                      onInteractionStart: (_) {
                        if (_selectedMember != null) _dismissMenu();
                      },
                      minScale: 0.6,
                      maxScale: 2.5,
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(200),
                      child: SizedBox(
                        width: _canvasWidth,
                        height: _canvasHeight - 60 - 47,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Positioned.fill(child: ConnectorLines()),

                            _heart(left: 60, top: 201),
                            _heart(left: 353, top: 199),
                            _heart(left: 206, top: 366),

                            Positioned(
                              left: 130,
                              top: 158,
                              child: Icon(
                                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                                size: 12,
                                color: const Color(0xFFA07A23),
                                shadows: const [
                                  Shadow(
                                    color: Color(0xFFF6D046),
                                    blurRadius: 8.4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),

                            // Grandparents row (y=167.5).
                            _nodeAt(
                              left: -41 - 17,
                              top: 167.5,
                              member: FamilyTreeMock.anant,
                            ),
                            _nodeAt(
                              left: 97 - 17,
                              top: 167.5,
                              member: FamilyTreeMock.prerna,
                            ),
                            Positioned(
                              left: 251 - 17,
                              top: 167.5,
                              child: AddNode(
                                member: FamilyTreeMock.fatherPlaceholder,
                                onTap: () => _openAddRelative(
                                  context,
                                  relation: Relation.father,
                                  subjectName: FamilyTreeMock.aparna.name,
                                  pronounPossessive: 'her',
                                ),
                              ),
                            ),
                            Positioned(
                              left: 391 - 17,
                              top: 167.5,
                              child: AddNode(
                                member: FamilyTreeMock.motherPlaceholder,
                                onTap: () => _openAddRelative(
                                  context,
                                  relation: Relation.mother,
                                  subjectName: FamilyTreeMock.aparna.name,
                                  pronounPossessive: 'her',
                                ),
                              ),
                            ),

                            // Parents row (y=334).
                            _nodeAt(
                              left: 107 - 17,
                              top: 334,
                              member: FamilyTreeMock.ashish,
                            ),
                            _nodeAt(
                              left: 240 - 17,
                              top: 334,
                              member: FamilyTreeMock.aparna,
                            ),
                            _nodeAt(
                              left: 396 - 17,
                              top: 334,
                              member: FamilyTreeMock.meera,
                            ),

                            // Self + sibling (y=485/487).
                            _nodeAt(
                              left: 107 - 17,
                              top: 485,
                              member: FamilyTreeMock.riya,
                            ),
                            Positioned(
                              left: 240 - 17,
                              top: 487,
                              child: AddNode(
                                member: FamilyTreeMock.siblingPlaceholder,
                                onTap: () => _openAddRelative(
                                  context,
                                  relation: Relation.sibling,
                                  subjectName: FamilyTreeMock.riya.name,
                                  pronounPossessive: 'her',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: TimeTravelBar(),
                  ),

                  if (_selectedMember != null && _menuPosition != null)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _dismissMenu,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: const Color(0x4D000000),
                          ),
                        ),
                      ),
                    ),

                  if (_selectedMember != null && _nodeScreenPosition != null)
                    Positioned(
                      left: _nodeScreenPosition!.dx,
                      top: _nodeScreenPosition!.dy,
                      child: Transform.scale(
                        scale: _nodeScale,
                        alignment: Alignment.topLeft,
                        child: FamilyNode(member: _selectedMember!),
                      ),
                    ),

                  if (_selectedMember != null && _menuPosition != null)
                    Positioned(
                      left: _menuPosition!.dx,
                      top: _menuPosition!.dy,
                      child: Transform.scale(
                        scale: _nodeScale,
                        alignment: Alignment.topLeft,
                        child: FamilyNodeMenu(
                        member: _selectedMember!,
                        onAddRelative: () =>
                            _openAddRelativeForMember(context, _selectedMember!),
                        onViewTree: () {
                          _dismissMenu();
                          _snack(context, 'View tree');
                        },
                        onAddMemory: () =>
                            _openAddMemory(context, _selectedMember!),
                        onViewProfile: () =>
                            _openViewProfile(context, _selectedMember!),
                        onDismiss: _dismissMenu,
                      ),
                    ),
                    ),

                  // Floating add button.
                  if (!_isSearching)
                    Positioned(
                      right: 12,
                      bottom: 58,
                      child: GestureDetector(
                        onTap: () => _openAddRelative(
                          context,
                          relation: Relation.child,
                          subjectName: FamilyTreeMock.riya.name,
                          pronounPossessive: 'her',
                        ),
                        child: Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF191919),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '+',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 28,
                              color: Colors.white,
                              height: 1.14,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_isSearching && _searchResults.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: _searchResults.map((entry) {
                            return GestureDetector(
                              onTap: () => _onSearchResultTap(entry),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 18,
                                  child: Text(
                                    entry.label,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 16 * 0.06,
                                      color: Color(0xFF1D1E09),
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            BottomNav(
              selectedIndex: widget.navIndex,
              onSelect: widget.onNavSelect,
            ),
          ],
        ),
      ),
    );
  }

  Widget _nodeAt({
    required double left,
    required double top,
    required FamilyMember member,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: FamilyNode(
        member: member,
        onTap: () => _onNodeTap(member, Offset(left, top)),
      ),
    );
  }
}
