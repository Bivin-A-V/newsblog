import 'dart:io';

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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? profileImageUrl;
  String? name;

  @override
  void initState() {
    super.initState();
    _listenToUserProfileChanges();
  }

  // Listen to real-time updates from Firestore for user profile changes
  void _listenToUserProfileChanges() {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        if (mounted) {
          setState(() {
            name = snapshot.get('name'); // Fetch updated name
            profileImageUrl =
                snapshot.get('profileImageUrl'); // Fetch updated image URL
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              name ?? 'User',
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
                  : const AssetImage('images/placeholder.jpg')
                      as ImageProvider, // Default placeholder image
              child: profileImageUrl == null
                  ? Text(
                      name != null && name!.isNotEmpty
                          ? name![0].toUpperCase()
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
