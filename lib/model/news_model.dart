import 'dart:convert';

import 'package:crypto/crypto.dart';

class NewsModel {
  final String articleId; // Unique article ID
  final String category;
  final String title;
  final String imageUrl;
  final String publishedAt;
  final String description;
  final String sourceName;
  final bool isAudioArticle;

  NewsModel({
    required this.articleId, // Now requires articleId
    required this.category,
    required this.title,
    required this.imageUrl,
    required this.publishedAt,
    required this.description,
    required this.sourceName,
    required this.isAudioArticle,
  });

  // Factory method for Firestore data
  factory NewsModel.fromFirestore(
      String id, Map<String, dynamic> firestoreData) {
    return NewsModel(
      articleId: id, // Use Firestore document ID as articleId
      category: firestoreData['Category'] ?? 'No category available',
      title: firestoreData['Title'] ?? 'No title available',
      imageUrl: firestoreData['imageUrl'] ?? '',
      publishedAt: firestoreData['date'] ?? 'No date available',
      description: firestoreData['Description'] ?? 'No description available',
      sourceName: firestoreData['sourceName'] ?? 'Unknown source',
      isAudioArticle: firestoreData['isAudioArticle'] ?? false,
    );
  }

  // Factory method for API data
  factory NewsModel.fromJson(Map<String, dynamic> json, String category) {
    // Generate a unique articleId by hashing the title and published date
    String articleId = generateArticleId(json['title'], json['publishedAt']);

    return NewsModel(
      articleId: articleId,
      category: category,
      title: json['title'] ?? 'No title available',
      imageUrl: json['image'] ?? '',
      publishedAt: json['publishedAt']?.substring(0, 10) ?? 'No date available',
      description: json['description'] ?? 'No description available',
      sourceName: json['source']['name'] ?? 'Unknown source',
      isAudioArticle: false, // Default value for API articles
    );
  }

  // Helper function to generate a unique articleId by hashing the title and published date
  static String generateArticleId(String title, String publishedAt) {
    // Combine title and published date as a string
    String inputString = '$title$publishedAt';

    // Generate a hash of the combined string
    var bytes = utf8.encode(inputString); // Convert to bytes
    var hash = sha256.convert(bytes); // SHA-256 hash

    // Return the hash as a string
    return hash.toString();
  }
}
