// news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsblog/model/news_model.dart';

class NewsService {
  final String _apiKey = '33753398ed8b877af2bb18bd47fecd03';
  final String _baseUrl = 'https://gnews.io/api/v4/top-headlines';

  // Fetch news by category
  Future<List<NewsModel>> fetchNews(String category) async {
    final url =
        '$_baseUrl?category=$category&lang=en&country=us&max=10&apikey=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['articles'] != null) {
          return (data['articles'] as List)
              .map((article) => NewsModel.fromJson(article, category))
              .toList();
        }
      }
      throw Exception('Failed to load news');
    } catch (e) {
      print('Error fetching $category news: $e');
      return [];
    }
  }
}
