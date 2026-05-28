import 'field_config.dart';
import 'post_type_config.dart';

const PostTypeConfig lifeUpdateConfig = PostTypeConfig(
  typeKey: 'life_update',
  displayName: 'Life Update',
  headerTitle: 'New Life Update',
  submittedMessage: 'Life update posted',
  fields: [
    VoiceNotesConfig(
      key: 'recording',
      recordTitle: 'Recording an update...',
      addLabel: 'Record update',
      highlighted: true,
      subtitle: 'We will transcribe it for you',
    ),
    TextAreaConfig(
      key: 'update',
      label: 'What’s new?*',
      hint: 'Describe the update',
      optional: false,
      height: 140,
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
