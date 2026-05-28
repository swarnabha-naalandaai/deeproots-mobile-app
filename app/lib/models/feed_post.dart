enum PostType { recipe, story, document, tradition, photoAlbum, lifeUpdate }

extension PostTypeLabel on PostType {
  String get label => switch (this) {
        PostType.recipe => 'RECIPE',
        PostType.story => 'STORY',
        PostType.document => 'DOCUMENT',
        PostType.tradition => 'TRADITION',
        PostType.photoAlbum => 'PHOTO ALBUM',
        PostType.lifeUpdate => 'LIFE UPDATE',
      };
}

sealed class FeedPost {
  final String id;
  final String authorName;
  final String timestamp;
  final List<String> tags;
  final int likes;
  final int comments;

  const FeedPost({
    required this.id,
    required this.authorName,
    required this.timestamp,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
  });

  PostType get type;
  String get authorInitial =>
      authorName.isEmpty ? '?' : authorName.substring(0, 1).toUpperCase();
}

class RecipePost extends FeedPost {
  final String coverUrl;
  final bool isVideo;
  final String? videoUrl;
  final String title;
  final String description;
  final int ingredientsCount;
  final int stepsCount;
  final bool hasVoiceNote;

  const RecipePost({
    required super.id,
    required super.authorName,
    required super.timestamp,
    required this.coverUrl,
    required this.title,
    required this.description,
    this.isVideo = false,
    this.videoUrl,
    this.ingredientsCount = 0,
    this.stepsCount = 0,
    this.hasVoiceNote = false,
    super.tags,
    super.likes,
    super.comments,
  });

  @override
  PostType get type => PostType.recipe;
}

class StoryPost extends FeedPost {
  final String coverUrl;
  final String title;
  final String audioUrl;
  final Duration duration;
  final String transcription;

  const StoryPost({
    required super.id,
    required super.authorName,
    required super.timestamp,
    required this.coverUrl,
    required this.title,
    required this.audioUrl,
    required this.duration,
    required this.transcription,
    super.tags,
    super.likes,
    super.comments,
  });

  @override
  PostType get type => PostType.story;
}

class DocumentPost extends FeedPost {
  final String title;
  final String description;
  final String fileName;

  const DocumentPost({
    required super.id,
    required super.authorName,
    required super.timestamp,
    required this.title,
    required this.description,
    required this.fileName,
    super.tags,
    super.likes,
    super.comments,
  });

  @override
  PostType get type => PostType.document;
}

class TraditionPost extends FeedPost {
  final List<String> images;
  final bool firstIsVideo;
  final String? videoUrl;
  final String title;
  final String frequencyLabel;
  final String description;

  const TraditionPost({
    required super.id,
    required super.authorName,
    required super.timestamp,
    required this.images,
    required this.title,
    required this.frequencyLabel,
    required this.description,
    this.firstIsVideo = false,
    this.videoUrl,
    super.tags,
    super.likes,
    super.comments,
  });

  @override
  PostType get type => PostType.tradition;
}

class LifeUpdatePost extends FeedPost {
  final String body;
  final String? audioUrl;
  final Duration? audioDuration;
  final String? transcription;

  const LifeUpdatePost({
    required super.id,
    required super.authorName,
    required super.timestamp,
    required this.body,
    this.audioUrl,
    this.audioDuration,
    this.transcription,
    super.tags,
    super.likes,
    super.comments,
  });

  @override
  PostType get type => PostType.lifeUpdate;
}

class PhotoAlbumPost extends FeedPost {
  final List<String> images;
  final String title;
  final String description;

  const PhotoAlbumPost({
    required super.id,
    required super.authorName,
    required super.timestamp,
    required this.images,
    required this.title,
    required this.description,
    super.tags,
    super.likes,
    super.comments,
  });

  @override
  PostType get type => PostType.photoAlbum;
}

