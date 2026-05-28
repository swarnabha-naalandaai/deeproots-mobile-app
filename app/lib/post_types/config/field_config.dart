import '../models/recorded_voice_note.dart';

sealed class FieldConfig {
  final String key;
  final String? label;
  final bool optional;

  const FieldConfig({
    required this.key,
    this.label,
    this.optional = true,
  });

  Object? defaultValue();

  bool hasValue(Object? value);
}

class TextFieldConfig extends FieldConfig {
  final String hint;
  final String? initialValue;

  const TextFieldConfig({
    required super.key,
    super.label,
    super.optional,
    this.hint = '',
    this.initialValue,
  });

  @override
  Object? defaultValue() => initialValue ?? '';

  @override
  bool hasValue(Object? value) => value is String && value.trim().isNotEmpty;
}

class TextAreaConfig extends FieldConfig {
  final String hint;
  final double height;
  final String? initialValue;

  const TextAreaConfig({
    required super.key,
    super.label,
    super.optional,
    this.hint = '',
    this.height = 160,
    this.initialValue,
  });

  @override
  Object? defaultValue() => initialValue ?? '';

  @override
  bool hasValue(Object? value) => value is String && value.trim().isNotEmpty;
}

class PhotoUploadConfig extends FieldConfig {
  final String emptyTitle;
  final String emptySubtitle;

  const PhotoUploadConfig({
    required super.key,
    super.label,
    super.optional,
    this.emptyTitle = 'Drag & drop a photo here',
    this.emptySubtitle = 'or click to choose',
  });

  @override
  Object? defaultValue() => const <String>[];

  @override
  bool hasValue(Object? value) => value is List && value.isNotEmpty;
}

class VoiceTranscriptionConfig extends FieldConfig {
  final String recordTitle;
  final String recordLabel;
  final String helperText;
  final bool transcribe;

  const VoiceTranscriptionConfig({
    required super.key,
    super.label,
    super.optional,
    required this.recordTitle,
    this.recordLabel = 'Record',
    this.helperText = 'We will transcribe it for you',
    this.transcribe = true,
  });

  @override
  Object? defaultValue() => null;

  @override
  bool hasValue(Object? value) => value is RecordedVoiceNote;
}

class VoiceNotesConfig extends FieldConfig {
  final String recordTitle;
  final String addLabel;

  const VoiceNotesConfig({
    required super.key,
    super.label,
    super.optional,
    this.recordTitle = 'Recording voice note...',
    this.addLabel = 'Add voice note',
  });

  @override
  Object? defaultValue() => const <RecordedVoiceNote>[];

  @override
  bool hasValue(Object? value) =>
      value is List<RecordedVoiceNote> && value.isNotEmpty;
}

class TagsConfig extends FieldConfig {
  final String hint;

  const TagsConfig({
    required super.key,
    super.label,
    super.optional,
    this.hint = 'Add a tag and press Enter',
  });

  @override
  Object? defaultValue() => const <String>[];

  @override
  bool hasValue(Object? value) => value is List && value.isNotEmpty;
}

class FamilyConfig extends FieldConfig {
  final String emptyLabel;

  const FamilyConfig({
    required super.key,
    super.label,
    super.optional,
    this.emptyLabel = '+ Tag family',
  });

  @override
  Object? defaultValue() => const <String>[];

  @override
  bool hasValue(Object? value) => value is List && value.isNotEmpty;
}
