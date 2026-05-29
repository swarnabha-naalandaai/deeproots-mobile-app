import 'dart:math';
import 'package:flutter/material.dart';
import 'family_member.dart';

class Position {
  final double x;
  final double y;
  const Position(this.x, this.y);
}

class LayoutResult {
  final Map<String, Position> positions;
  final double width;
  final double height;
  final double minX;
  final double minY;

  LayoutResult({
    required this.positions,
    required this.width,
    required this.height,
    required this.minX,
    required this.minY,
  });
}

class PathStep {
  final String dir; // "P" (parent), "C" (child), "S" (spouse)
  final String via;
  final String to;
  PathStep(this.dir, this.via, this.to);
}

class FamilyTreeState {
  final Map<String, FamilyMember> people;
  final List<List<String>> partners; // List of pairs of person IDs
  final List<List<String>> parentChild; // List of [parent ID, child ID]
  final String? meId;

  FamilyTreeState({
    required this.people,
    required this.partners,
    required this.parentChild,
    this.meId,
  });

  // Factory to build initial mock tree state
  factory FamilyTreeState.initialMock() {
    final people = <String, FamilyMember>{
      'riya': const FamilyMember(
        id: 'riya',
        name: 'Riya',
        subtitle: 'You',
        relation: Relation.self,
      ),
      'ashish': const FamilyMember(
        id: 'ashish',
        name: 'Ashish K. Dey',
        relation: Relation.father,
      ),
      'aparna': const FamilyMember(
        id: 'aparna',
        name: 'Aparna Dey',
        relation: Relation.mother,
        badgeCount: 2,
      ),
      'anant': const FamilyMember(
        id: 'anant',
        name: 'Anant Dey',
        relation: Relation.grandfather,
      ),
      'prerna': const FamilyMember(
        id: 'prerna',
        name: 'Prerna Dey',
        relation: Relation.grandmother,
        lifespan: '1944-2006',
        deceased: true,
      ),
      'meera': const FamilyMember(
        id: 'meera',
        name: 'Meera Dutta',
        relation: Relation.mother, // cousin/aunt placeholder
      ),
    };

    final partners = <List<String>>[
      ['anant', 'prerna'],
      ['ashish', 'aparna'],
    ];

    final parentChild = <List<String>>[
      ['anant', 'ashish'],
      ['prerna', 'ashish'],
      ['ashish', 'riya'],
      ['aparna', 'riya'],
    ];

    return FamilyTreeState(
      people: people,
      partners: partners,
      parentChild: parentChild,
      meId: 'riya',
    );
  }

  // Create a copy of this state with some fields replaced
  FamilyTreeState copyWith({
    Map<String, FamilyMember>? people,
    List<List<String>>? partners,
    List<List<String>>? parentChild,
    String? meId,
  }) {
    return FamilyTreeState(
      people: people ?? Map.from(this.people),
      partners: partners ?? List.from(this.partners),
      parentChild: parentChild ?? List.from(this.parentChild),
      meId: meId ?? this.meId,
    );
  }

  // Helper getters
  List<String> getPartners(String id) {
    return partners
        .where((p) => p.contains(id))
        .map((p) => p[0] == id ? p[1] : p[0])
        .toList();
  }

  List<String> getParents(String id) {
    return parentChild.where((pc) => pc[1] == id).map((pc) => pc[0]).toList();
  }

  List<String> getChildren(String id) {
    return parentChild.where((pc) => pc[0] == id).map((pc) => pc[1]).toList();
  }

  List<String> getSiblings(String id) {
    final parents = getParents(id);
    if (parents.isEmpty) return [];
    final sibs = <String>{};
    for (final p in parents) {
      for (final c in getChildren(p)) {
        if (c != id) sibs.add(c);
      }
    }
    return sibs.toList();
  }

  List<String> getAncestors(String id) {
    final ancestors = <String>{};
    void walk(String p) {
      for (final parent in getParents(p)) {
        if (!ancestors.contains(parent)) {
          ancestors.add(parent);
          walk(parent);
        }
      }
    }
    walk(id);
    return ancestors.toList();
  }

