import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/user_state.dart';

class NBProfileScreen extends StatefulWidget {
  static String tag = '/NBProfileScreen';

  const NBProfileScreen({super.key});

  @override
  NBProfileScreenState createState() => NBProfileScreenState();
}

class NBProfileScreenState extends State<NBProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    tabController = TabController(length: 1, vsync: this);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        physics: const ScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              expandedHeight: 330,
              backgroundColor: white,
              title:
                  Text('Profile', style: boldTextStyle(size: 20, color: black)),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 50,
                        backgroundImage: userState.profileImage != null
                            ? FileImage(userState.profileImage!)
                            : (userState.profileImageUrl != null &&
                                    userState.profileImageUrl!.isNotEmpty
                                ? NetworkImage(userState.profileImageUrl!)
                                : const AssetImage('images/placeholder.jpg')),
                        child: (userState.profileImage == null &&
                                (userState.profileImageUrl == null ||
                                    userState.profileImageUrl!.isEmpty))
                            ? Text(
                                userState.name.isNotEmpty
                                    ? userState.name[0].toUpperCase()
                                    : 'NB',
                                style: const TextStyle(
                                    fontSize: 20.0, color: Colors.white),
                              )
                            : null,
                      ),
                      8.height,
                      Text(
                        userState.name.isNotEmpty
                            ? userState.name
                            : userState.signupName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      16.height,
                      Row(
                        children: [
                          Column(
                            children: [
                              Text('${userState.articles}',
                                  style: boldTextStyle(color: NBPrimaryColor)),
                              Text('Articles', style: boldTextStyle()),
                            ],
                          ).expand(),
                          Column(
                            children: [
                              Text('${userState.followers}',
                                  style: boldTextStyle(color: NBPrimaryColor)),
                              Text('Followers', style: boldTextStyle()),
                            ],
                          ).onTap(() {}).expand(),
                          Column(
                            children: [
                              Text('${userState.following}',
                                  style: boldTextStyle(color: NBPrimaryColor)),
                              Text('Following', style: boldTextStyle()),
                            ],
                          ).onTap(() {}).expand(),
                        ],
                      ),
                      16.height,
                    ],
                  ),
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
            // Articles Tab
            userState.createdArticles.isEmpty
                ? const Center(
                    child: Text(
                      'No Content to Show!',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  )
                : ListView.builder(
                    itemCount: userState.createdArticles.length,
                    itemBuilder: (context, index) {
                      final article = userState.createdArticles[index];
                      return ListTile(
                        leading: Image.file(
                          File(article.imageUrl),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(article.title, style: boldTextStyle()),
                        subtitle: Text(article.publishedAt,
                            style: secondaryTextStyle()),
                        onTap: () {
                          // Navigate to article details
                          // Use appropriate navigation logic if needed
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
