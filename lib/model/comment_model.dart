import 'package:flutter/material.dart';

class Comment {
  final String userName;
  final String comment;
  final String dateTime;
  final ImageProvider userImage;

  Comment({
    required this.userName,
    required this.comment,
    required this.dateTime,
    required this.userImage,
  });
}
