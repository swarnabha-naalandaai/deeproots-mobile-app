# CLAUDE.md — DeepRoots Mobile App

**READ FIRST before adding any new post type, form field, or create-post screen.**
This app uses a **config-driven post creation system**. Do NOT build new screens, controllers, or duplicate widgets — extend the existing system.

---

## Golden Rules

1. **Never** create a new `New<X>Screen` (e.g. `NewTraditionScreen`). Use `CreatePostScreen` driven by a `PostTypeConfig`.
2. **Never** duplicate field UI (text inputs, photo upload, voice recorder, tags, family chips). Reuse the field widgets in `lib/post_types/widgets/fields/`.
3. **Never** hardcode a post type string outside `PostTypeRegistry`. Routing lookups go through `PostTypeRegistry.findByDisplayName(title)`.
4. **Never** redefine form colors, field shell, label, or pill button. Use `lib/widgets/form/` primitives.
5. **Never** add state management libs (Provider/Riverpod/Bloc). App uses pure `setState`. Match it.

---

## Architecture Map

```
lib/
├── post_types/
│   ├── models/
│   │   └── recorded_voice_note.dart        # shared voice capture model
│   ├── config/
│   │   ├── field_config.dart               # sealed FieldConfig + 7 variants
│   │   ├── post_type_config.dart           # PostTypeConfig contract
│   │   ├── post_type_registry.dart         # display-name → config lookup
│   │   └── <type>_config.dart              # one file per post type
│   ├── widgets/
│   │   ├── form_renderer.dart              # sealed switch → field widget
│   │   └── fields/
│   │       ├── text_field_widget.dart
│   │       ├── text_area_widget.dart
│   │       ├── photo_upload_widget.dart
│   │       ├── voice_transcription_widget.dart
│   │       ├── voice_notes_widget.dart
│   │       ├── tags_widget.dart
│   │       └── family_widget.dart
│   └── screens/
│       └── create_post_screen.dart         # generic; renders any config
└── widgets/form/
    ├── form_tokens.dart                    # colors + relative-time helper
    ├── field_shell.dart                    # rounded grey container
    ├── field_label.dart                    # standard label text
    └── pill_button.dart                    # icon + label rounded button
```

---

## Existing Field Types (sealed `FieldConfig`)

Use one of these. **Do not invent new field types unless the new variant is genuinely missing.**

| Variant | Value type | Use for |
|---|---|---|
| `TextFieldConfig` | `String` | Single-line input (title, name, frequency) |
| `TextAreaConfig` | `String` | Multiline description |
| `PhotoUploadConfig` | `List<String>` (paths) | Multi-photo upload, 3-col grid |
| `VoiceTranscriptionConfig` | `RecordedVoiceNote?` | Top-of-form record block w/ transcript |
| `VoiceNotesConfig` | `List<RecordedVoiceNote>` | Multiple inline voice notes |
| `TagsConfig` | `List<String>` | Maroon-pill tag input |
| `FamilyConfig` | `List<String>` | Beige family-tag chips |

Each `FieldConfig` defines `defaultValue()` + `hasValue(value)`. `hasValue` drives the "Post" button enable state.

### Adding a new field type (rare)

1. Add new variant to `lib/post_types/config/field_config.dart`.
2. Build widget under `lib/post_types/widgets/fields/`.
3. Add `case` to switch in `form_renderer.dart` (sealed → exhaustive, compiler enforces).

---

## Adding a New Post Type — REQUIRED FLOW

**Do NOT create a new screen file.** Only:

### Step 1 — Write the config

`lib/post_types/config/<type>_config.dart`:

```dart
import 'field_config.dart';
import 'post_type_config.dart';

const PostTypeConfig traditionConfig = PostTypeConfig(
  typeKey: 'tradition',
  displayName: 'Tradition',          // MUST match AddPostSheet button title
  headerTitle: 'New Tradition',
  submittedMessage: 'Tradition posted',
  fields: [
    TextFieldConfig(key: 'title', label: 'Title*', hint: 'Name this tradition', optional: false),
    TextFieldConfig(key: 'frequency', label: 'How often?', hint: 'Annual, Monthly...'),
    TextAreaConfig(key: 'description', label: 'Description*', hint: 'How do you celebrate?', optional: false),
    PhotoUploadConfig(key: 'photos', label: 'Photos (optional)'),
    TagsConfig(key: 'tags', label: 'Tags (optional)'),
    FamilyConfig(key: 'family', label: 'Tag family members (optional)'),
  ],
);
```