  List<String> getDescendants(String id) {
    final descendants = <String>{};
    void walk(String p) {
      for (final child in getChildren(p)) {
        if (!descendants.contains(child)) {
          descendants.add(child);
          walk(child);
        }
      }
    }
    walk(id);
    return descendants.toList();
  }

  bool isPartner(String a, String b) {
    return partners.any((p) => p.contains(a) && p.contains(b));
  }

  // Eligibility lists
  List<String> eligibleNewPartners(String id) {
    final ancestors = getAncestors(id);
    final descendants = getDescendants(id);
    return people.keys.where((o) {
      if (o == id) return false;
      if (isPartner(id, o)) return false;
      if (ancestors.contains(o) || descendants.contains(o)) return false;
      return true;
    }).toList();
  }

  List<String> eligibleNewParents(String id) {
    if (getParents(id).length >= 2) return [];
    final descendants = getDescendants(id);
    final cur = getParents(id).toSet();
    final parts = getPartners(id).toSet();
    return people.keys.where((o) {
      if (o == id) return false;
      if (cur.contains(o)) return false;
      if (descendants.contains(o)) return false;
      if (parts.contains(o)) return false;
      return true;
    }).toList();
  }

  List<String> eligibleNewChildren(String id) {
    final ancestors = getAncestors(id);
    final cur = getChildren(id).toSet();
    final parts = getPartners(id).toSet();
    return people.keys.where((o) {
      if (o == id) return false;
      if (cur.contains(o)) return false;
      if (ancestors.contains(o)) return false;
      if (parts.contains(o)) return false;
      return true;
    }).toList();
  }

  List<String> eligibleNewSiblings(String id) {
    final cur = getSiblings(id).toSet()..add(id);
    final ancestors = getAncestors(id);
    final descendants = getDescendants(id);
    final parts = getPartners(id).toSet();
    return people.keys.where((o) {
      if (cur.contains(o)) return false;
      if (ancestors.contains(o) || descendants.contains(o)) return false;
      if (parts.contains(o)) return false;
      return true;
    }).toList();
  }

  // Kinship Path Finding
  List<PathStep>? findKinshipPath(String fromId, String toId) {
    if (fromId == toId) return [];
    final visited = <String, List<PathStep>>{};
    visited[fromId] = [];
    final queue = [fromId];

    while (queue.isNotEmpty) {
      final cur = queue.removeAt(0);
      final curPath = visited[cur]!;

      final moves = <_Move>[];
      for (final p in getParents(cur)) {
        moves.add(_Move(p, "P"));
      }
      for (final c in getChildren(cur)) {
        moves.add(_Move(c, "C"));
      }
      for (final s in getPartners(cur)) {
        moves.add(_Move(s, "S"));
      }

      for (final m in moves) {
        if (visited.containsKey(m.id)) continue;
        final newPath = [...curPath, PathStep(m.dir, cur, m.id)];
        visited[m.id] = newPath;
        if (m.id == toId) return newPath;
        queue.add(m.id);
      }
    }
    return null;
  }

