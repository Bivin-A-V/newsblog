import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/main.dart';
import 'package:newsblog/model/news_model.dart';
import 'package:newsblog/screen/NBCommentScreen.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBImages.dart';
import 'package:newsblog/utils/NBWidgets.dart';
import 'package:newsblog/utils/globals.dart';
import 'package:newsblog/utils/user_state.dart';

class NBNewsDetailsScreen extends StatefulWidget {
  final NewsModel newsDetails; // Receive NewsModel directly
  final VoidCallback? onFollow;

  const NBNewsDetailsScreen(
      {Key? key, required this.newsDetails, this.onFollow})
      : super(key: key);

  @override
  NBNewsDetailsScreenState createState() => NBNewsDetailsScreenState();
}

class NBNewsDetailsScreenState extends State<NBNewsDetailsScreen> {
  bool isFollowing = false;
  // Check if the news is bookmarked
  bool get isBookmarked {
    return bookmarkedNews.contains(widget.newsDetails);
  }

  void toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
      if (isFollowing) {
        // Increment followers for the article's author
        if (widget.newsDetails.sourceName == userState.name) {
          userState.followers++;
        }

        // Increment following count for the current user
        userState.following++;
        widget.onFollow?.call();
      }
    });
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
                  onPressed: () {
                    toggleBookmark();
                  },
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
                NBCommentScreen().launch(context);
              },
            ),
            16.height,
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }
}
