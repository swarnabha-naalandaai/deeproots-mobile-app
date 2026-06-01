import 'field_config.dart';
import 'post_type_config.dart';

const PostTypeConfig recipeConfig = PostTypeConfig(
  typeKey: 'recipe',
  displayName: 'Recipe',
  headerTitle: 'New Recipe',
  submittedMessage: 'Recipe posted',
  fields: [
    RecipeRecordConfig(key: 'recording'),
    TextFieldConfig(
      key: 'title',
      label: 'Title*',
      hint: 'What is it called?',
      optional: false,
    ),
    TextAreaConfig(
      key: 'caption',
      label: 'Caption*',
      hint: 'What is this document? Add some context',
      optional: false,
      height: 140,
    ),
    ListItemsConfig(
      key: 'ingredients',
      label: 'Ingredients*',
      hint: 'Atta — 2 cups, the same one you make roti with',
      addLabel: '+ Add ingredient',
      optional: false,
    ),
    ListItemsConfig(
      key: 'steps',
      label: 'Steps*',
      hint: 'Describe what to do',
      addLabel: '+ Add step',
      optional: false,
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
