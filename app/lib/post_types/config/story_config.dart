import 'field_config.dart';
import 'post_type_config.dart';

const PostTypeConfig storyConfig = PostTypeConfig(
  typeKey: 'story',
  displayName: 'Story',
  headerTitle: 'New Story',
  submittedMessage: 'Story posted',
  fields: [
    VoiceTranscriptionConfig(
      key: 'transcription',
      recordTitle: 'Recording a memory of Prerna...',
      recordLabel: 'Record story',
      helperText: 'We will transcribe it for you',
      transcribe: true,
    ),
    TextFieldConfig(
      key: 'title',
      label: 'Title*',
      hint: 'Give it a name',
      optional: false,
    ),
    TextAreaConfig(
      key: 'story',
      label: 'Story*',
      hint: 'Tell it like you’d tell it at the table',
      optional: false,
      height: 160,
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
      label: 'Tags (optional)',
      hint: 'Add a tag and press Enter',
    ),
    FamilyConfig(
      key: 'family',
      label: 'Tag family members (optional)',
    ),
  ],
);
