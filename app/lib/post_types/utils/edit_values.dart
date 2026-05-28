import '../../models/feed_post.dart';
import '../models/recorded_voice_note.dart';

Map<String, dynamic> editValuesFor(FeedPost post) {
  switch (post) {
    case RecipePost p:
      return {
        'title': p.title,
        'photos': <String>[p.coverUrl],
        'tags': List<String>.from(p.tags),
      };
    case StoryPost p:
      return {
        'title': p.title,
        'story': p.transcription,
        'photos': <String>[p.coverUrl],
        'tags': List<String>.from(p.tags),
        'recording': <RecordedVoiceNote>[
          RecordedVoiceNote(
            path: p.audioUrl,
            duration: p.duration,
            createdAt: DateTime.now(),
            transcript: p.transcription,
          ),
        ],
      };
    case DocumentPost p:
      return {
        'title': p.title,
        'description': p.description,
        'tags': List<String>.from(p.tags),
      };
    case TraditionPost p:
      return {
        'name': p.title,
        'frequency': p.frequencyLabel,
        'description': p.description,
        'photos': List<String>.from(p.images),
        'tags': List<String>.from(p.tags),
      };
    case PhotoAlbumPost p:
      return {
        'title': p.title,
        'description': p.description,
        'photos': List<String>.from(p.images),
        'tags': List<String>.from(p.tags),
      };
    case LifeUpdatePost p:
      return {
        'update': p.body,
        'tags': List<String>.from(p.tags),
        if (p.audioUrl != null)
          'recording': <RecordedVoiceNote>[
            RecordedVoiceNote(
              path: p.audioUrl!,
              duration: p.audioDuration ?? Duration.zero,
              createdAt: DateTime.now(),
              transcript: p.transcription,
            ),
          ],
      };
  }
}

String editHeaderFor(FeedPost post) {
  switch (post.type) {
    case PostType.recipe:
      return 'Edit Recipe';
    case PostType.story:
      return 'Edit Story';
    case PostType.document:
      return 'Edit Document';
    case PostType.tradition:
      return 'Edit Tradition';
    case PostType.photoAlbum:
      return 'Edit Photo Album';
    case PostType.lifeUpdate:
      return 'Edit Life Update';
  }
}

String registryDisplayNameFor(PostType type) {
  switch (type) {
    case PostType.recipe:
      return 'Recipe';
    case PostType.story:
      return 'Story';
    case PostType.document:
      return 'Documents';
    case PostType.tradition:
      return 'Tradition';
    case PostType.photoAlbum:
      return 'Photo Album';
    case PostType.lifeUpdate:
      return 'Life Update';
  }
}
