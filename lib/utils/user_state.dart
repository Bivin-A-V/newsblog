import 'dart:io';
import 'package:newsblog/model/news_model.dart';

class UserState {
  static final UserState _instance = UserState._internal();

  factory UserState() {
    return _instance;
  }

  UserState._internal();

  String? _name;
  String signupName = '';
  String email = '';
  File? profileImage;
  String? profileImageUrl;
  int articles = 0;
  int followers = 0;
  int following = 0;
  List<NewsModel> createdArticles = [];

  // Computed property to get the name
  String get name =>
      _name ??
      signupName; // Use the name if edited, otherwise fallback to signupName

  set name(String value) {
    _name = value; // Update the name if edited
  }
}

final userState = UserState(); // Global instance
