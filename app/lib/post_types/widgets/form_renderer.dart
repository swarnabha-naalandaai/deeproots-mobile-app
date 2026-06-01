import 'package:flutter/material.dart';
import '../config/field_config.dart';
import '../models/recorded_voice_note.dart';
import 'fields/family_widget.dart';
import 'fields/list_items_widget.dart';
import 'fields/photo_upload_widget.dart';
import 'fields/recipe_record_widget.dart';
import 'fields/tags_widget.dart';
import 'fields/text_area_widget.dart';
import 'fields/text_field_widget.dart';
import 'fields/voice_notes_widget.dart';

class FormRenderer extends StatelessWidget {
  final List<FieldConfig> fields;
  final Map<String, dynamic> values;
  final void Function(String key, Object? value) onChanged;
  final void Function(Map<String, dynamic> fields)? onBulkChanged;
  final double gap;

  const FormRenderer({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
    this.onBulkChanged,
    this.gap = 28,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < fields.length; i++) {
      if (i > 0) children.add(SizedBox(height: gap));
      children.add(_buildField(fields[i]));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildField(FieldConfig field) {
    final value = values[field.key];
    switch (field) {
      case TextFieldConfig():
        return TextFieldWidget(
          key: ValueKey(field.key),
          config: field,
          value: (value as String?) ?? '',
          onChanged: (v) => onChanged(field.key, v),
        );
      case TextAreaConfig():
        return TextAreaWidget(
          key: ValueKey(field.key),
          config: field,
          value: (value as String?) ?? '',
          onChanged: (v) => onChanged(field.key, v),
        );
      case PhotoUploadConfig():
        return PhotoUploadWidget(
          key: ValueKey(field.key),
          config: field,
          value: (value as List?)?.cast<String>() ?? const [],
          onChanged: (v) => onChanged(field.key, v),
        );
      case VoiceNotesConfig():
        return VoiceNotesWidget(
          key: ValueKey(field.key),
          config: field,
          value: (value as List?)?.cast<RecordedVoiceNote>() ?? const [],
          onChanged: (v) => onChanged(field.key, v),
        );
      case TagsConfig():
        return TagsWidget(
          key: ValueKey(field.key),
          config: field,
          value: (value as List?)?.cast<String>() ?? const [],
          onChanged: (v) => onChanged(field.key, v),
        );
      case FamilyConfig():
        return FamilyWidget(
          key: ValueKey(field.key),
          config: field,
          value: (value as List?)?.cast<String>() ?? const [],
          onChanged: (v) => onChanged(field.key, v),
        );
      case ListItemsConfig():
        return ListItemsWidget(
          key: ValueKey(field.key),
          config: field,
          value: (value as List?)?.cast<String>() ?? const [],
          onChanged: (v) => onChanged(field.key, v),
        );
      case RecipeRecordConfig():
        return RecipeRecordWidget(
          key: ValueKey(field.key),
          config: field,
          value: value as RecipeRecordResult?,
          onChanged: (v) => onChanged(field.key, v),
          onBulkChanged: onBulkChanged,
        );
    }
  }
}
