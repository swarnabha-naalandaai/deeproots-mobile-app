import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import 'cards/document_card.dart';
import 'cards/life_update_card.dart';
import 'cards/photo_album_card.dart';
import 'cards/recipe_card.dart';
import 'cards/story_card.dart';
import 'cards/tradition_card.dart';

class FeedCard extends StatelessWidget {
  final FeedPost post;
  const FeedCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return switch (post) {
      final RecipePost p => RecipeCard(post: p),
      final StoryPost p => StoryCard(post: p),
      final DocumentPost p => DocumentCard(post: p),
      final TraditionPost p => TraditionCard(post: p),
      final PhotoAlbumPost p => PhotoAlbumCard(post: p),
      final LifeUpdatePost p => LifeUpdateCard(post: p),
    };
  }
}
