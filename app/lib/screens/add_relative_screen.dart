import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/family_member.dart';
import '../theme/app_colors.dart';
import '../widgets/form/form_tokens.dart';

class AddRelativeScreen extends StatefulWidget {
  final Relation relation;
  final String? subjectName;
  final String pronounPossessive;

  const AddRelativeScreen({
    super.key,
    required this.relation,
    this.subjectName,
    this.pronounPossessive = 'her',
  });

  @override
  State<AddRelativeScreen> createState() => _AddRelativeScreenState();
}

class _AddRelativeScreenState extends State<AddRelativeScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  DateTime? _birthDate;
  String _countryCode = '+91';
  String _countryFlag = '🇮🇳';
  int _genderIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.relation == Relation.spouse && widget.pronounPossessive == 'her') {
      _genderIndex = 1; // Default to Husband when adding spouse to a woman (pronounPossessive is 'her')
    } else if (widget.relation == Relation.father || widget.relation == Relation.grandfather) {
      _genderIndex = 1; // Default to Father/Grandfather bifurcation when adding father/grandfather
    } else {
      _genderIndex = 0; // Default to Mother/Wife/etc. (optA)
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.relation) {
      case Relation.child:
        return 'Add a child';
      case Relation.sibling:
        return 'Add a sibling';
      case Relation.spouse:
        return 'Add a partner';
      case Relation.father:
      case Relation.mother:
        return 'Add a parent';
      case Relation.grandfather:
      case Relation.grandmother:
        return 'Add a grandparent';
      default:
        return 'Add family member';
    }
  }

  ({String prompt, String optA, String optB}) get _genderChoices {
    final p = widget.pronounPossessive;
    switch (widget.relation) {
      case Relation.child:
        return (prompt: 'Is this $p daughter or son?', optA: 'Daughter', optB: 'Son');
      case Relation.sibling:
        return (prompt: 'Is this $p sister or brother?', optA: 'Sister', optB: 'Brother');
      case Relation.spouse:
        return (prompt: 'Is this $p wife or husband?', optA: 'Wife', optB: 'Husband');
      case Relation.father:
      case Relation.mother:
      case Relation.grandfather:
      case Relation.grandmother:
        return (prompt: 'Is this $p mother or father?', optA: 'Mother', optB: 'Father');
      default:
        return (prompt: 'Female or male?', optA: 'Female', optB: 'Male');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 10, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickCountry() async {
    final choice = await showModalBottomSheet<({String code, String flag})>(
      context: context,
      builder: (ctx) {
        const options = <({String code, String flag, String name})>[
          (code: '+91', flag: '🇮🇳', name: 'India'),
          (code: '+1', flag: '🇺🇸', name: 'United States'),
          (code: '+44', flag: '🇬🇧', name: 'United Kingdom'),
          (code: '+61', flag: '🇦🇺', name: 'Australia'),
          (code: '+971', flag: '🇦🇪', name: 'UAE'),
          (code: '+65', flag: '🇸🇬', name: 'Singapore'),
        ];
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final o in options)
                ListTile(
                  leading: Text(o.flag, style: const TextStyle(fontSize: 22)),
                  title: Text('${o.name} (${o.code})'),
                  onTap: () => Navigator.of(ctx).pop((code: o.code, flag: o.flag)),
                ),
            ],
          ),
        );
      },
    );
    if (choice != null) {
      setState(() {
        _countryCode = choice.code;
        _countryFlag = choice.flag;
      });
    }
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  void _save() {
    Navigator.of(context).pop({
      'name': _nameCtrl.text.trim(),
      'birthDate': _birthDate,
      'gender': _genderIndex == 0 ? _genderChoices.optA : _genderChoices.optB,
      'phone': _phoneCtrl.text.trim(),
      'countryCode': _countryCode,
      'email': _emailCtrl.text.trim(),
      'relation': widget.relation,
    });
  }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final choices = _genderChoices;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleBlock(),
                    const SizedBox(height: 20),
                    _sectionLabel(choices.prompt),
                    const SizedBox(height: 12),
                    _genderToggle(choices.optA, choices.optB),
                    const SizedBox(height: 20),
                    Center(child: _avatar()),
                    const SizedBox(height: 20),
                    _sectionLabel('Name', bold: true),
                    const SizedBox(height: 8),
                    _textField(_nameCtrl, hint: 'Their name', onChanged: (_) => setState(() {})),
                    const SizedBox(height: 16),
                    _sectionLabel('Birth Date', bold: true),
                    const SizedBox(height: 8),
                    _dateField(),
                    const SizedBox(height: 12),
                    Text(
                      '*This helps us send them aan invite directly',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Contact number', bold: true),
                    const SizedBox(height: 8),
                    _contactRow(),
                    const SizedBox(height: 16),
                    _sectionLabel('Email ID', bold: true),
                    const SizedBox(height: 8),
                    _textField(
                      _emailCtrl,
                      hint: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _saveButton(),
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

  Widget _header() {
    return SizedBox(
      height: 47,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: Icon(
                PhosphorIcons.caretLeft(),
                size: 24,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: Icon(
                PhosphorIcons.shareNetwork(),
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleBlock() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          if (widget.subjectName != null) ...[
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
                children: [
                  const TextSpan(text: 'for '),
                  TextSpan(
                    text: widget.subjectName!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(height: 0.6, color: FormTokens.fieldBorder),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {bool bold = false}) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
    );
  }

  Widget _genderToggle(String optA, String optB) {
    return Row(
      children: [
        Expanded(child: _genderPill(optA, 0)),
        const SizedBox(width: 12),
        Expanded(child: _genderPill(optB, 1)),
      ],
    );
  }

  Widget _genderPill(String label, int index) {
    final selected = _genderIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _genderIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF191919) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF191919) : FormTokens.fieldBorder,
            width: selected ? 1 : 0.6,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE7E2D6),
            ),
            alignment: Alignment.center,
            child: Icon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
              size: 56,
              color: const Color(0xFFB9B0A0),
            ),
          ),
          Positioned(
            right: -2,
            bottom: 2,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Icon(
                  PhosphorIcons.camera(PhosphorIconsStyle.fill),
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      isDense: true,
      border: InputBorder.none,
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(
        fontSize: 14,
        color: FormTokens.hint,
      ),
    );
  }

  Widget _shell({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: FormTokens.fieldBorder, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _textField(
    TextEditingController c, {
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChanged,
  }) {
    return _shell(
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        onChanged: onChanged,
        style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
        decoration: _inputDeco(hint),
      ),
    );
  }

  Widget _dateField() {
    final txt = _birthDate == null ? 'DD/MM/YYYY' : _formatDate(_birthDate!);
    return GestureDetector(
      onTap: _pickDate,
      behavior: HitTestBehavior.opaque,
      child: _shell(
        child: Row(
          children: [
            Expanded(
              child: Text(
                txt,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: _birthDate == null ? FormTokens.hint : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              PhosphorIcons.calendarBlank(),
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickCountry,
          behavior: HitTestBehavior.opaque,
          child: _shell(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_countryFlag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  _countryCode,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  PhosphorIcons.caretDown(),
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _textField(
            _phoneCtrl,
            hint: '95048 92840',
            keyboardType: TextInputType.phone,
            formatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    final enabled = _canSave;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: enabled ? _save : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Save',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
