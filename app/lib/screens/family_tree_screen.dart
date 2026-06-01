import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/family_member.dart';
import '../models/family_tree_state.dart';
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
  // Pure local state engine!
  late FamilyTreeState _treeState;

  FamilyMember? _selectedMember;
  Offset? _menuPosition;
  Offset? _nodeScreenPosition;
  double _nodeScale = 1.0;

  String? _lineageRootId;
  Set<String> _lineageIds = const {};

  final TransformationController _transformCtrl = TransformationController();
  final TextEditingController _searchCtrl = TextEditingController();
  List<_SearchEntry> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Hydrate the initial state
    _treeState = FamilyTreeState.initialMock();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  // Dynamic search corpus based on current members
  List<_SearchEntry> get _searchCorpus {
    final corpus = <_SearchEntry>[];
    
    // Add default category searches
    final allReal = _treeState.people.values.where((m) => !m.isPlaceholder).toList();
    
    final meera = _treeState.people['meera'];
    if (meera != null) {
      corpus.add(_SearchEntry('cousins', [meera]));
      corpus.add(_SearchEntry('first cousins', [meera]));
      corpus.add(_SearchEntry('aunt', [meera]));
    }
    
    final anant = _treeState.people['anant'];
    final prerna = _treeState.people['prerna'];
    if (anant != null || prerna != null) {
      final gps = [anant, prerna].whereType<FamilyMember>().toList();
      corpus.add(_SearchEntry('grandparents', gps));
      corpus.add(_SearchEntry('paternal grandparents', gps));
    }
    
    final ashish = _treeState.people['ashish'];
    final aparna = _treeState.people['aparna'];
    if (ashish != null || aparna != null) {
      final parents = [ashish, aparna].whereType<FamilyMember>().toList();
      corpus.add(_SearchEntry('parents', parents));
    }

    // Add each dynamic member search entry
    for (final member in allReal) {
      corpus.add(_SearchEntry(member.name, [member]));
      final rel = _treeState.relationToSelf(member.id);
      if (rel.isNotEmpty) {
        corpus.add(_SearchEntry(rel.toLowerCase(), [member]));
      }
    }
    
    return corpus;
  }

  void _onNodeTap(FamilyMember member, Offset nodeCanvasTopLeft) {
    if (member.isPlaceholder) {
      final childId = member.id.split('_').first; // e.g. 'aparna' from 'aparna_father_p'
      final child = _treeState.people[childId] ?? _treeState.people['riya']!;
      
      _openAddRelative(
        context,
        relation: member.relation,
        fromId: childId,
        subjectName: child.name,
        pronounPossessive: _possessiveFor(child),
      );
      return;
    }

    final matrix = _transformCtrl.value;
    final scaled = MatrixUtils.transformPoint(matrix, nodeCanvasTopLeft);
    final scale = matrix.getMaxScaleOnAxis();

    setState(() {
      _lineageRootId = null;
      _lineageIds = const {};
      if (_selectedMember?.id == member.id) {
        _selectedMember = null;
        _menuPosition = null;
        _nodeScreenPosition = null;
      } else {
        _selectedMember = member;
        _nodeScreenPosition = scaled;
        _nodeScale = scale;

        final nodeScreenH = 114 * scale;
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

  void _showLineageFor(FamilyMember member) {
    final ids = <String>{member.id};
    ids.addAll(_treeState.getAncestors(member.id));
    ids.addAll(_treeState.getDescendants(member.id));
    ids.addAll(_treeState.getPartners(member.id));
    ids.removeWhere((id) {
      final m = _treeState.people[id];
      return m == null || m.isPlaceholder;
    });
    setState(() {
      _selectedMember = null;
      _menuPosition = null;
      _nodeScreenPosition = null;
      _lineageRootId = member.id;
      _lineageIds = ids;
    });
  }

  void _clearLineage() {
    if (_lineageRootId == null) return;
    setState(() {
      _lineageRootId = null;
      _lineageIds = const {};
    });
  }

  Future<void> _openAddRelative(
    BuildContext context, {
    required Relation relation,
    required String fromId,
    String? subjectName,
    String pronounPossessive = 'her',
  }) async {
    _dismissMenu();
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddRelativeScreen(
          relation: relation,
          subjectName: subjectName,
          pronounPossessive: pronounPossessive,
        ),
      ),
    );

    if (result == null || !mounted) return;

    final String name = result['name'] ?? '';
    if (name.isEmpty) return;

    Relation targetRelation = relation;
    final String gender = result['gender'] ?? '';
    if (relation == Relation.father || relation == Relation.mother) {
      if (gender == 'Father') {
        targetRelation = Relation.father;
      } else if (gender == 'Mother') {
        targetRelation = Relation.mother;
      }
    } else if (relation == Relation.grandfather || relation == Relation.grandmother) {
      if (gender == 'Father') {
        targetRelation = Relation.grandfather;
      } else if (gender == 'Mother') {
        targetRelation = Relation.grandmother;
      }
    }

    final DateTime? birthDate = result['birthDate'] as DateTime?;
    final String lifespan = birthDate != null ? '${birthDate.year}-Present' : 'Present';

    setState(() {
      final newId = 'p_${DateTime.now().millisecondsSinceEpoch}';
      final newMember = FamilyMember(
        id: newId,
        name: name,
        relation: targetRelation,
        lifespan: lifespan,
      );

      final newPeople = Map<String, FamilyMember>.from(_treeState.people);
      newPeople[newId] = newMember;

      final newPartners = List<List<String>>.from(_treeState.partners);
      final newParentChild = List<List<String>>.from(_treeState.parentChild);

      if (targetRelation == Relation.father || targetRelation == Relation.mother) {
        newParentChild.add([newId, fromId]);
        
        final existingParents = _treeState.getParents(fromId);
        if (existingParents.isNotEmpty) {
          newPartners.add([newId, existingParents[0]]);
        }
        
        final renderedState = _treeState.withPlaceholders();
        final siblings = renderedState.getSiblings(fromId);
        for (final sibId in siblings) {
          if (!renderedState.people[sibId]!.isPlaceholder) {
            newParentChild.add([newId, sibId]);
          }
        }
      } else if (targetRelation == Relation.spouse) {
        newPartners.add([fromId, newId]);
      } else if (targetRelation == Relation.child) {
        newParentChild.add([fromId, newId]);
        
        final partners = _treeState.getPartners(fromId);
        if (partners.isNotEmpty) {
          newParentChild.add([partners[0], newId]);
        }
      } else if (targetRelation == Relation.sibling) {
        final parents = _treeState.getParents(fromId);
        for (final pId in parents) {
          newParentChild.add([pId, newId]);
        }
      }

      _treeState = FamilyTreeState(
        people: newPeople,
        partners: newPartners,
        parentChild: newParentChild,
        meId: _treeState.meId,
      );
    });
  }

  void _handleLinkExisting(String selectedId, Relation relation, FamilyMember subject) {
    setState(() {
      final newParentChild = List<List<String>>.from(_treeState.parentChild);
      final newPartners = List<List<String>>.from(_treeState.partners);

      if (relation == Relation.father || relation == Relation.mother) {
        if (!newParentChild.any((pc) => pc[0] == selectedId && pc[1] == subject.id)) {
          newParentChild.add([selectedId, subject.id]);
        }

        // Auto-heal/sync with siblings
        final siblings = _treeState.people.values
            .where((p) => p.relation == Relation.sibling && p.id != subject.id)
            .map((p) => p.id);
        for (final sibId in siblings) {
          if (!newParentChild.any((pc) => pc[0] == selectedId && pc[1] == sibId)) {
            newParentChild.add([selectedId, sibId]);
          }
        }
      } else if (relation == Relation.child) {
        if (!newParentChild.any((pc) => pc[0] == subject.id && pc[1] == selectedId)) {
          newParentChild.add([subject.id, selectedId]);
        }
      } else if (relation == Relation.spouse) {
        if (!newPartners.any((p) => (p[0] == selectedId && p[1] == subject.id) || (p[0] == subject.id && p[1] == selectedId))) {
          newPartners.add([selectedId, subject.id]);
        }
      } else if (relation == Relation.sibling) {
        final parents = _treeState.parentChild
            .where((pc) => pc[1] == subject.id)
            .map((pc) => pc[0])
            .toList();
        for (final pId in parents) {
          if (!newParentChild.any((pc) => pc[0] == pId && pc[1] == selectedId)) {
            newParentChild.add([pId, selectedId]);
          }
        }
      }

      _treeState = _treeState.copyWith(
        parentChild: newParentChild,
        partners: newPartners,
      );
    });
  }

  void _openAddRelativeForMember(BuildContext context, FamilyMember m) {
    _dismissMenu();
    showFamilyMemberProfileSheet(
      context,
      m,
      initialTab: 1,
      allMembers: _treeState.people.values.toList(),
      onLinkExisting: _handleLinkExisting,
      onAddRelative: (relation, subject) {
        _openAddRelative(
          context,
          relation: relation,
          fromId: subject.id,
          subjectName: subject.name,
          pronounPossessive: _possessiveFor(subject),
        );
      },
    );
  }

  void _openAddMemory(BuildContext context, FamilyMember m) {
    _dismissMenu();
    showFamilyMemberProfileSheet(
      context,
      m,
      initialTab: 0,
      allMembers: _treeState.people.values.toList(),
      onLinkExisting: _handleLinkExisting,
      onAddRelative: (relation, subject) {
        _openAddRelative(
          context,
          relation: relation,
          fromId: subject.id,
          subjectName: subject.name,
          pronounPossessive: _possessiveFor(subject),
        );
      },
    );
  }

  void _openViewProfile(BuildContext context, FamilyMember m) {
    _dismissMenu();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          member: m,
          isSelf: m.id == _treeState.meId,
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
    final renderedState = _treeState.withPlaceholders();
    final layoutResult = renderedState.getShiftedLayout();
    final pos = layoutResult.positions[member.id];
    if (pos == null) return;

    _searchCtrl.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
    FocusScope.of(context).unfocus();

    final viewSize = MediaQuery.of(context).size;
    const nodeW = 110.0;
    const nodeH = 114.0;
    final targetX = pos.x + nodeW / 2;
    final targetY = pos.y + nodeH / 2;
    final scale = 1.3;
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

  String _possessiveFor(FamilyMember m) {
    switch (m.relation) {
      case Relation.father:
      case Relation.grandfather:
        return 'his';
      case Relation.mother:
      case Relation.grandmother:
        return 'her';
      default:
        return 'their';
    }
  }

  List<Widget> _buildHearts(FamilyTreeState state, Map<String, Position> positions) {
    final hearts = <Widget>[];
    final painted = <String>{};
    for (final pair in state.partners) {
      final a = pair[0];
      final b = pair[1];
      if (painted.contains('$a-$b') || painted.contains('$b-$a')) continue;

      final pa = positions[a];
      final pb = positions[b];
      if (pa == null || pb == null) continue;

      final y = pa.y + 114 / 2 - 6; // Center height minus half heart height
      final x = (pa.x + pb.x + 110) / 2 - 6; // Midpoint minus half heart width

      hearts.add(
        Positioned(
          left: x,
          top: y,
          child: Icon(
            PhosphorIcons.heart(PhosphorIconsStyle.fill),
            size: 12,
            color: const Color(0xFF7E2525),
          ),
        ),
      );
      painted.add('$a-$b');
    }
    return hearts;
  }

  @override
  Widget build(BuildContext context) {
    final renderedState = _treeState.withPlaceholders();
    final layoutResult = renderedState.getShiftedLayout();
    final positions = layoutResult.positions;

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
                    minScale: 0.4,
                    maxScale: 2.5,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(400),
                    child: SizedBox(
                      // Dynamic size matching the computed tree boundary!
                      width: layoutResult.width,
                      height: layoutResult.height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: ConnectorLines(
                              state: renderedState,
                              positions: positions,
                              lineageIds: _lineageIds,
                            ),
                          ),

                          ..._buildHearts(renderedState, positions),

                          // Dynamically render all nodes at their computed layout coordinates!
                          ...renderedState.people.values.map((member) {
                            final pos = positions[member.id];
                            if (pos == null) return const SizedBox.shrink();

                            if (member.isPlaceholder) {
                              return Positioned(
                                left: pos.x,
                                top: pos.y,
                                child: AddNode(
                                  member: member,
                                  onTap: () => _onNodeTap(member, Offset(pos.x, pos.y)),
                                ),
                              );
                            }

                            return Positioned(
                              left: pos.x,
                              top: pos.y,
                              child: FamilyNode(
                                member: member,
                                highlighted: _lineageRootId == member.id,
                                onTap: () => _onNodeTap(member, Offset(pos.x, pos.y)),
                              ),
                            );
                          }),
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

                  if (_lineageRootId != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 12,
                      child: Center(
                        child: GestureDetector(
                          onTap: _clearLineage,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D1E09).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Lineage of ${_treeState.people[_lineageRootId!]?.name ?? ''}',
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.close, size: 14, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                        child: FamilyNode(
                          member: _selectedMember!,
                          highlighted: _lineageRootId == _selectedMember!.id,
                        ),
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
                          onViewTree: () => _showLineageFor(_selectedMember!),
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
                          fromId: _treeState.meId!,
                          subjectName: _treeState.people[_treeState.meId!]!.name,
                          pronounPossessive: _possessiveFor(_treeState.people[_treeState.meId!]!),
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
}