  String pathToLabel(List<PathStep> path, String targetId) {
    final target = people[targetId];
    if (target == null) return "";
    final g = inferGender(target);
    final dirs = path.map((s) => s.dir).join("");

    if (dirs == "S") return g == "F" ? "Wife" : g == "M" ? "Husband" : "Spouse";
    if (dirs == "P") return g == "F" ? "Mother" : g == "M" ? "Father" : "Parent";
    if (dirs == "C") return g == "F" ? "Daughter" : g == "M" ? "Son" : "Child";
    if (dirs == "PC") return g == "F" ? "Sister" : g == "M" ? "Brother" : "Sibling";

    if (dirs == "PP") {
      final parentId = path[0].to;
      final parentG = inferGender(people[parentId]);
      if (parentG == "M") return g == "F" ? "Paternal Grandmother" : g == "M" ? "Paternal Grandfather" : "Grandparent";
      if (parentG == "F") return g == "F" ? "Maternal Grandmother" : g == "M" ? "Maternal Grandfather" : "Grandparent";
      return g == "F" ? "Grandmother" : g == "M" ? "Grandfather" : "Grandparent";
    }
    if (dirs == "CC") return g == "F" ? "Granddaughter" : g == "M" ? "Grandson" : "Grandchild";

    if (dirs == "PPC") {
      final parentId = path[0].to;
      final parentG = inferGender(people[parentId]);
      if (parentG == "M") return g == "F" ? "Paternal Aunt" : g == "M" ? "Paternal Uncle" : "Uncle/Aunt";
      if (parentG == "F") return g == "F" ? "Maternal Aunt" : g == "M" ? "Maternal Uncle" : "Uncle/Aunt";
      return g == "F" ? "Aunt" : g == "M" ? "Uncle" : "Uncle/Aunt";
    }

    if (dirs == "PCC") return g == "F" ? "Niece" : g == "M" ? "Nephew" : "Niece/Nephew";
    if (dirs == "PPCC") return "Cousin";

    if (dirs == "SP") return g == "F" ? "Mother-in-law" : g == "M" ? "Father-in-law" : "Parent-in-law";
    if (dirs == "CS") return g == "F" ? "Daughter-in-law" : g == "M" ? "Son-in-law" : "Child-in-law";
    if (dirs == "PCS" || dirs == "SPC") return g == "F" ? "Sister-in-law" : g == "M" ? "Brother-in-law" : "Sibling-in-law";
    if (dirs == "PS") return g == "F" ? "Step-mother" : g == "M" ? "Step-father" : "Step-parent";

    if (RegExp(r"^P+$").hasMatch(dirs)) {
      final greats = dirs.length - 2;
      return _greatPrefix(greats) + (g == "F" ? "Grandmother" : g == "M" ? "Grandfather" : "Grandparent");
    }
    if (RegExp(r"^C+$").hasMatch(dirs)) {
      final greats = dirs.length - 2;
      return _greatPrefix(greats) + (g == "F" ? "Granddaughter" : g == "M" ? "Grandson" : "Grandchild");
    }
    return "Family";
  }

  String _greatPrefix(int n) {
    if (n <= 0) return "";
    return "Great-" * n;
  }

  String? inferGender(FamilyMember? person) {
    if (person == null) return null;
    final relation = person.relation;
    if (relation == Relation.father || relation == Relation.grandfather) {
      return "M";
    }
    if (relation == Relation.mother || relation == Relation.grandmother) {
      return "F";
    }
    final name = person.name.toLowerCase();
    if (name.contains("sister") ||
        name.contains("mother") ||
        name.contains("wife") ||
        name.contains("daughter") ||
        name.contains("aparna") ||
        name.contains("riya") ||
        name.contains("prerna") ||
        name.contains("meera") ||
        name.contains("mami") ||
        name.contains("nani") ||
        name.contains("dadi") ||
        name.contains("bua") ||
        name.contains("mausi")) {
      return "F";
    }
    if (name.contains("brother") ||
        name.contains("father") ||
        name.contains("husband") ||
        name.contains("son") ||
        name.contains("ashish") ||
        name.contains("anant") ||
        name.contains("chacha") ||
        name.contains("nana") ||
        name.contains("dada") ||
        name.contains("mama") ||
        name.contains("mausa")) {
      return "M";
    }
    return null;
  }

  String relationToSelf(String targetId) {
    if (meId == null || targetId == meId) return "You";
    final path = findKinshipPath(meId!, targetId);
    if (path == null) return "";
    return pathToLabel(path, targetId);
  }

