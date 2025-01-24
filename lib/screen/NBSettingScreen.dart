import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/main.dart';
import 'package:newsblog/model/NBModel.dart';
import 'package:newsblog/screen/NBLanguageScreen.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBImages.dart';
import 'package:newsblog/utils/NBWidgets.dart';
import 'package:newsblog/screen/NBEditProfileScreen.dart';
import 'package:newsblog/screen/NBChangePasswordScreen.dart';

class NBSettingScreen extends StatefulWidget {
  static String tag = '/NBSettingScreen';

  @override
  NBSettingScreenState createState() => NBSettingScreenState();
}

class NBSettingScreenState extends State<NBSettingScreen> {
  NBLanguageItemModel? result =
      NBLanguageItemModel(NBEnglishFlag, 'English', 'en', 'en-US');

  void updateLanguage(NBLanguageItemModel newLanguage) {
    setState(() {
      result = newLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: nbAppBarWidget(
          context,
          title: ('select_language'.tr()),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            height: 237,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, index) {
                return const Divider();
              },
              itemCount: 3,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return Row(
                    children: [
                      Text('language'.tr(), style: primaryTextStyle()).expand(),
                      Row(
                        children: [
                          commonCachedNetworkImage(result!.image, height: 16),
                          8.width,
                          Text('${result!.name}', style: primaryTextStyle()),
                          const Icon(Icons.navigate_next).paddingAll(8),
                        ],
                      ),
                    ],
                  ).onTap(() async {
                    final selectedLanguage = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NBLanguageScreen()),
                    );
                    if (selectedLanguage is NBLanguageItemModel) {
                      updateLanguage(selectedLanguage);
                    }
                  });
                } else if (index == 1) {
                  return Row(
                    children: [
                      Text('profile'.tr(), style: primaryTextStyle()).expand(),
                      const Icon(Icons.navigate_next).paddingAll(8),
                    ],
                  ).onTap(() {
                    NBEditProfileScreen().launch(context);
                  });
                } else if (index == 2) {
                  return Row(
                    children: [
                      Text('change_password'.tr(), style: primaryTextStyle())
                          .expand(),
                      const Icon(Icons.navigate_next).paddingAll(8),
                    ],
                  ).onTap(() {
                    NBChangePasswordScreen().launch(context);
                  });
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('dark_mode'.tr(), style: primaryTextStyle())
                  .paddingOnly(left: 16),
              Switch(
                value: appStore.isDarkModeOn,
                activeColor: appColorPrimary,
                onChanged: (s) {
                  appStore.toggleDarkMode(value: s);
                },
              )
            ],
          ).onTap(() {
            appStore.toggleDarkMode();
          }),
        ],
      ),
    );
  }
}
