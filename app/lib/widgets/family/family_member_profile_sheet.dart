import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/family_member.dart';
import '../../models/family_tree_mock.dart';
import '../../screens/add_relative_screen.dart';
import '../recording_sheet.dart';
import '../voice_preview_bar.dart';

enum _MemoryKind { audio, text }

class _Memory {
  final _MemoryKind kind;
  final String title;
  final String body;
  final String recordedBy;
  final String ago;
  final String? audioPath;
  final Duration duration;
  const _Memory({
    required this.kind,
    required this.title,
    required this.body,
    required this.recordedBy,
    required this.ago,
    this.audioPath,
    this.duration = Duration.zero,
  });
}

const List<_Memory> _seedMemoriesPrerna = [
  _Memory(
    kind: _MemoryKind.audio,
    title: 'The summer we spent in Lucknow',
    body:
        'I remember the summer of 1998. We had gone to Lucknow for two months. The whole family.\n\nThe house had this huge mango tree in the backyard, and every afternoon after lunch, we would all gather under it. Dadi would tell us stories about her childhood, about Partition, about how she came to Lucknow as a young bride.\n\nI was maybe eight years old. I didn’t understand most of what she said. But I remember her voice. I remember sitting there, eating mangoes, listening.',
    recordedBy: 'Arundhuti',
    ago: '7m ago',
    duration: Duration(minutes: 4),
  ),
  _Memory(
    kind: _MemoryKind.text,
    title: 'About Dadi’s hands in the kitchen',
    body:
        'Dadi’s hands always smelled of haldi and ghee. She would wake up before everyone, before the sun, and start kneading dough by the window. I would creep in and sit on the counter and watch her, the way the light caught the flour on her wrists.',
    recordedBy: 'Aparna',
    ago: '12d ago',
  ),
];

void showFamilyMemberProfileSheet(BuildContext context, FamilyMember member) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x26000000), // rgba(0,0,0,0.15)
    builder: (_) => FamilyMemberProfileSheet(member: member),
  );
}

class FamilyMemberProfileSheet extends StatelessWidget {
  final FamilyMember member;

  const FamilyMemberProfileSheet({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.64,
      minChildSize: 0.4,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(10),
          child: _ProfileContent(
            member: member,
            scrollController: scrollController,
          ),
        );
      },
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final FamilyMember member;
  final ScrollController scrollController;

  const _ProfileContent({required this.member, required this.scrollController});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  int _tabIndex = 0;
  late List<_Memory> _memories;

  @override
  void initState() {
    super.initState();
    _memories = widget.member.id == 'prerna'
        ? List.of(_seedMemoriesPrerna)
        : <_Memory>[];
  }

  Future<void> _recordMemory() async {
    final result = await RecordingSheet.show(
      context,
      title: 'Record a memory of ${_firstName(widget.member.name)}',
      transcribe: true,
    );
    if (result == null || !mounted) return;
    final transcript = result.transcript ?? '';
    final title = _titleFromTranscript(transcript);
    final body = transcript.isEmpty ? '(audio memory)' : transcript;
    setState(() {
      _memories.insert(
        0,
        _Memory(
          kind: _MemoryKind.audio,
          title: title,
          body: body,
          recordedBy: 'You',
          ago: 'just now',
          audioPath: result.path,
          duration: result.duration,
        ),
      );
    });
  }

  Future<void> _writeMemory() async {
    final controller = TextEditingController();
    final body = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Write a memory of ${_firstName(widget.member.name)}',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E3E3E),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'A small story, note about them worth remembering.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(ctx).pop(controller.text.trim()),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (body == null || body.isEmpty || !mounted) return;
    setState(() {
      _memories.insert(
        0,
        _Memory(
          kind: _MemoryKind.text,
          title: _titleFromTranscript(body),
          body: body,
          recordedBy: 'You',
          ago: 'just now',
        ),
      );
    });
  }

