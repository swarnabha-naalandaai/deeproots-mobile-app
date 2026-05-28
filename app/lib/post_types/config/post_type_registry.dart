import 'post_type_config.dart';
import 'story_config.dart';

class PostTypeRegistry {
  PostTypeRegistry._();

  static final Map<String, PostTypeConfig> _byDisplayName = {
    storyConfig.displayName: storyConfig,
  };

  static PostTypeConfig? findByDisplayName(String displayName) =>
      _byDisplayName[displayName];

  static List<PostTypeConfig> all() => _byDisplayName.values.toList();
}
