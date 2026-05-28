import 'package:flutter/material.dart';
import 'field_config.dart';

typedef PostSubmitHandler = void Function(
  BuildContext context,
  Map<String, dynamic> values,
);

class PostTypeConfig {
  final String typeKey;
  final String displayName;
  final String headerTitle;
  final String postLabel;
  final String submittedMessage;
  final List<FieldConfig> fields;
  final PostSubmitHandler? onSubmit;

  const PostTypeConfig({
    required this.typeKey,
    required this.displayName,
    required this.headerTitle,
    this.postLabel = 'Post',
    required this.submittedMessage,
    required this.fields,
    this.onSubmit,
  });
}