  String _titleFromTranscript(String s) {
    if (s.isEmpty) return 'New memory';
    final words = s.split(RegExp(r'\s+')).take(6).join(' ');
    return words.length > 60 ? '${words.substring(0, 60)}…' : words;
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverToBoxAdapter(child: _handle()),
        SliverToBoxAdapter(child: _shareRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _identityRow(m),
              const SizedBox(height: 12),
              _tabs(),
              const SizedBox(height: 24),
              if (_tabIndex == 1) ..._familyTab(context, m) else ..._storyTab(),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFFD3D2CE),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _shareRow() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 37,
        height: 37,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F4EE),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          PhosphorIcons.shareNetwork(),
          size: 16,
          color: const Color(0xFF5F5F5F),
        ),
      ),
    );
  }

  Widget _identityRow(FamilyMember m) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatarWithBadge(m),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.name,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 24 / 20,
                  color: Color(0xFF1D1E09),
                ),
              ),
              Text(
                m.roleLabel,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 24 / 13,
                  color: Color(0xFF5F5F5F),
                ),
              ),
            ],
          ),
        ),
        Icon(
          PhosphorIcons.pencilSimple(),
          size: 24,
          color: const Color(0xFF5F5F5F),
        ),
      ],
    );
  }

  Widget _avatarWithBadge(FamilyMember m) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE5D7CA),
              image: m.imageAsset != null
                  ? DecorationImage(image: AssetImage(m.imageAsset!), fit: BoxFit.cover)
                  : (m.imageUrl != null
                      ? DecorationImage(image: NetworkImage(m.imageUrl!), fit: BoxFit.cover)
                      : null),
            ),
            child: (m.imageAsset == null && m.imageUrl == null)
                ? Icon(
                    PhosphorIcons.user(PhosphorIconsStyle.fill),
                    size: 32,
                    color: const Color(0xFF88623E),
                  )
                : null,
          ),
          if (m.deceased)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x33C1A373),
                ),
              ),
            ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F4EE),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.camera_alt,
                  size: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          if (m.deceased)
            Positioned(
              left: 24,
              top: -16,
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
        ],
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: [
        Expanded(child: _tab('Story', 0)),
        Expanded(child: _tab('Family', 1)),
      ],
    );
  }

  Widget _tab(String label, int idx) {
    final active = _tabIndex == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _tabIndex = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xFF1D1E09) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: Color(0xFF3E3E3E),
          ),
        ),
      ),
    );
  }

  List<Widget> _storyTab() {
    return [
      _sectionLabel('Add memories'),
      const SizedBox(height: 12),
      Row(
        children: [
          _addMemoryButton(
            child: const Text(
              'Aa',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1E09),
              ),
            ),
            onTap: _writeMemory,
          ),
          const SizedBox(width: 12),
          _addMemoryButton(
            child: Icon(
              PhosphorIcons.camera(),
              size: 18,
              color: const Color(0xFF1D1E09),
            ),
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _addMemoryButton(
            filled: true,
            child: Icon(
              PhosphorIcons.microphone(PhosphorIconsStyle.fill),
              size: 18,
              color: Colors.white,
            ),
            onTap: _recordMemory,
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Text(
        'A small story, note about them worth remembering.',
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontStyle: FontStyle.italic,
          fontSize: 13,
          height: 18 / 13,
          color: Color(0xFF999999),
        ),
      ),
      if (_memories.isNotEmpty) ...[
        const SizedBox(height: 24),
        _sectionLabel('Memories'),
        const SizedBox(height: 8),
        for (var i = 0; i < _memories.length; i++) ...[
          _MemoryCard(memory: _memories[i]),
          if (i != _memories.length - 1) const SizedBox(height: 12),
        ],
      ],
    ];
  }

  Widget _addMemoryButton({
    required Widget child,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFA07A23) : const Color(0xFFF0F1F0),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  List<Widget> _familyTab(BuildContext context, FamilyMember m) {
    return [
      _sectionLabel('Add family for ${_firstName(m.name)}'),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _addSlot(
              context,
              'Parent',
              'Mother or father',
              Relation.mother,
              m,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _addSlot(
              context,
              'Partner',
              'Wife or husband',
              Relation.spouse,
              m,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _addSlot(
              context,
              'Child',
              'Daughter or son',
              Relation.child,
              m,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _addSlot(
              context,
              'Sibling',
              'Sister or brother',
              Relation.sibling,
              m,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      Center(
        child: GestureDetector(
          onTap: () {},
          child: const Text(
            'Add an existing person',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: Color(0xFF1B72A8),
            ),
          ),
        ),
      ),
      const SizedBox(height: 32),
      _sectionLabel('Spouse'),
      const SizedBox(height: 8),
      _personRow(FamilyTreeMock.anant, '1935-Present'),
      const SizedBox(height: 24),
      _sectionLabel('Children'),
      const SizedBox(height: 8),
      _personRow(FamilyTreeMock.ashish, '1974-Present'),
    ];
  }

  String _firstName(String full) => full.split(' ').first;

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: Color(0xFF3E3E3E),
      ),
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

  void _openAddRelative(
    BuildContext context,
    Relation relation,
    FamilyMember subject,
  ) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddRelativeScreen(
          relation: relation,
          subjectName: _firstName(subject.name),
          pronounPossessive: _possessiveFor(subject),
        ),
      ),
    );
  }

  Widget _addSlot(
    BuildContext context,
    String title,
    String subtitle,
    Relation relation,
    FamilyMember subject,
  ) {
    return GestureDetector(
      onTap: () => _openAddRelative(context, relation, subject),
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              '+',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1,
                color: Color(0xFF5F5F5F),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                    color: Color(0xFF1D1E09),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    height: 18 / 14,
                    color: Color(0xFF5F5F5F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _personRow(FamilyMember m, String years) {
    final initials = _initials(m.name);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 24, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E1CA),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA07A23),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 21 / 16,
                    color: Color(0xFF1D1E09),
                  ),
                ),
                Text(
                  years,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    height: 20 / 12,
                    color: Color(0xFF5F5F5F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _MemoryCard extends StatefulWidget {
  final _Memory memory;
  const _MemoryCard({required this.memory});

  @override
  State<_MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<_MemoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.memory;
    final isAudio = m.kind == _MemoryKind.audio;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F4EE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFA07A23),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isAudio
                  ? Icon(
                      PhosphorIcons.microphone(PhosphorIconsStyle.fill),
                      size: 14,
                      color: Colors.white,
                    )
                  : const Text(
                      'Aa',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 18 / 14,
                      color: Color(0xFF1D1E09),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_expanded && isAudio) ...[
                    VoicePreviewBar(
                      filePath: m.audioPath ?? '',
                      totalHint: m.duration,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    _expanded ? m.body : _snippet(m.body),
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      height: 18 / 13,
                      color: Color(0xFF3E3E3E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Recorded by ${m.recordedBy}, ${m.ago}',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      height: 16 / 12,
                      color: Color(0xFF5F5F5F),
                    ),
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.caretUp(),
                          size: 12,
                          color: const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Show less',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _snippet(String body) {
    final first = body.split('\n').first.trim();
    final quoted = first.length > 110 ? '${first.substring(0, 110)}…' : first;
    return '“$quoted”';
  }
}
