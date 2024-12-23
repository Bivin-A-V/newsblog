import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/model/NBModel.dart';

import 'package:newsblog/screen/NBLanguageScreen.dart';

import 'package:newsblog/utils/NBImages.dart';

String details =
    'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
    'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s,'
    ' when an unknown printer took a galley of type and scrambled it to make a type specimen book. '
    'It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. '
    'It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing '
    'software like Aldus PageMaker including versions of Lorem Ipsum.\n\n'
    'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
    'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s,'
    ' when an unknown printer took a galley of type and scrambled it to make a type specimen book. '
    'It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. '
    'It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing '
    'software like Aldus PageMaker including versions of Lorem Ipsum.\n\n'
    'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
    'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s,'
    ' when an unknown printer took a galley of type and scrambled it to make a type specimen book. '
    'It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. '
    'It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing '
    'software like Aldus PageMaker including versions of Lorem Ipsum.';

List<NBBannerItemModel> nbGetBannerItems() {
  List<NBBannerItemModel> bannerList = [];
  bannerList.add(NBBannerItemModel(image: NBNewsImage1));
  bannerList.add(NBBannerItemModel(image: NBNewsImage2));
  bannerList.add(NBBannerItemModel(image: NBNewsImage3));
  return bannerList;
}

List<NBDrawerItemModel> nbGetDrawerItems() {
  List<NBDrawerItemModel> drawerItems = [];
  drawerItems.add(NBDrawerItemModel(title: 'Home'));
  drawerItems.add(NBDrawerItemModel(title: 'Audio'));
  drawerItems.add(NBDrawerItemModel(title: 'Create New Article'));
  drawerItems.add(NBDrawerItemModel(title: 'Bookmark'));
  drawerItems.add(NBDrawerItemModel(title: 'Membership'));
  drawerItems.add(NBDrawerItemModel(title: 'Setting'));
  return drawerItems;
}

List<NBNewsDetailsModel> nbGetNewsDetails() {
  List<NBNewsDetailsModel> newsDetailsList = [];
  newsDetailsList.add(NBNewsDetailsModel(
    categoryName: 'Sports',
    title: 'NHL roundup: Mika Zibanejad\'s record night powers Rangers',
    date: '20 jan 2021',
    image: NBSportSNews1,
    details: details,
    time: '40:18',
    isBookmark: true,
  ));
  newsDetailsList.add(NBNewsDetailsModel(
    categoryName: 'Technology',
    title:
        'Amazfit T-Rex Pro review: This fitness watch is in a league of its own',
    date: '20 jan 2021',
    image: NBTechNews1,
    details: details,
    time: '1:40:18',
  ));
  newsDetailsList.add(NBNewsDetailsModel(
    categoryName: 'Fashion',
    title:
        'Amazfit T-Rex Pro review: This fitness watch is in a league of its own',
    date: '20 jan 2021',
    image: NBTechNews1,
    details: details,
    time: '40:00',
    isBookmark: true,
  ));
  newsDetailsList.add(NBNewsDetailsModel(
    categoryName: 'Science',
    title: 'NHL roundup: Mika Zibanejad\'s record night powers Rangers',
    date: '20 jan 2021',
    image: NBSportSNews1,
    details: details,
    time: '15:00',
    isBookmark: true,
  ));
  newsDetailsList.add(NBNewsDetailsModel(
    categoryName: 'Sports',
    title: 'Spring training roundup: Braves get past Rays',
    date: '20 Nov 2020',
    image: NBSportSNews2,
    details: details,
    time: '1:9:30',
  ));
  newsDetailsList.add(NBNewsDetailsModel(
    categoryName: 'Technology',
    title:
        'Micromax In 1 review: Clean software gives this budget smartphone an edge',
    date: '20 Nov 2020',
    image: NBTechNews2,
    details: details,
    time: '1:9:30',
    isBookmark: true,
  ));
  newsDetailsList.add(NBNewsDetailsModel(
    categoryName: 'Fashion',
    title:
        'Micromax In 1 review: Clean software gives this budget smartphone an edge',
    date: '20 Nov 2020',
    image: NBTechNews2,
    details: details,
    time: '40:00',
  ));
  newsDetailsList.add(NBNewsDetailsModel(
    categoryName: 'Science',
    title: 'Spring training roundup: Braves get past Rays',
    date: '20 Nov 2020',
    image: NBSportSNews2,
    details: details,
    time: '20:00',
  ));
  return newsDetailsList;
}

List<NBSettingsItemModel> nbGetSettingItems() {
  List<NBSettingsItemModel> settingList = [];
  settingList.add(NBSettingsItemModel(title: 'Language'));
  settingList.add(NBSettingsItemModel(title: 'Edit Profile'));
  settingList.add(NBSettingsItemModel(title: 'Change Password'));
  settingList.add(NBSettingsItemModel(title: 'Notification Setting'));
  settingList.add(NBSettingsItemModel(title: 'Help and Support'));
  settingList.add(NBSettingsItemModel(title: 'Terms and Conditions'));
  return settingList;
}

