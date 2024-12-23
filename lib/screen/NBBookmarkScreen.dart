import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/screen/NBHomeScreen.dart';
import 'package:newsblog/utils/globals.dart';

class NBBookmarkScreen extends StatefulWidget {
  @override
  _NBBookmarkScreenState createState() => _NBBookmarkScreenState();
}

class _NBBookmarkScreenState extends State<NBBookmarkScreen> {
  List<String> dropDownItems = ['Most Recent', 'Ascending', 'Descending'];
  String? dropDownValue = 'Most Recent';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              NBHomeScreen().launch(context);
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sort by',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                DropdownButton<String>(
                  value: dropDownValue,
                  items: dropDownItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropDownValue = newValue;
                      toasty(context, dropDownValue);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(
                height: 10), // Space between Sort Row and Bookmarked Items
            // List of Bookmarked News
            Expanded(
              child: ListView.builder(
                itemCount: bookmarkedNews.length,
                itemBuilder: (context, index) {
                  final news = bookmarkedNews[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                            image: news.imageUrl != null &&
                                    news.imageUrl.isNotEmpty
                                ? NetworkImage(news.imageUrl)
                                : AssetImage('assets/images/placeholder.png')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        news.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        news.publishedAt,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            bookmarkedNews.remove(news);
                            toasty(context, 'Removed from Bookmarks');
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
