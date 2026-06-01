import 'package:flutter/material.dart';

enum Relation {
  self,
  father,
  mother,
  grandfather,
  grandmother,
  sibling,
  spouse,
  child,
  placeholder,
}

class FamilyMember {
  final String id;
  final String name;
  final String? subtitle; // e.g. "You"
  final String? imageAsset;
  final String? imageUrl;
  final String? lifespan;
  final Relation relation;
  final bool deceased;
  final bool isPlaceholder;
  final Color? placeholderTint;
  final int badgeCount;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.subtitle,
    this.imageAsset,
    this.imageUrl,
    this.lifespan,
    this.deceased = false,
    this.isPlaceholder = false,
    this.placeholderTint,
    this.badgeCount = 0,
  });

  String get roleLabel {
    switch (relation) {
      case Relation.self:
        return 'You';
      case Relation.father:
        return 'Father';
      case Relation.mother:
        return 'Mother';
      case Relation.grandfather:
        return 'Grandfather';
      case Relation.grandmother:
        return 'Grandmother';
      case Relation.sibling:
        return 'Sibling';
      case Relation.spouse:
        return 'Spouse';
      case Relation.child:
        return 'Child';
      case Relation.placeholder:
        return 'Add';
    }
  }

  FamilyMember copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? imageAsset,
    String? imageUrl,
    String? lifespan,
    Relation? relation,
    bool? deceased,
    bool? isPlaceholder,
    Color? placeholderTint,
    int? badgeCount,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      lifespan: lifespan ?? this.lifespan,
      relation: relation ?? this.relation,
      deceased: deceased ?? this.deceased,
      isPlaceholder: isPlaceholder ?? this.isPlaceholder,
      placeholderTint: placeholderTint ?? this.placeholderTint,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}

