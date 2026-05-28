import 'field_config.dart';
import 'post_type_config.dart';

const PostTypeConfig traditionConfig = PostTypeConfig(
  typeKey: 'tradition',
  displayName: 'Tradition',
  headerTitle: 'New Tradition',
  submittedMessage: 'Tradition posted',
  fields: [
    VoiceNotesConfig(
      key: 'recording',
      recordTitle: 'Recording a tradition...',
      addLabel: 'Record story',
      highlighted: true,
      subtitle: 'We will transcribe it for you',
    ),
    TextFieldConfig(
      key: 'name',
      label: 'Name*',
      hint: 'What is it called?',
      optional: false,
    ),
    TextFieldConfig(
      key: 'frequency',
      label: 'When does it happen?*',
      hint: 'e.g., every year on Diwali',
      optional: false,
    ),
    TextAreaConfig(
      key: 'description',
      label: 'Describe the tradition*',
      hint: 'Tell it like you’d tell it at the table',
      optional: false,
      height: 172,
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