### Step 2 — Register

Edit `lib/post_types/config/post_type_registry.dart` — add to `_byDisplayName` map:

```dart
import 'tradition_config.dart';
...
static final Map<String, PostTypeConfig> _byDisplayName = {
  storyConfig.displayName: storyConfig,
  traditionConfig.displayName: traditionConfig,
};
```

### Step 3 — Verify AddPostSheet title matches

`lib/widgets/add_post_sheet.dart` — `displayName` in the config must match the `_PostOption.title` string exactly. AddPostSheet button → `onSelect(title)` → `PostTypeRegistry.findByDisplayName(title)`.

**That's it.** `CreatePostScreen` renders automatically. No new screen, no new routing.

---

## Routing Contract

Two screens trigger create-post flow:
- `lib/screens/feed_screen.dart` — `_onPostTypeSelected`
- `lib/screens/chat_screen.dart` — `AddPostSheet onSelect`

Both look up `PostTypeRegistry.findByDisplayName(title)`. **If you add a third entry point, use the same pattern — never branch on `title == 'Story'` etc.**

---

## State Management

- `CreatePostScreen` owns `Map<String, dynamic>` keyed by `FieldConfig.key`.
- Each field widget is given `(config, value, onChanged)`. Field widgets own internal controllers (TextEditingController, FocusNode) and dispose them.
- Post button enables when **any** field passes `hasValue` (matches original Story behavior). Change in `_hasContent` getter if needed per type.

---

## Submission

`PostTypeConfig.onSubmit` is optional. Default behavior: show snackbar, pop screen. When wiring real backend:

```dart
const myConfig = PostTypeConfig(
  ...
  onSubmit: _submitMyType,
);

void _submitMyType(BuildContext context, Map<String, dynamic> values) {
  // values keyed by FieldConfig.key
  // call backend, etc.
}
```

`values` is unmodifiable map of `key → value` for every field.

---

## Shared Voice Recording

`RecordingSheet` (`lib/widgets/recording_sheet.dart`) is generic. Two field types use it:
- `VoiceTranscriptionConfig` — single recording, optional STT transcript
- `VoiceNotesConfig` — list of recordings

Returns `RecordedVoiceNote` (`lib/post_types/models/recorded_voice_note.dart`). **Do not create a parallel voice model.**

`VoicePreviewBar` (in-form playback) and `WaveformPlayer` (feed-card playback) are also generic and reusable.

---

## Feed Card Pattern (read-side, separate from create flow)

Feed cards in `lib/widgets/cards/` already share `CardHeader` + `CardFooter`. When adding a card for a new post type:
- Add `PostType` enum value in `lib/models/feed_post.dart`
- Add `FeedPost` subclass with type-specific fields
- Create `<type>_card.dart` using `CardHeader` + body + `CardFooter`
- Wire in `lib/widgets/feed_card.dart` switch

Duplication to watch: `RecipeCard._MetaRow` and `PhotoAlbumCard._MetaRow` are identical — extract before adding a third.

---

## Anti-Patterns — Do NOT do these

| Don't | Do instead |
|---|---|
| Create `NewTraditionScreen` | Add `traditionConfig` + register |
| Copy/paste form field UI | Use existing `FieldConfig` variant |
| Hardcode `if (title == '<Type>')` | `PostTypeRegistry.findByDisplayName` |
| New `_VoiceNote` private class | `RecordedVoiceNote` shared model |
| Custom color hex literals in forms | `FormTokens.*` |
| New `_fieldShell` / `_label` / `_pillButton` helpers | `FieldShell`, `FieldLabel`, `PillButton` |
| Add Provider/Riverpod/Bloc | Stay on `setState` |
| Add a field type for one-off use | Compose from existing variants first |

---

## Checklist Before Submitting Any Change Adding/Modifying a Post Type

- [ ] No new file under `lib/screens/` for the post type
- [ ] Config file under `lib/post_types/config/`
- [ ] Registered in `PostTypeRegistry`
- [ ] `displayName` matches `AddPostSheet` option title exactly
- [ ] No duplicate field widget created
- [ ] No new form color/spacing constant outside `FormTokens`
- [ ] `flutter analyze` clean
