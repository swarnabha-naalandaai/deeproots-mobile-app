import 'field_config.dart';
import 'post_type_config.dart';

const PostTypeConfig photoAlbumConfig = PostTypeConfig(
  typeKey: 'photo_album',
  displayName: 'Photo Album',
  headerTitle: 'New Photo Album',
  submittedMessage: 'Photo album posted',
  fields: [
    TextFieldConfig(
      key: 'title',
      label: 'Album title*',
      hint: 'What is it called?',
      optional: false,
    ),
    TextAreaConfig(
      key: 'description',
      label: 'Description*',
      hint: 'Describe what these photos are about',
      optional: false,
      height: 143,
    ),
    PhotoUploadConfig(
      key: 'photos',
      label: 'Photos (optional)',
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
