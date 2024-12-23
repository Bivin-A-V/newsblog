import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding
import 'dart:io';
import 'package:newsblog/utils/user_state.dart'; // Import UserState

// Comment model
class Comment {
  final String userName;
  final String comment;
  final String dateTime;
  final String userImagePath; // Path to image (local or network)

  Comment({
    required this.userName,
    required this.comment,
    required this.dateTime,
    required this.userImagePath,
  });

  // Convert a Comment object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'comment': comment,
      'dateTime': dateTime,
      'userImagePath': userImagePath,
    };
  }

  // Create a Comment object from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userName: json['userName'],
      comment: json['comment'],
      dateTime: json['dateTime'],
      userImagePath: json['userImagePath'],
    );
  }
}

class NBCommentScreen extends StatefulWidget {
  @override
  _NBCommentScreenState createState() => _NBCommentScreenState();
}

class _NBCommentScreenState extends State<NBCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = []; // List to store comments

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  // Load comments from SharedPreferences
  Future<void> _loadComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedComments = prefs.getString('comments');
    if (savedComments != null) {
      List<dynamic> commentList = jsonDecode(savedComments);
      setState(() {
        comments = commentList.map((e) => Comment.fromJson(e)).toList();
      });
    }
  }

  // Save comments to SharedPreferences
  Future<void> _saveComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedComments =
        jsonEncode(comments.map((comment) => comment.toJson()).toList());
    await prefs.setString('comments', encodedComments);
  }

  // Function to Post a New Comment
  void _postComment() {
    if (_commentController.text.isNotEmpty) {
      // Fetch user details from UserState
      String userImagePath;
      if (userState.profileImage != null) {
        userImagePath = userState.profileImage!.path;
      } else if (userState.profileImageUrl != null &&
          userState.profileImageUrl!.isNotEmpty) {
        userImagePath = userState.profileImageUrl!;
      } else {
        userImagePath = 'placeholder'; // Use a placeholder identifier
      }

      // Get current timestamp
      String currentDateTime = DateTime.now().toString();

      // Create a new Comment object
      Comment newComment = Comment(
        userName:
            userState.name.isNotEmpty ? userState.name : userState.signupName,
        comment: _commentController.text,
        dateTime: currentDateTime,
        userImagePath: userImagePath,
      );

      // Add the comment to the list and update the UI
      setState(() {
        comments.add(newComment);
      });

      // Save comments to persistent storage
      _saveComments();

      // Clear the input field
      _commentController.clear();
    }
  }

  // Function to Delete a Comment
  void _deleteComment(int index) {
    setState(() {
      comments.removeAt(index);
    });
    _saveComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News Article"),
      ),
      body: Column(
        children: [
          // Display Comments Section
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return GestureDetector(
                  onLongPress: () => _deleteComment(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Image
                        CircleAvatar(
                          backgroundImage:
                              comment.userImagePath == 'placeholder'
                                  ? AssetImage('images/placeholder.jpg')
                                      as ImageProvider
                                  : comment.userImagePath.startsWith('http')
                                      ? NetworkImage(comment.userImagePath)
                                      : FileImage(File(comment.userImagePath)),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),

                        // User Details and Comment
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display Username
                              Text(
                                comment.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Display Comment Text
                              Text(
                                comment.comment,
                                style: const TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 5),

                              // Display Comment Timestamp
                              Text(
                                comment.dateTime,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Field to Add New Comment
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Comment Input Field
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Add your comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                // Send Button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