List<NBLanguageItemModel> nbGetLanguageItems() {
  List<NBLanguageItemModel> languageList = [];
  languageList
      .add(NBLanguageItemModel(NBEnglishFlag, 'English', 'en', 'en-US'));
  languageList.add(NBLanguageItemModel(NBMelayuFlag, 'Malay', 'ms', 'en-US'));
  languageList.add(NBLanguageItemModel(NBSpainFlag, 'Spanish', 'es', 'es-ES'));
  languageList.add(NBLanguageItemModel(NBFrenchFlag, 'French', 'fr', 'fr-FR'));
  languageList
      .add(NBLanguageItemModel(NBChineseFlag, 'Chinese', 'zh', 'zh-CN'));
  return languageList;
}

List<NBNotificationItemModel> nbGetNotificationItems() {
  List<NBNotificationItemModel> notificationList = [];
  notificationList.add(NBNotificationItemModel('App Notification', true));
  notificationList.add(NBNotificationItemModel('Recommended Article', true));
  notificationList.add(NBNotificationItemModel('Promotion', false));
  notificationList.add(NBNotificationItemModel('Latest News', true));
  return notificationList;
}

List<NBCategoryItemModel> nbGetCategoryItems() {
  List<NBCategoryItemModel> categoryList = [];
  categoryList.add(NBCategoryItemModel(NBTechnologyCategory, 'Technology'));
  categoryList.add(NBCategoryItemModel(NBFashionCategory, 'Fashion'));
  categoryList.add(NBCategoryItemModel(NBSportsCategory, 'Sports'));
  categoryList.add(NBCategoryItemModel(NBScienceCategory, 'Science'));
  return categoryList;
}

List<NBMembershipPlanItemModel> nbGetMembershipPlanItems() {
  List<NBMembershipPlanItemModel> planList = [];
  planList
      .add(NBMembershipPlanItemModel('Monthly', '₹499', 'Billed every month'));
  planList.add(
      NBMembershipPlanItemModel('Yearly', '\₹299/month', 'Billed every month'));
  return planList;
}

List<NBFollowersItemModel> nbGetFollowers() {
  List<NBFollowersItemModel> followersList = [];
  followersList.add(NBFollowersItemModel(NBProfileImage, 'Jones Hawkins', 13));
  followersList
      .add(NBFollowersItemModel(NBProfileImage, 'Frederick Rodriquez', 8));
  followersList.add(NBFollowersItemModel(NBProfileImage, 'John Jordan', 37));
  followersList
      .add(NBFollowersItemModel(NBProfileImage, 'Cameron Williamson', 16));
  followersList.add(NBFollowersItemModel(NBProfileImage, 'Cody Fisher', 13));
  followersList.add(NBFollowersItemModel(NBProfileImage, 'Carla Hamilton', 21));
  followersList
      .add(NBFollowersItemModel(NBProfileImage, 'Fannie Townsend', 25));
  followersList.add(NBFollowersItemModel(NBProfileImage, 'Viola Lloyd', 13));
  return followersList;
}

List<NBCommentItemModel> nbGetCommentList() {
  List<NBCommentItemModel> commentList = [];
  commentList.add(NBCommentItemModel(
    image: NBProfileImage,
    name: 'Jones Hawkins',
    date: 'Jan 18,2021',
    time: '12:15',
    message: 'This is Very Helpful,Thank You.',
  ));
  commentList.add(NBCommentItemModel(
    image: NBProfileImage,
    name: 'Frederick Rodriquez',
    date: 'Jan 19,2021',
    time: '01:15',
    message: 'This is very Important for me,Thank You.',
  ));
  commentList.add(NBCommentItemModel(
    image: NBProfileImage,
    name: 'John Jordan',
    date: 'Feb 18,2021',
    time: '03:15',
    message: 'This is Very Helpful,Thank You.',
  ));
  commentList.add(NBCommentItemModel(
    image: NBProfileImage,
    name: 'Cameron Williamson',
    date: 'Jan 21,2021',
    time: '12:15',
    message: 'This is very Important for me,Thank You.',
  ));
  commentList.add(NBCommentItemModel(
    image: NBProfileImage,
    name: 'Cody Fisher',
    date: 'Jan 28,2021',
    time: '12:15',
    message: 'This is very helpful,thanks',
  ));
  return commentList;
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(
        id: 1,
        name: 'English',
        languageCode: 'en',
        fullLanguageCode: 'en-US',
        flag: 'images/flag/ic_us.png'),
    LanguageDataModel(
        id: 2,
        name: 'Hindi',
        languageCode: 'hi',
        fullLanguageCode: 'hi-IN',
        flag: 'images/flag/ic_hi.png'),
    LanguageDataModel(
        id: 3,
        name: 'Arabic',
        languageCode: 'ar',
        fullLanguageCode: 'ar-AR',
        flag: 'images/flag/ic_ar.png'),
    LanguageDataModel(
        id: 4,
        name: 'French',
        languageCode: 'fr',
        fullLanguageCode: 'fr-FR',
        flag: 'images/flag/ic_fr.png'),
  ];
}