  // ─── Generates placeholders dynamically ───
  FamilyTreeState withPlaceholders() {
    if (meId == null) return this;

    final newPeople = Map<String, FamilyMember>.from(people);
    final newPartners = List<List<String>>.from(partners);
    final newParentChild = List<List<String>>.from(parentChild);

    // 1. Add grandparent placeholders (parents of aparna/mother and ashish/father if missing)
    final myParents = getParents(meId!);
    for (final parentId in myParents) {
      final pParents = getParents(parentId);
      final pMember = people[parentId];
      if (pMember != null && pMember.relation == Relation.mother) {
        // Self-heal sibling links: ensure 'meera' shares all real parents of 'aparna'
        if (parentId == 'aparna' && newPeople.containsKey('meera')) {
          for (final pId in pParents) {
            final alreadyLinked = newParentChild.any((pc) => pc[0] == pId && pc[1] == 'meera');
            if (!alreadyLinked) {
              newParentChild.add([pId, 'meera']);
            }
          }
        }

        bool hasFather = false;
        bool hasMother = false;
        String? realFatherId;
        String? realMotherId;

        for (final pId in pParents) {
          final g = inferGender(people[pId]);
          if (g == "M") {
            hasFather = true;
            realFatherId = pId;
          } else if (g == "F") {
            hasMother = true;
            realMotherId = pId;
          }
        }

        final fPId = '${parentId}_father_p';
        final mPId = '${parentId}_mother_p';

        if (!hasFather) {
          if (!newPeople.containsKey(fPId)) {
            newPeople[fPId] = FamilyMember(
              id: fPId,
              name: 'Father',
              relation: Relation.father,
              isPlaceholder: true,
              placeholderTint: const Color(0xFFC8D1CE),
            );
            newParentChild.add([fPId, parentId]);
            if (parentId == 'aparna' && newPeople.containsKey('meera')) {
              newParentChild.add([fPId, 'meera']);
            }
          }
        }

        if (!hasMother) {
          if (!newPeople.containsKey(mPId)) {
            newPeople[mPId] = FamilyMember(
              id: mPId,
              name: 'Mother',
              relation: Relation.mother,
              isPlaceholder: true,
              placeholderTint: const Color(0xFFDDD7CD),
            );
            newParentChild.add([mPId, parentId]);
            if (parentId == 'aparna' && newPeople.containsKey('meera')) {
              newParentChild.add([mPId, 'meera']);
            }
          }
        }

        final fatherId = hasFather ? realFatherId! : fPId;
        final motherId = hasMother ? realMotherId! : mPId;

        final hasPartner = newPartners.any((p) => p.contains(fatherId) && p.contains(motherId));
        if (!hasPartner) {
          newPartners.add([fatherId, motherId]);
        }
      }
    }

    return FamilyTreeState(
      people: newPeople,
      partners: newPartners,
      parentChild: newParentChild,
      meId: meId,
    );
  }