const _img1 = 'https://picsum.photos/seed/aloo/800/600';
const _img2 = 'https://picsum.photos/seed/scooter/800/600';
const _img3 = 'https://picsum.photos/seed/rangoli-diya/600/600';
const _img4 = 'https://picsum.photos/seed/diwali-lamps/600/600';
const _img5 = 'https://picsum.photos/seed/rangoli3/600/600';
const _img6 = 'https://picsum.photos/seed/bhopal-lake/800/600';
const _img7 = 'https://picsum.photos/seed/sanchi-stupa/800/600';
const _img8 = 'https://picsum.photos/seed/upper-lake/800/600';
const _img9 = 'https://picsum.photos/seed/bhopal-street/800/600';
const _img10 = 'https://picsum.photos/seed/family-car/800/600';
const _img11 = 'https://picsum.photos/seed/sunset-mp/800/600';
const _img12 = 'https://picsum.photos/seed/old-fort/800/600';
const _img13 = 'https://picsum.photos/seed/market-mp/800/600';
const _img14 = 'https://picsum.photos/seed/bhopal-night/800/600';

final List<FeedPost> mockFeed = [
  RecipePost(
    id: 'r1',
    authorName: 'Maa',
    timestamp: '2 hours ago',
    coverUrl: _img1,
    isVideo: true,
    videoUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
    title: "Daadi's Aloo Poori",
    description:
        "Daadi only makes this on rainy Sunday afternoons. She says the atta needs to feel the weather. Patience is the secret — the dough rests for at least an hour before it ever touches the rolling pin, and the aloo is mashed by hand, never a masher.",
    ingredientsCount: 8,
    stepsCount: 5,
    hasVoiceNote: true,
    tags: ['Daadi', 'Delhi', 'Recipe'],
    likes: 9,
    comments: 4,
  ),
  StoryPost(
    id: 's1',
    authorName: 'Daadi',
    timestamp: '8 hours ago',
    coverUrl: _img2,
    title: 'The night Daada brought home the scooter',
    audioUrl:
        'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3',
    duration: Duration(minutes: 4),
    transcription:
        "1972 ka saal tha. Tumhare Daada office se ek raat 9 baje ghar aaye, haath mein ek chaabi. Maine pucha 'kya hai?'. Woh muskuraye aur bole 'neeche aao'. Building ke neeche khadi thi ek nayi Bajaj Chetak, gehri laal rang ki. Maine kabhi nahi socha tha ki hum ek scooter le sakte hain.",
    tags: ['Daada', '1972', 'Delhi'],
    likes: 9,
    comments: 4,
  ),
  DocumentPost(
    id: 'd1',
    authorName: 'Bhai',
    timestamp: '29 April 2026',
    title: "Maa-Papa's wedding invitation, 1986",
    description:
        'Scanned the original. Hindi calligraphy on the inside, English on the cover. Even the paper smells like 1986.',
    fileName: 'Wedding_invitation_1986.pdf',
    tags: ['1986', 'Wedding', 'Kolkata'],
    likes: 9,
    comments: 4,
  ),
  TraditionPost(
    id: 't1',
    authorName: 'Sunita Sharma',
    timestamp: '2 days ago',
    images: [_img3, _img4, _img5],
    firstIsVideo: true,
    videoUrl: 'https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4',
    title: 'Diwali rangoli at the threshold',
    frequencyLabel: 'Annual',
    description:
        'Every Diwali morning, before anyone eats, we draw the rangoli at the front door. The pattern changes every year but the lotus in the middle never does. Maa says her mother started it.',
    tags: ['Ritual', 'Home'],
    likes: 9,
    comments: 4,
  ),
  LifeUpdatePost(
    id: 'l1',
    authorName: 'Didi',
    timestamp: '5 hours ago',
    body:
        'Aaj Riya ne school mein apna pehla solo dance perform kiya — Kathak. Sab ne taali bajaayi. Mummy ki aankhein bhar aayin. Recording attached, please sun lena Daadi.',
    audioUrl:
        'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3',
    audioDuration: Duration(seconds: 42),
    transcription:
        'Aaj Riya ne school mein apna pehla solo dance perform kiya. Sab ne taali bajaayi.',
    tags: ['Riya', 'Dance', 'School'],
    likes: 12,
    comments: 3,
  ),
  PhotoAlbumPost(
    id: 'p1',
    authorName: 'Papa',
    timestamp: '2 days ago',
    images: [
      _img6,
      _img7,
      _img8,
      _img9,
      _img10,
      _img11,
      _img12,
      _img13,
      _img14,
      _img4,
      _img5,
      _img1,
      _img2,
      _img3,
    ],
    title: 'Bhopal Trip',
    description:
        'Three days, one car, six people. Sanchi was the highlight — the kids actually quiet for an hour. Upper Lake at sunset was unreal.',
    tags: ['Bhopal', 'Family'],
    likes: 9,
    comments: 4,
  ),
];
