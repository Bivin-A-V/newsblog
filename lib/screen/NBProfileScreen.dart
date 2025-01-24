import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/model/news_model.dart';
import 'package:newsblog/screen/NBNewsDetailsScreen.dart';
import 'package:newsblog/services/database.dart';
import 'package:newsblog/utils/NBColors.dart';

class NBProfileScreen extends StatefulWidget {
  static String tag = '/NBProfileScreen';

  const NBProfileScreen({super.key});

  @override
  NBProfileScreenState createState() => NBProfileScreenState();
}

class NBProfileScreenState extends State<NBProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List<NewsModel> createdArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
    _fetchCreatedArticles();
  }

  Future<void> _fetchCreatedArticles() async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        createdArticles = await DataBaseHelper().fetchUserArticles(userId);
      } else {
        toasty(context, 'User is not logged in.');
      }
    } catch (e) {
      log('Error fetching created articles: $e');
      toasty(context, 'Failed to load articles.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  Widget _buildProfileHeader(DocumentSnapshot userData) {
    final String userName = userData.get('name') ?? 'User';
    final String profileImg = userData.get('profileImageUrl') ?? '';
    final int followersCount = userData.get('followers') ?? 0;
    final int followingCount = userData.get('following') ?? 0;

    return Container(
      margin: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 50,
            backgroundImage: profileImg.isNotEmpty
                ? NetworkImage(profileImg)
                : const AssetImage('images/placeholder.jpg') as ImageProvider,
            child: profileImg.isEmpty
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'NB',
                    style: const TextStyle(fontSize: 20.0, color: Colors.white),
                  )
                : null,
          ),
          8.height,
          Text(
            userName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          16.height,
          Row(
            children: [
              Column(
                children: [
                  Text('${createdArticles.length}',
                      style: boldTextStyle(color: NBPrimaryColor)),
                  Text('Articles', style: boldTextStyle()),
                ],
              ).expand(),
              Column(
                children: [
                  Text('$followersCount',
                      style: boldTextStyle(color: NBPrimaryColor)),
                  Text('Followers', style: boldTextStyle()),
                ],
              ).expand(),
              Column(
                children: [
                  Text('$followingCount',
                      style: boldTextStyle(color: NBPrimaryColor)),
                  Text('Following', style: boldTextStyle()),
                ],
              ).expand(),
            ],
          ),
          16.height,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : NestedScrollView(
              physics: const ScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 330,
                    backgroundColor: white,
                    title: Text('Profile',
                        style: boldTextStyle(size: 20, color: black)),
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          try {
                            return _buildProfileHeader(snapshot.data!);
                          } catch (e) {
                            log('Error reading Firestore data: $e');
                            return const Center(
                                child: Text('Failed to load user data.'));
                          }
                        },
                      ),
                    ),
                    bottom: TabBar(
                      controller: tabController,
                      labelColor: NBPrimaryColor,
                      unselectedLabelColor: grey,
                      tabs: const [
                        Tab(text: 'Articles'),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: tabController,
                children: [
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : createdArticles.isEmpty
                          ? const Center(
                              child: Text(
                                'No Content to Show!',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            )
                          : ListView.builder(
                              itemCount: createdArticles.length,
                              itemBuilder: (context, index) {
                                final article = createdArticles[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      leading: article.imageUrl.isNotEmpty
                                          ? (Uri.tryParse(article.imageUrl)
                                                      ?.hasAbsolutePath ??
                                                  false)
                                              ? Image.network(
                                                  article
                                                      .imageUrl, // Fetches the image from a network URL
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      const Icon(
                                                          Icons.broken_image,
                                                          size: 50),
                                                )
                                              : File(article.imageUrl)
                                                      .existsSync()
                                                  ? Image.file(
                                                      File(article.imageUrl),
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const Icon(Icons.image,
                                                      size: 50)
                                          : const Icon(Icons.image, size: 50),
                                      title: Text(article.title,
                                          style: boldTextStyle()),
                                      subtitle: Text(article.publishedAt,
                                          style: secondaryTextStyle()),
                                      onTap: () {
                                        NBNewsDetailsScreen(
                                                newsDetails: article)
                                            .launch(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
    );
  }
}
