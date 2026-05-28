import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'field_config.dart';
import 'post_type_config.dart';

final PostTypeConfig documentConfig = PostTypeConfig(
  typeKey: 'document',
  displayName: 'Documents',
  headerTitle: 'New Document',
  submittedMessage: 'Document posted',
  fields: [
    TextFieldConfig(
      key: 'title',
      label: 'Title*',
      hint: 'What is it called?',
      optional: false,
    ),
    TextAreaConfig(
      key: 'description',
      label: 'Description*',
      hint: 'What is this document? Add some context',
      optional: false,
      height: 143,
    ),
    PhotoUploadConfig(
      key: 'documents',
      label: 'Upload document(s)*',
      emptyTitle: 'Drag & drop a document here',
      emptySubtitle: 'or click to choose',
      emptyIcon: PhosphorIconsRegular.files,
      source: UploadSource.files,
    ),
    VoiceNotesConfig(
      key: 'voiceNotes',
      label: 'Voice note (optional)',
      recordTitle: 'Recording voice note...',
      addLabel: 'Add voice note',
    ),
    TagsConfig(
      key: 'tags',
      label: 'Tags',
      hint: 'Add a tag and press Enter',
    ),
    FamilyConfig(
      key: 'family',
      label: 'Tag family members (optional)',
    ),
  ],
);
