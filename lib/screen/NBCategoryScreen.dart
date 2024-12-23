import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/model/NBModel.dart';
import 'package:newsblog/utils/NBDataProviders.dart';
import 'package:newsblog/utils/NBWidgets.dart';

class NBCategoryScreen extends StatefulWidget {
  static String tag = '/NBCategoryScreen';

  @override
  NBCategoryScreenState createState() => NBCategoryScreenState();
}

class NBCategoryScreenState extends State<NBCategoryScreen> {
  List<NBCategoryItemModel> mCategoryList = nbGetCategoryItems();

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: nbAppBarWidget(context, title: 'Categories'),
      body: GridView.builder(
        itemCount: mCategoryList.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // Send selected category back to the previous screen
              Navigator.pop(context, mCategoryList[index]);
            },
            child: Stack(
              children: <Widget>[
                commonCachedNetworkImage(
                  mCategoryList[index].image,
                  fit: BoxFit.cover,
                  width: context.width(),
                  height: context.height(),
                ).cornerRadiusWithClipRRect(16),
                Container(
                  alignment: Alignment.center,
                  width: context.width(),
                  height: context.height(),
                  color: black.withAlpha(
                      (255 * 0.5).toInt()), // Equivalent to .withOpacity(0.5)
                  child: Text(
                    mCategoryList[index].name,
                    style: boldTextStyle(color: white),
                  ),
                ).cornerRadiusWithClipRRect(16),
              ],
            ),
          );
        },
      ),
    );
  }
}
