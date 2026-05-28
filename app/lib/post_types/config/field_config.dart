import 'package:flutter/widgets.dart';
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

enum UploadSource { images, files }

class PhotoUploadConfig extends FieldConfig {
  final String emptyTitle;
  final String emptySubtitle;
  final IconData? emptyIcon;
  final UploadSource source;

  const PhotoUploadConfig({
    required super.key,
    super.label,
    super.optional,
    this.emptyTitle = 'Drag & drop a photo here',
    this.emptySubtitle = 'or click to choose',
    this.emptyIcon,
    this.source = UploadSource.images,
  });

  @override
  Object? defaultValue() => const <String>[];

  @override
  bool hasValue(Object? value) => value is List && value.isNotEmpty;
}

class VoiceNotesConfig extends FieldConfig {
  final String recordTitle;
  final String addLabel;
  final bool highlighted;
  final String? subtitle;

  const VoiceNotesConfig({
    required super.key,
    super.label,
    super.optional,
    this.recordTitle = 'Recording voice note...',
    this.addLabel = 'Add voice note',
    this.highlighted = false,
    this.subtitle,
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
