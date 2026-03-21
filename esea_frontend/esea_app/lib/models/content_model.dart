class ContentModel {
  final String id;
  final String type;
  final String title;
  final String shortDescription;
  final String? fullDescription;
  final String? imageUrl;
  final String? fileUrl;
  final String? externalLink;
  final String? eventVenue;
  final String? eventDate;
  final String? eventTime;
  final String? deadline;
  final String published_at;
  
  ContentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    this.imageUrl,
    this.fileUrl,
    this.externalLink,
    this.eventVenue,
    this.eventDate,
    this.eventTime,
    this.deadline,
    required this.published_at,
  });

   bool get isNew {
    try {
      final date = DateTime.parse(published_at);
      return DateTime.now().difference(date).inDays <= 2;
    } catch (e) {
      return false;
    }
  }

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'].toString(),
      type: json['type'],
      title: json['title'],
      shortDescription: json['short_description'],
      fullDescription: json['full_description'],
      imageUrl: json['image_url'],
      fileUrl: json['file_url'],
      externalLink: json['external_link'],
      eventVenue: json['event_venue'],
      eventDate: json['event_date'],
      eventTime: json['event_time'],
      deadline: json['deadline'],
      published_at: json['published_at'],
    );
  }
}
