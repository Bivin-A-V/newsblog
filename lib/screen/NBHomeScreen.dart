import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/model/news_model.dart';
import 'package:newsblog/screen/NBCreateNewArticleScreen.dart';
import 'package:newsblog/screen/NBDashboardScreen.dart';
import 'package:newsblog/screen/NBNewsDetailsScreen.dart';
import 'package:newsblog/services/news_service.dart';
import 'package:newsblog/utils/user_state.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:newsblog/utils/NBColors.dart';

class NBHomeScreen extends StatefulWidget {
  static String tag = '/NBHomeScreen';

  @override
  NBHomeScreenState createState() => NBHomeScreenState();
}

class NBHomeScreenState extends State<NBHomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? tabController;
  int _currentPage = 0;
  final List<String> imageList = [
    'assets/images/nb_newsImage1.jpg',
    'assets/images/nb_newsImage2.jpg',
    'assets/images/nb_newsImage1.jpg',
  ];

  List<NewsModel> allNews = [];
  List<NewsModel> technologyNews = [];
  List<NewsModel> fashionNews = [];
  List<NewsModel> sportsNews = [];
  List<NewsModel> scienceNews = [];

  final NewsService newsService = NewsService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    fetchAllNews();
  }

  Future<void> fetchAllNews() async {
    try {
      allNews = await newsService.fetchNews('top headlines');
      technologyNews = await newsService.fetchNews('technology');
      fashionNews = await newsService.fetchNews('fashion');
      sportsNews = await newsService.fetchNews('sports');
      scienceNews = await newsService.fetchNews('science');
    } catch (e) {
      log("Error fetching news: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Handle adding new article
  Future<void> _addNewArticle() async {
    final newArticle = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NBCreateNewArticleScreen()),
    );

    if (newArticle != null) {
      setState(() {
        allNews.insert(
            0, newArticle); // Add the new article to the top of the list
      });
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  // Function to get the image provider (either FileImage or NetworkImage)
  ImageProvider<Object> _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return NetworkImage(imageUrl);
    } else {
      return FileImage(File(imageUrl));
    }
  }

  Widget buildAllNewsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Shrink-wrap the Column
      children: [
        const SizedBox(height: 10),
        CarouselSlider.builder(
          itemCount: imageList.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                imageList[index],
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
            );
          },
          options: CarouselOptions(
            height: 200,
            initialPage: 0,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: AnimatedSmoothIndicator(
            activeIndex: _currentPage,
            count: imageList.length,
            effect: const JumpingDotEffect(
              dotHeight: 10,
              dotWidth: 10,
              spacing: 12,
              activeDotColor: NBPrimaryColor,
              dotColor: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest News',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to create a new article screen
                  _addNewArticle();
                },
                child: const Text(
                  'Add Article',
                  style: TextStyle(
                    color: NBPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Flexible(
          // Use Flexible to prevent height constraints issue
          child: ListView.builder(
            shrinkWrap: true, // Allow ListView to size itself
            physics:
                const NeverScrollableScrollPhysics(), // Prevent scroll conflict
            itemCount: allNews.length,
            itemBuilder: (context, index) {
              final news = allNews[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: Colors.grey[200],
                  leading: Container(
                    width: 100,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: news.imageUrl != null && news.imageUrl.isNotEmpty
                            ? NetworkImage(news.imageUrl)
                            : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    news.category,
                    style: const TextStyle(
                      color: NBPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        news.publishedAt,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    NBNewsDetailsScreen(
                      newsDetails: news,
                    ).launch(context);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildNewsTab(List<NewsModel> newsList) {
    if (newsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: Colors.grey[200],
            leading: Container(
              width: 100,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: news.imageUrl != null && news.imageUrl.isNotEmpty
                      ? NetworkImage(news.imageUrl)
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              news.category,
              style: const TextStyle(
                color: NBPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  news.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  news.publishedAt,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              NBNewsDetailsScreen(
                newsDetails: news,
              ).launch(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('app_title'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: 'all_news'.tr()),
            Tab(text: 'technology'.tr()),
            Tab(text: 'fashion'.tr()),
            Tab(text: 'sports'.tr()),
            Tab(text: 'science'.tr()),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelColor: Colors.black,
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          unselectedLabelColor: Colors.grey,
          indicatorColor: NBPrimaryColor,
          indicatorWeight: 3,
          isScrollable: true,
        ),
      ),
      drawer: AppDrawer(userState.profileImageUrl),
      body: TabBarView(
        controller: tabController,
        children: [
          SingleChildScrollView(child: buildAllNewsTab()),
          buildNewsTab(technologyNews),
          buildNewsTab(fashionNews),
          buildNewsTab(sportsNews),
          buildNewsTab(scienceNews),
        ],
      ),
    );
  }
}
