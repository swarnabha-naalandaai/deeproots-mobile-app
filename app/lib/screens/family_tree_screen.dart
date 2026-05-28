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
import '../widgets/family/family_tree_header.dart';
import '../widgets/family/time_travel_bar.dart';

class FamilyTreeScreen extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavSelect;

  const FamilyTreeScreen({
    super.key,
    this.navIndex = 2,
    this.onNavSelect = _noop,
  });

  static void _noop(int _) {}

  static const double _canvasWidth = 412;
  static const double _canvasHeight = 917;

  void _openDetail(BuildContext context, FamilyMember m) {
    showFamilyMemberProfileSheet(context, m);
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
              onMenu: () => _snack(context, 'Menu'),
            ),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: DotGridBackground()),
                  InteractiveViewer(
                    minScale: 0.6,
                    maxScale: 2.5,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(200),
                    child: SizedBox(
                      width: _canvasWidth,
                      height: _canvasHeight - 60 - 47, // minus header + nav
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned.fill(child: ConnectorLines()),

                          // Hearts between couples.
                          _heart(left: 60, top: 201),
                          _heart(left: 353, top: 199),
                          _heart(left: 206, top: 366),

                          // Sparkle accent.
                          Positioned(
                            left: 129,
                            top: 151,
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
                          Positioned(
                            left: -41 - 17, // shift label container
                            top: 167.5,
                            child: FamilyNode(
                              member: FamilyTreeMock.anant,
                              onTap: () => _openDetail(context, FamilyTreeMock.anant),
                            ),
                          ),
                          Positioned(
                            left: 97 - 17,
                            top: 167.5,
                            child: FamilyNode(
                              member: FamilyTreeMock.prerna,
                              onTap: () => _openDetail(context, FamilyTreeMock.prerna),
                            ),
                          ),
                          Positioned(
                            left: 251 - 17,
                            top: 167.5,
                            child: AddNode(
                              member: FamilyTreeMock.fatherPlaceholder,
                              onTap: () => _snack(context, 'Add Father'),
                            ),
                          ),
                          Positioned(
                            left: 391 - 17,
                            top: 167.5,
                            child: AddNode(
                              member: FamilyTreeMock.motherPlaceholder,
                              onTap: () => _snack(context, 'Add Mother'),
                            ),
                          ),

                          // Parents row (y=334).
                          Positioned(
                            left: 107 - 17,
                            top: 334,
                            child: FamilyNode(
                              member: FamilyTreeMock.ashish,
                              onTap: () => _openDetail(context, FamilyTreeMock.ashish),
                            ),
                          ),
                          Positioned(
                            left: 240 - 17,
                            top: 334,
                            child: FamilyNode(
                              member: FamilyTreeMock.aparna,
                              onTap: () => _openDetail(context, FamilyTreeMock.aparna),
                            ),
                          ),
                          Positioned(
                            left: 396 - 17,
                            top: 334,
                            child: FamilyNode(
                              member: FamilyTreeMock.meera,
                              onTap: () => _openDetail(context, FamilyTreeMock.meera),
                            ),
                          ),

                          // Self + sibling (y=485/487).
                          Positioned(
                            left: 107 - 17,
                            top: 485,
                            child: FamilyNode(
                              member: FamilyTreeMock.riya,
                              onTap: () => _openDetail(context, FamilyTreeMock.riya),
                            ),
                          ),
                          Positioned(
                            left: 240 - 17,
                            top: 487,
                            child: AddNode(
                              member: FamilyTreeMock.siblingPlaceholder,
                              onTap: () => _snack(context, 'Add Sibling'),
                            ),
                          ),

                          // Time travel bar (y≈808).
                          const Positioned(
                            left: 0,
                            right: 0,
                            top: 805,
                            child: SizedBox(
                              height: 50,
                              child: TimeTravelBar(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating add button (anchored bottom-right above nav).
                  Positioned(
                    right: 12,
                    bottom: 58,
                    child: GestureDetector(
                      onTap: () => _snack(context, 'Add family member'),
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
                ],
              ),
            ),
            BottomNav(
              selectedIndex: navIndex,
              onSelect: onNavSelect,
            ),
          ],
        ),
      ),
    );
  }
}
