# Family Tree — Implementation Plan

## Scope
Build Family Tree screen matching Figma spec (412×917 canvas). New route wired to bottom nav `TreeStructure` (index 2). Absolute Stack positioning, pixel-matched. Mock data layer. Pan/zoom canvas. Tap nodes → detail stub. Tap `+` placeholders/FAB → snackbar.

## Files to create

| Path | Purpose |
|---|---|
| `app/lib/models/family_member.dart` | `FamilyMember` model + `Relation` enum |
| `app/lib/models/family_tree_mock.dart` | Hardcoded mock list (Riya self + parents + grandparents + placeholders) |
| `app/lib/screens/family_tree_screen.dart` | Main screen |
| `app/lib/screens/family_member_detail_screen.dart` | Detail stub (tap target) |
| `app/lib/widgets/family/family_node.dart` | Avatar circle + name + dates |
| `app/lib/widgets/family/add_node.dart` | Gray `+` placeholder w/ role label |
| `app/lib/widgets/family/connector_lines.dart` | `CustomPainter` for connectors + rounded brackets |
| `app/lib/widgets/family/dot_grid_background.dart` | `CustomPainter` 3px dotted grid (32px gap) |
| `app/lib/widgets/family/family_tree_header.dart` | Back + search field + 3-dot menu |
| `app/lib/widgets/family/time_travel_bar.dart` | Line + endpoints + draggable dot + 1920/2026 labels + sparkle "TIME TRAVEL" |

## Files to edit
- `app/lib/main.dart` — `RootShell`: add `_navIndex == 2 → FamilyTreeScreen`

## Model

```dart
enum Relation {
  self, father, mother, grandfather, grandmother,
  sibling, spouse, child, placeholder,
}

class FamilyMember {
  final String id;
  final String name;
  final String? imageAsset;
  final String? lifespan;          // "1944-2006"
  final Relation relation;
  final bool deceased;
  final bool isPlaceholder;
  final Color? placeholderTint;    // C8D1CE / DDD7CD / D8D8D8
  final int badgeCount;            // Aparna "2"
}
```

## Screen layout (Stack, absolute, 412 canvas centered)

```
Scaffold (bg #F0F1F0)
└─ SafeArea → Column
   ├─ FamilyTreeHeader (white, ~63px)
   ├─ Expanded → InteractiveViewer(min 0.7, max 2.5)
   │   └─ SizedBox(412 × contentH) → Stack
   │      ├─ DotGridBackground (Positioned.fill)
   │      ├─ ConnectorLines CustomPaint (Vectors 7/10/11/14/15/16)
   │      ├─ Heart icons #7E2525 at (60,201) (353,199) (206,366)
   │      ├─ FamilyNode × real members
   │      │     Anant   (-41, 167)
   │      │     Prerna  ( 97, 167)
   │      │     Ashish  (107, 334)
   │      │     Riya    (107, 485)   ← 2px black border (self)
   │      ├─ AddNode × placeholders
   │      │     Father  (251, 167) tint C8D1CE
   │      │     Mother  (391, 167) tint DDD7CD
   │      │     Aparna  (240, 334) woman + sepia overlay
   │      │     Meera   (396, 334) woman + sepia overlay
   │      │     Sibling (240, 487) tint D8D8D8
   │      ├─ Red badge "2" (294, 331) over Aparna
   │      ├─ Sparkle #A07A23 (129, 151) gold drop-shadow
   │      └─ TimeTravelBar Positioned bottom y≈808
   ├─ FAB Positioned(right:12, bottom:118) 56px black "+"
   └─ Bottom nav (existing widget, index 2 active)
```

## Connectors (`CustomPainter`, stroke 1px `#5F5F5F`)
- Vector 14: rounded-rect 145,372 size 133×110 — Riya↔Sibling bracket up to parents
- Vector 7: H line 188→235, y=372 — drop into Aparna
- Vector 15: rounded-rect 66,206 size 79×126 — Anant+Prerna bracket
- Vector 10: mirrored rounded-rect 280,206 size 157×126 — Father+Mother bracket
- Vector 11/16: short H lines feeding bracket centers into Ashish/Aparna

## Interactions
- Tap real node → push `FamilyMemberDetailScreen(member)` (shows name + lifespan)
- Tap `+` placeholder → `SnackBar("Add ${role}")`
- Tap FAB → `SnackBar("Add family member")`
- `TimeTravelBar` dot drag along line → `SnackBar("Year: $year")` (no real filter yet)
- `InteractiveViewer` → pan + zoom whole canvas

## Visual specifics
- Avatars 76×76 circles, `CachedNetworkImage` + Phosphor `user` fallback (no mock png assets exist yet)
- Riya: 2px black border (self marker)
- Prerna deceased: lifespan text gray `#999999`, no overlay
- Aparna/Meera (deceased tint): woman placeholder + `rgba(193,163,115,0.2)` overlay
- Hearts: Phosphor `heart_fill` 12×12
- Sparkle: Phosphor `sparkle_fill` #A07A23 w/ `BoxShadow(#F6D046, blur 8.4)`
- Header search: `#F0F1F0` rounded-24 field, placeholder `Search "cousins", "Delhi", "1990s"`
- Time bar: 378.5px line #999999 stroke 2, dot at 2026 right end, 13px circle #A07A23 ring 0.4 #A07A23

## Risks / notes
- Avatar images referenced (`1.png`, `5.png`, `10.png`, `WOMAN.png`) — not in repo. Use Phosphor user icon fallback. `imageAsset` field reserved on model; drop assets in `app/assets/family/`, register `pubspec.yaml` later.
- 412×917 canvas taller than viewport — `InteractiveViewer` + `SingleChildScrollView` inside if needed for small phones.
- No state mgmt added. Mock list passed down via constructor. Provider/Riverpod swap trivial later.
- Status bar block in Figma spec ignored — real OS status bar via `SafeArea`.

## Build order
1. Models + mock data
2. `DotGridBackground` + `ConnectorLines` painters (visual scaffold first)
3. `FamilyNode` + `AddNode` widgets
4. `FamilyTreeHeader`
5. Assemble `FamilyTreeScreen` Stack
6. `TimeTravelBar` + FAB
7. Wire `main.dart` nav index 2
8. `FamilyMemberDetailScreen` stub + tap wiring

## Acceptance
- Tree icon in bottom nav opens screen
- All 9 nodes render at exact Figma coords
- Connector brackets + hearts visible
- Pan/zoom works
- Tap real node → detail; tap `+` / FAB → snackbar
- Time bar dot draggable, shows year
