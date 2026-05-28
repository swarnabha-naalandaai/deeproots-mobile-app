import 'document_config.dart';
import 'life_update_config.dart';
import 'photo_album_config.dart';
import 'post_type_config.dart';
import 'recipe_config.dart';
import 'story_config.dart';
import 'tradition_config.dart';

class PostTypeRegistry {
  PostTypeRegistry._();

  static final Map<String, PostTypeConfig> _byDisplayName = {
    storyConfig.displayName: storyConfig,
    recipeConfig.displayName: recipeConfig,
    traditionConfig.displayName: traditionConfig,
    photoAlbumConfig.displayName: photoAlbumConfig,
    documentConfig.displayName: documentConfig,
    lifeUpdateConfig.displayName: lifeUpdateConfig,
  };

  static PostTypeConfig? findByDisplayName(String displayName) =>
      _byDisplayName[displayName];

  static List<PostTypeConfig> all() => _byDisplayName.values.toList();
}
