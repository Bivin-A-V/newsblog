import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import UserState
import 'package:timeago/timeago.dart' as timeago;
import 'dart:io';

class Comment {
  final String userName;
  final String comment;
  final String dateTime;
  final String userImagePath;

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
  final String articleId; // Article ID to associate comments

  const NBCommentScreen({required this.articleId});

  @override
  _NBCommentScreenState createState() => _NBCommentScreenState();
}

class _NBCommentScreenState extends State<NBCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName;
  String? userImagePath;

  // Function to calculate "time ago"
  String getTimeAgo(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return timeago.format(dateTime);
  }

  // Fetch current user's data from Firestore
  Future<void> _fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get('name') ?? 'Unknown';
          userImagePath = userDoc.get('profileImageUrl') ?? 'placeholder';
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Function to Post a New Comment
  Future<void> _postComment() async {
    if (_commentController.text.isNotEmpty) {
      // Ensure user data is fetched before posting the comment
      if (userName == null || userImagePath == null) {
        await _fetchUserData();
      }

      // Get current timestamp
      String currentDateTime = DateTime.now().toIso8601String();

      // Create a new Comment object
      Comment newComment = Comment(
        userName: userName ?? 'Unknown', // Fallback if name is null

        comment: _commentController.text,
        dateTime: currentDateTime,
        userImagePath:
            userImagePath ?? 'placeholder', // Fallback if image is null
      );

      try {
        // Add the comment to the Firestore subcollection
        await _firestore
            .collection('Articles')
            .doc(widget.articleId)
            .collection('Comments')
            .add(newComment.toJson());

        // Clear the input field
        _commentController.clear();
      } catch (e) {
        print("Error posting comment: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to post comment. Please try again.")),
        );
      }
    }
  }

  // Stream to Fetch Comments from Firestore
  Stream<List<Comment>> _fetchComments() {
    return _firestore
        .collection('Articles')
        .doc(widget.articleId)
        .collection('Comments')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Display Comments Section
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _fetchComments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching comments."));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No comments yet."));
                }

                final comments = snapshot.data!;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Padding(
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
                                    : NetworkImage(comment.userImagePath),
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
                                const SizedBox(height: 5),

                                // Display Comment Timestamp
                                Text(
                                  getTimeAgo(comment.dateTime), // "x mins ago"
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
                    );
                  },
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
