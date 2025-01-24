import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:newsblog/model/news_model.dart';

class DataBaseHelper {
  final String cloudinaryUrl =
      "https://api.cloudinary.com/v1_1/dtimkxg1n/image/upload";

  final String uploadPreset = "unsigned_preset";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Uploads an image to Cloudinary and returns its public URL.
  Future<String?> uploadImageToCloudinary(File image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData.body);
        return data['secure_url']; // Cloudinary's public URL
      } else {
        throw Exception("Failed to upload image: ${responseData.body}");
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }

  /// Adds article details to Firestore.
  Future<void> addArticleDetails(
      String userId, Map<String, dynamic> articleInfoMap, String id) async {
    try {
      await _firestore
          .collection("Articles")
          .doc(userId)
          .collection("UserArticles")
          .doc(id)
          .set(articleInfoMap);
    } catch (e) {
      print("Error adding article to Firestore: $e");
      throw Exception("Failed to add article to Firestore: $e");
    }
  }

  /// Fetches articles published by the currently logged-in user.
  Future<List<NewsModel>> fetchUserArticles(String userId) async {
    try {
      // Query Firestore for articles under the current user's ID
      QuerySnapshot snapshot = await _firestore
          .collection("Articles")
          .doc(userId)
          .collection("UserArticles")
          .get();

      // Map Firestore documents to NewsModel objects
      List<NewsModel> userArticles = snapshot.docs.map((doc) {
        return NewsModel.fromFirestore(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      return userArticles;
    } catch (e) {
      print("Error fetching user's articles: $e");
      throw Exception("Failed to fetch user's articles.");
    }
  }

  /// Fetches all articles from Firestore.
  Future<List<NewsModel>> fetchAllArticles() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collectionGroup('UserArticles').get();
      List<NewsModel> articles = snapshot.docs.map((doc) {
        // Pass Firestore document ID as the `id` to NewsModel
        return NewsModel.fromFirestore(
            doc.id, doc.data() as Map<String, dynamic>);
// Pass document ID
      }).toList();
      return articles;
    } catch (e) {
      print("Error fetching articles: $e");
      throw Exception("Failed to fetch articles.");
    }
  }
}
