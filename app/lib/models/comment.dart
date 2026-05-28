class Comment {
  final String id;
  final String authorName;
  final String text;
  final String time;
  final int likes;
  final bool liked;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.time,
    this.likes = 0,
    this.liked = false,
    this.replies = const [],
  });

  String get authorInitial =>
      authorName.isEmpty ? '?' : authorName.substring(0, 1).toUpperCase();

  Comment copyWith({List<Comment>? replies, int? likes, bool? liked}) {
    return Comment(
      id: id,
      authorName: authorName,
      text: text,
      time: time,
      likes: likes ?? this.likes,
      liked: liked ?? this.liked,
      replies: replies ?? this.replies,
    );
  }
}

const List<Comment> mockComments = [
  Comment(
    id: 'c1',
    authorName: 'Maa',
    text: 'Ahh amazing beta!!!',
    time: '2h',
    likes: 9,
  ),
  Comment(
    id: 'c2',
    authorName: 'Aparna Dey',
    text: 'Wow, it looks yummy🤤',
    time: '2h',
    likes: 12,
  ),
  Comment(
    id: 'c3',
    authorName: 'Priya Dutta',
    text:
        'I am going to make it too. Thanks for sharing. Now I have the whole recipe',
    time: '2h',
    likes: 20,
    liked: true,
  ),
  Comment(
    id: 'c4',
    authorName: 'Aryan Dey',
    text: 'Bohot mast bana tha @nainadey❤️🤤🤤',
    time: '2h',
    likes: 7,
    replies: [
      Comment(id: 'c4r1', authorName: 'Naina', text: 'Thank you!', time: '1h'),
      Comment(id: 'c4r2', authorName: 'Maa', text: 'Pyaare bachhe', time: '1h'),
    ],
  ),
];

const List<String> mockMentionUsers = [
  'Aparna Dey',
  'Ashish Dey',
  'Aryan Dey',
  'Abhijeet Dutta',
  'Aparajita',
];
