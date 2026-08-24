/// One module within a [TopicDetailScreen]'s "Sub-topics & Challenges" list.
class SubTopic {
  const SubTopic({
    required this.title,
    required this.description,
    required this.taskCount,
    required this.duration,
  });

  final String title;
  final String description;
  final int taskCount;

  /// Pre-formatted duration label, e.g. "~20m".
  final String duration;
}