  // Pure layout algorithm
  Map<String, Position> computeLayout({
    double nodeW = 110.0,
    double nodeH = 114.0,
    double genGapY = 60.0,
    double nodeGapX = 16.0,
    double coupleGapX = 12.0,
    double familyGapX = 32.0,
  }) {
    final positions = <String, Position>{};
    if (people.isEmpty) return positions;

    final gen = computeGenerations(people, partners, parentChild, meId);
    final dist = computeDistFromSelf(people, partners, parentChild, meId);

    final anchorOf = <String, String>{};
    final anchors = <String, Anchor>{};
    int nextAid = 0;

    final sortedIds = people.keys.toList()
      ..sort((a, b) => (dist[a] ?? 999).compareTo(dist[b] ?? 999));

    for (final id in sortedIds) {
      if (anchorOf[id] != null) continue;
      final aid = "a${nextAid++}";

      // Find partner at same generation that doesn't have an anchor yet
      String? partner;
      for (final p in getPartners(id)) {
        if (gen[p] == gen[id] && anchorOf[p] == null) {
          partner = p;
          break;
        }
      }

      final ids = partner != null ? [id, partner] : [id];
      anchors[aid] = Anchor(
        id: aid,
        ids: ids,
        gen: gen[id] ?? 0,
        children: [],
      );

      anchorOf[id] = aid;
      if (partner != null) {
        anchorOf[partner] = aid;
      }
    }

    // Determine primary parent
    for (final anc in anchors.values) {
      final parentSet = <String>{};
      for (final id in anc.ids) {
        parentSet.addAll(getParents(id));
      }
      if (parentSet.isEmpty) continue;

      final parentAids = parentSet.map((p) => anchorOf[p]!).toSet();
      String? bestPaid;
      int bestD = 999999;

      for (final paid in parentAids) {
        final minD = anchors[paid]!.ids.map((p) => dist[p] ?? 999999).reduce(min);
        if (minD < bestD) {
          bestD = minD;
          bestPaid = paid;
        }
      }

      anc.primaryParent = bestPaid;
      if (bestPaid != null) {
        anchors[bestPaid]!.children.add(anc.id);
      }
    }

    // Recursive width calculation
    double widthOf(String aid) {
      final anc = anchors[aid]!;
      if (anc.w != null) return anc.w!;
      final selfW = anc.ids.length == 2 ? 2 * nodeW + coupleGapX : nodeW;

      double childW = 0;
      for (var i = 0; i < anc.children.length; i++) {
        if (i > 0) childW += nodeGapX;
        childW += widthOf(anc.children[i]);
      }

      anc.sw = selfW;
      anc.cw = childW;
      anc.w = max(selfW, childW);
      return anc.w!;
    }

    // Recursive placement
    void place(String aid, double leftX) {
      final anc = anchors[aid]!;
      final w = anc.w!;
      final selfW = anc.sw!;
      final childW = anc.cw!;

      double cx = leftX + (w - childW) / 2;
      for (var i = 0; i < anc.children.length; i++) {
        final cid = anc.children[i];
        if (i > 0) cx += nodeGapX;
        place(cid, cx);
        cx += anchors[cid]!.w!;
      }

      double selfLeft;
      if (anc.children.isNotEmpty) {
        double sum = 0;
        for (final cid in anc.children) {
          final cAnc = anchors[cid]!;
          final cCenter = positions[cAnc.ids[0]]!.x + cAnc.sw! / 2;
          sum += cCenter;
        }
        selfLeft = sum / anc.children.length - selfW / 2;
      } else {
        selfLeft = leftX + (w - selfW) / 2;
      }

      final y = anc.gen * (nodeH + genGapY) - nodeH / 2;
      if (anc.ids.length == 2) {
        if (anc.children.length >= 2) {
          final firstCid = anc.children.first;
          final lastCid = anc.children.last;
          final firstAnc = anchors[firstCid]!;
          final lastAnc = anchors[lastCid]!;

          final centerFirst = positions[firstAnc.ids[0]]!.x + firstAnc.sw! / 2;
          final centerLast = positions[lastAnc.ids[0]]!.x + lastAnc.sw! / 2;

          positions[anc.ids[0]] = Position(centerFirst - nodeW / 2, y);
          positions[anc.ids[1]] = Position(centerLast - nodeW / 2, y);
        } else {
          positions[anc.ids[0]] = Position(selfLeft, y);
          positions[anc.ids[1]] = Position(selfLeft + nodeW + coupleGapX, y);
        }
      } else {
        positions[anc.ids[0]] = Position(selfLeft, y);
      }
    }

    final rootAids = anchors.values
        .where((a) => a.primaryParent == null)
        .map((a) => a.id)
        .toList();

    for (final rid in rootAids) {
      widthOf(rid);
    }

    rootAids.sort((a, b) {
      final da = anchors[a]!.ids.map((p) => dist[p] ?? 999).reduce(min);
      final db = anchors[b]!.ids.map((p) => dist[p] ?? 999).reduce(min);
      return da.compareTo(db);
    });

    double rootX = 0;
    for (final rid in rootAids) {
      place(rid, rootX);
      rootX += anchors[rid]!.w! + familyGapX;
    }

    // Align all parent couples perfectly above their children's midpoint
    for (final anc in anchors.values) {
      if (anc.ids.length == 2 && anc.children.isNotEmpty) {
        double sumX = 0;
        int count = 0;
        for (final childAid in anc.children) {
          final cAnc = anchors[childAid]!;
          for (final cId in cAnc.ids) {
            final pos = positions[cId];
            if (pos != null) {
              sumX += pos.x + nodeW / 2;
              count++;
            }
          }
        }
        if (count > 0) {
          final targetCenter = sumX / count;
          final p0 = positions[anc.ids[0]];
          final p1 = positions[anc.ids[1]];
          if (p0 != null && p1 != null) {
            final curCenter = (p0.x + p1.x + nodeW) / 2;
            final dx = targetCenter - curCenter;
            positions[anc.ids[0]] = Position(p0.x + dx, p0.y);
            positions[anc.ids[1]] = Position(p1.x + dx, p1.y);
          }
        }
      }
    }

    // Adjust relative to meId so meId is at x = 0
    if (meId != null && positions[meId] != null) {
      final off = positions[meId]!.x;
      for (final entry in positions.entries) {
        positions[entry.key] = Position(entry.value.x - off, entry.value.y);
      }
    }

    return positions;
  }

