import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/screen/NBAudioArticleScreen.dart';
import 'package:newsblog/screen/NBBookmarkScreen.dart';
import 'package:newsblog/screen/NBCreateNewArticleScreen.dart';
import 'package:newsblog/screen/NBHelpAndSupportScreen.dart';
import 'package:newsblog/screen/NBMembershipScreen.dart';
import 'package:newsblog/screen/NBProfileScreen.dart';
import 'package:newsblog/screen/NBSettingScreen.dart';
import 'package:newsblog/screen/NBSignoutScreen.dart';
import 'package:newsblog/screen/NBTermsAndConditionsScreen.dart';
import 'package:newsblog/utils/user_state.dart';

class AppDrawer extends StatelessWidget {
  final String? profileImageUrl;
  AppDrawer(this.profileImageUrl);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userState.name.isNotEmpty ? userState.name : userState.signupName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: GestureDetector(
              onTap: () {
                const NBProfileScreen().launch(context);
              },
              child: Text(
                'view_profile'.tr(),
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blue,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : (userState.profileImage != null
                      ? FileImage(userState.profileImage!)
                      : null),
              child: profileImageUrl == null && userState.profileImage == null
                  ? Text(
                      userState.name.isNotEmpty
                          ? userState.name[0].toUpperCase()
                          : 'NB',
                      style:
                          const TextStyle(fontSize: 20.0, color: Colors.white),
                    )
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('home'.tr()),
            onTap: () {
              finish(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack),
            title: Text('audio_article'.tr()),
            onTap: () {
              const NBAudioArticleScreen().launch(context);
            },
          ),
          ListTile(
              leading: const Icon(Icons.article),
              title: Text('create_new_article'.tr()),
              onTap: () async {
                NBCreateNewArticleScreen().launch(context);
              }),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text('bookmark'.tr()),
            onTap: () {
              NBBookmarkScreen().launch(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_membership),
            title: Text('membership'.tr()),
            onTap: () {
              NBMembershipScreen().launch(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('settings'.tr()),
            onTap: () {
              NBSettingScreen().launch(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy_rounded),
            title: Text('terms_and_conditions'.tr()),
            onTap: () {
              NBTermsAndConditionsScreen().launch(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_mark_rounded),
            title: Text('help_and_support'.tr()),
            onTap: () {
              const NBHelpAndSupportScreen().launch(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('logout'.tr()),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
