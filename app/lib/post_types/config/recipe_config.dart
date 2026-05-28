import 'field_config.dart';
import 'post_type_config.dart';

const PostTypeConfig recipeConfig = PostTypeConfig(
  typeKey: 'recipe',
  displayName: 'Recipe',
  headerTitle: 'New Recipe',
  submittedMessage: 'Recipe posted',
  fields: [
    TextFieldConfig(
      key: 'title',
      label: 'Name*',
      hint: 'What is this dish called?',
      optional: false,
    ),
    TextAreaConfig(
      key: 'ingredients',
      label: 'Ingredients*',
      hint: 'One per line',
      optional: false,
      height: 143,
    ),
    TextAreaConfig(
      key: 'steps',
      label: 'Steps*',
      hint: 'How is it made?',
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
