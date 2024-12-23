// news_model.dart
class NewsModel {
  final String category;
  final String title;
  final String imageUrl;
  final String publishedAt;
  final String description;
  final String sourceName; // New property to store the source name

  NewsModel({
    required this.category,
    required this.title,
    required this.imageUrl,
    required this.publishedAt,
    required this.description,
    required this.sourceName, // Add sourceName to the constructor
  });

  // Factory method to create an instance from JSON
  factory NewsModel.fromJson(Map<String, dynamic> json, String category) {
    return NewsModel(
      description: json['description'],
      category: category,
      title: json['title'] ?? 'No title available',
      imageUrl: json['image'] ?? '',
      publishedAt: json['publishedAt']?.substring(0, 10) ?? 'No date available',
      sourceName: json['source']['name'] ??
          'Unknown source', // Extract source name from the JSON
    );
  }
}
