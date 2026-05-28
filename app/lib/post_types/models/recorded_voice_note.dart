class RecordedVoiceNote {
  final String path;
  final Duration duration;
  final DateTime createdAt;
  final String? transcript;

  const RecordedVoiceNote({
    required this.path,
    required this.duration,
    required this.createdAt,
    this.transcript,
  });
}