  // Computes positive layout result with dynamic canvas bounds
  LayoutResult getShiftedLayout({
    double paddingX = 60.0,
    double paddingY = 60.0,
    double nodeW = 110.0,
    double nodeH = 114.0,
    double genGapY = 60.0,
    double nodeGapX = 16.0,
    double coupleGapX = 12.0,
    double familyGapX = 32.0,
  }) {
    final rawPositions = computeLayout(
      nodeW: nodeW,
      nodeH: nodeH,
      genGapY: genGapY,
      nodeGapX: nodeGapX,
      coupleGapX: coupleGapX,
      familyGapX: familyGapX,
    );

    if (rawPositions.isEmpty) {
      return LayoutResult(
        positions: {},
        width: 400,
        height: 400,
        minX: 0,
        minY: 0,
      );
    }

    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (final pos in rawPositions.values) {
      if (pos.x < minX) minX = pos.x;
      if (pos.x > maxX) maxX = pos.x;
      if (pos.y < minY) minY = pos.y;
      if (pos.y > maxY) maxY = pos.y;
    }

    final shifted = <String, Position>{};
    for (final entry in rawPositions.entries) {
      shifted[entry.key] = Position(
        entry.value.x - minX + paddingX,
        entry.value.y - minY + paddingY,
      );
    }

    final width = maxX - minX + nodeW + (paddingX * 2);
    final height = maxY - minY + nodeH + (paddingY * 2);

    return LayoutResult(
      positions: shifted,
      width: width,
      height: height,
      minX: minX,
      minY: minY,
    );
  }

  // Heuristic generation helpers
  static Map<String, int> computeGenerations(
    Map<String, FamilyMember> people,
    List<List<String>> partners,
    List<List<String>> parentChild,
    String? meId,
  ) {
    final gen = <String, int>{};
    if (meId == null || !people.containsKey(meId)) return gen;
    gen[meId] = 0;
    final q = [meId];
    while (q.isNotEmpty) {
      final id = q.removeAt(0);
      final g = gen[id]!;

      // parents
      for (final pc in parentChild) {
        if (pc[1] == id) {
          final p = pc[0];
          if (gen[p] == null) {
            gen[p] = g - 1;
            q.add(p);
          }
        }
      }

      // children
      for (final pc in parentChild) {
        if (pc[0] == id) {
          final c = pc[1];
          if (gen[c] == null) {
            gen[c] = g + 1;
            q.add(c);
          }
        }
      }

      // partners
      for (final p in partners) {
        if (p.contains(id)) {
          final pt = p[0] == id ? p[1] : p[0];
          if (gen[pt] == null) {
            gen[pt] = g;
            q.add(pt);
          }
        }
      }
    }
    for (final id in people.keys) {
      gen[id] ??= 0;
    }
    return gen;
  }

  static Map<String, int> computeDistFromSelf(
    Map<String, FamilyMember> people,
    List<List<String>> partners,
    List<List<String>> parentChild,
    String? meId,
  ) {
    final dist = <String, int>{};
    if (meId == null) return dist;
    dist[meId] = 0;
    final q = [meId];
    while (q.isNotEmpty) {
      final cur = q.removeAt(0);
      final d = dist[cur]!;

      final neighbors = <String>[];
      for (final pc in parentChild) {
        if (pc[1] == cur) neighbors.add(pc[0]);
        if (pc[0] == cur) neighbors.add(pc[1]);
      }
      for (final p in partners) {
        if (p.contains(cur)) neighbors.add(p[0] == cur ? p[1] : p[0]);
      }

      for (final n in neighbors) {
        if (dist[n] == null) {
          dist[n] = d + 1;
          q.add(n);
        }
      }
    }
    return dist;
  }
}

class Anchor {
  final String id;
  final List<String> ids;
  final int gen;
  final List<String> children;
  String? primaryParent;
  double? w;
  double? sw;
  double? cw;

  Anchor({
    required this.id,
    required this.ids,
    required this.gen,
    required this.children,
    this.primaryParent,
  });
}

class _Move {
  final String id;
  final String dir;
  _Move(this.id, this.dir);
}
