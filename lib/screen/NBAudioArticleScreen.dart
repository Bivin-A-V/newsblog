import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/model/news_model.dart';
import 'package:newsblog/screen/NBAudioDetailsScreen.dart'; // Update import for audio details
import 'package:newsblog/services/database.dart';
import 'package:newsblog/services/news_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:newsblog/utils/NBColors.dart';

class NBAudioArticleScreen extends StatefulWidget {
  static String tag = '/NBAudioArticleScreen';
  final NewsModel? newAudioArticle;

  const NBAudioArticleScreen({this.newAudioArticle});

  @override
  _NBAudioArticleScreenState createState() => _NBAudioArticleScreenState();
}

class _NBAudioArticleScreenState extends State<NBAudioArticleScreen>
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
      // Fetch news from the API
      allNews = await newsService.fetchNews('top headlines');
      technologyNews = await newsService.fetchNews('technology');
      fashionNews = await newsService.fetchNews('fashion');
      sportsNews = await newsService.fetchNews('sports');
      scienceNews = await newsService.fetchNews('science');
// Fetch created articles
      List<NewsModel> createdArticles =
          await DataBaseHelper().fetchAllArticles();

      // Filter out articles where isAudioArticle is true
      List<NewsModel> AudioArticles =
          createdArticles.where((article) => article.isAudioArticle).toList();

      // Merge created articles with API news
      setState(() {
        allNews = [...AudioArticles, ...allNews];
      });
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

  // Function to calculate total duration for a news article
  double _calculateTotalDuration(String text, {double speechRate = 0.5}) {
    int wordCount = text.split(' ').length;
    double estimatedDurationInMinutes = wordCount /
        (speechRate * 200); // Average of 200 words per minute at speechRate 1.0
    return estimatedDurationInMinutes * 60; // Convert to seconds
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  Widget buildAllNewsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        CarouselSlider.builder(
          itemCount: imageList.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                child: Image.asset(
                  imageList[index],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                ),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest News',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allNews.length,
            itemBuilder: (context, index) {
              final news = allNews[index];
              // Calculate total duration for the news description
              double totalDuration = _calculateTotalDuration(news.description);

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
                    NBAudioDetailsScreen(
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
        double totalDuration = _calculateTotalDuration(news.description);
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
                const SizedBox(height: 10),
                // Display total duration in seconds or minutes
                Text(
                  'Duration: ${_formatDuration(totalDuration)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            onTap: () {
              NBAudioDetailsScreen(
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Audio Article',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'All News'),
            Tab(text: 'Technology'),
            Tab(text: 'Fashion'),
            Tab(text: 'Sports'),
            Tab(text: 'Science'),
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

  // Helper function to format duration as minutes:seconds
  String _formatDuration(double duration) {
    int minutes = (duration / 60).floor();
    int seconds = (duration % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
