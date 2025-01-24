import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/main.dart';
import 'package:newsblog/model/news_model.dart';
import 'package:newsblog/screen/NBCommentScreen.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBImages.dart';
import 'package:newsblog/utils/NBWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsblog/utils/globals.dart';

class NBNewsDetailsScreen extends StatefulWidget {
  final NewsModel newsDetails;
  final VoidCallback? onFollow;

  const NBNewsDetailsScreen({
    Key? key,
    required this.newsDetails,
    this.onFollow,
  }) : super(key: key);

  @override
  NBNewsDetailsScreenState createState() => NBNewsDetailsScreenState();
}

class NBNewsDetailsScreenState extends State<NBNewsDetailsScreen> {
  bool isFollowing = false;
  String currentUserName = '';
  String? authorId;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Check if the article is bookmarked
  bool get isBookmarked {
    return bookmarkedNews.contains(widget.newsDetails);
  }

  void toggleBookmark() {
    setState(() {
      if (isBookmarked) {
        bookmarkedNews.remove(widget.newsDetails);
        toasty(context, 'Removed from Bookmarks');
      } else {
        bookmarkedNews.add(widget.newsDetails);
        toasty(context, 'Added to Bookmarks');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAuthorIdAndFollowStatus();
    _fetchUserData();
  }

  Future<void> _fetchAuthorIdAndFollowStatus() async {
    try {
      // Get the author ID directly from the article
      DocumentSnapshot articleSnapshot = await FirebaseFirestore.instance
          .collection('Articles')
          .doc(widget.newsDetails.articleId) // articleId == userId
          .get();

      if (articleSnapshot.exists) {
        setState(() {
          authorId =
              articleSnapshot.id; // The document ID is the author's userId
        });

        // Listen for follow status in real-time
        _listenFollowStatus();
      }
    } catch (e) {
      toasty(context, 'Error fetching article details.');
    }
  }

  void _listenFollowStatus() {
    if (authorId == null || currentUserId == null) return;

    // Listen to real-time changes in the follow status
    FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .snapshots()
        .listen((currentUserDoc) {
      if (currentUserDoc.exists) {
        setState(() {
          List followingList = currentUserDoc['followingList'] ?? [];
          isFollowing = followingList.contains(authorId);
        });
      }
    });
  }

  Future<void> _fetchUserData() async {
    String? userId = currentUserId;

    if (userId == null) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        currentUserName = userDoc['name'] ?? '';
      });
    }
  }

  Future<void> toggleFollow() async {
    if (authorId == null || currentUserId == null) {
      toasty(context, 'Error performing follow action.');
      return;
    }

    String userId = currentUserId!;
    bool followAction = !isFollowing;

    try {
      // Perform Firestore updates in a batch
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update current user's following count and list
      batch.update(
        FirebaseFirestore.instance.collection('Users').doc(userId),
        {
          'following': FieldValue.increment(followAction ? 1 : -1),
          if (followAction)
            'followingList': FieldValue.arrayUnion([authorId])
          else
            'followingList': FieldValue.arrayRemove([authorId]),
        },
      );

      // Update the author's followers count
      batch.update(
        FirebaseFirestore.instance.collection('Users').doc(authorId),
        {
          'followers': FieldValue.increment(followAction ? 1 : -1),
        },
      );

      // Commit the batch
      await batch.commit();

      setState(() {
        isFollowing = followAction;
      });

      widget.onFollow?.call(); // Trigger the callback (if any)
    } catch (e) {
      toasty(context, 'Error performing follow action: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: appStore.isDarkModeOn ? white : black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: context.cardColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.newsDetails.category,
                style: boldTextStyle(color: NBPrimaryColor)),
            Row(
              children: [
                Text(widget.newsDetails.title, style: boldTextStyle(size: 20))
                    .expand(flex: 3),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? NBPrimaryColor : null,
                  ),
                  onPressed: toggleBookmark,
                ),
              ],
            ),
            16.height,
            commonCachedNetworkImage(
              widget.newsDetails.imageUrl,
              height: 200,
              width: context.width(),
              fit: BoxFit.cover,
            ).cornerRadiusWithClipRRect(16),
            16.height,
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Text('Source: ${widget.newsDetails.sourceName}',
                  style: boldTextStyle()),
              subtitle: Text(widget.newsDetails.publishedAt,
                  style: secondaryTextStyle()),
              leading:
                  CircleAvatar(backgroundImage: AssetImage(NBProfileImage)),
              trailing: AppButton(
                elevation: 0,
                text: isFollowing ? 'Following' : 'Follow',
                onTap: toggleFollow,
                color: isFollowing ? grey.withAlpha(51) : black,
                textColor: isFollowing ? grey : white,
              ).cornerRadiusWithClipRRect(30),
            ),
            16.height,
            Text(widget.newsDetails.description,
                style: primaryTextStyle(), textAlign: TextAlign.justify),
            16.height,
            nbAppButtonWidget(
              context,
              'Comment',
              () {
                NBCommentScreen(articleId: widget.newsDetails.articleId)
                    .launch(context);
              },
            ),
            16.height,
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }
}
