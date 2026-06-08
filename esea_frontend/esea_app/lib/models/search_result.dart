class SearchResult {
  final String id;
  final String entityType;
  final String title;
  final String preview;
  final DateTime createdAt;
  final double relevanceScore;

  SearchResult({
    required this.id,
    required this.entityType,
    required this.title,
    required this.preview,
    required this.createdAt,
    required this.relevanceScore,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'].toString(),
      entityType: json['entity_type'] ?? '',
      title: json['title'] ?? '',
      preview: json['preview'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      relevanceScore: json['relevance_score']?.toDouble() ?? 0.0,
    );
  }
}
