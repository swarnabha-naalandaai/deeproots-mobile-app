import 'package:flutter/material.dart';
import 'family_member.dart';

const _tintFather = Color(0xFFC8D1CE);
const _tintMother = Color(0xFFDDD7CD);
const _tintSibling = Color(0xFFD8D8D8);

class FamilyTreeMock {
  static const FamilyMember anant = FamilyMember(
    id: 'anant',
    name: 'Anant Dey',
    relation: Relation.grandfather,
  );

  static const FamilyMember prerna = FamilyMember(
    id: 'prerna',
    name: 'Prerna Dey',
    relation: Relation.grandmother,
    lifespan: '1944-2006',
    deceased: true,
  );

  static const FamilyMember fatherPlaceholder = FamilyMember(
    id: 'father_p',
    name: 'Father',
    relation: Relation.father,
    isPlaceholder: true,
    placeholderTint: _tintFather,
  );

  static const FamilyMember motherPlaceholder = FamilyMember(
    id: 'mother_p',
    name: 'Mother',
    relation: Relation.mother,
    isPlaceholder: true,
    placeholderTint: _tintMother,
  );

  static const FamilyMember ashish = FamilyMember(
    id: 'ashish',
    name: 'Ashish K. Dey',
    relation: Relation.father,
  );

  static const FamilyMember aparna = FamilyMember(
    id: 'aparna',
    name: 'Aparna Dey',
    relation: Relation.mother,
    deceased: true,
    badgeCount: 2,
  );

  static const FamilyMember meera = FamilyMember(
    id: 'meera',
    name: 'Meera Dutta',
    relation: Relation.mother,
    deceased: true,
  );

  static const FamilyMember riya = FamilyMember(
    id: 'riya',
    name: 'Riya',
    subtitle: 'You',
    relation: Relation.self,
  );

  static const FamilyMember siblingPlaceholder = FamilyMember(
    id: 'sibling_p',
    name: 'Sibling',
    relation: Relation.sibling,
    isPlaceholder: true,
    placeholderTint: _tintSibling,
  );

  static const List<FamilyMember> all = [
    anant,
    prerna,
    fatherPlaceholder,
    motherPlaceholder,
    ashish,
    aparna,
    meera,
    riya,
    siblingPlaceholder,
  ];
}
