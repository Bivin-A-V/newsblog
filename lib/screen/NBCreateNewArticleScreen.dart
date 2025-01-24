import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/screen/NBAudioArticleScreen.dart';
import 'package:newsblog/screen/NBHomeScreen.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBDottedBorder.dart';
import 'package:newsblog/utils/NBWidgets.dart';
import 'package:newsblog/screen/NBCategoryScreen.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:newsblog/services/database.dart';
import 'package:random_string/random_string.dart';

class NBCreateNewArticleScreen extends StatefulWidget {
  @override
  _NBCreateNewArticleScreenState createState() =>
      _NBCreateNewArticleScreenState();
}

class _NBCreateNewArticleScreenState extends State<NBCreateNewArticleScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController articleController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  bool isAudioArticle = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
  }

  Future<String?> _getUserName() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['name'];
      }
    }
    return null;
  }

  Future<void> _navigateAndSelectCategory() async {
    final selectedCategory = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NBCategoryScreen()),
    );

    if (selectedCategory != null) {
      setState(() {
        categoryController.text = selectedCategory.name;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _publishArticle() async {
    if (titleController.text.isEmpty ||
        articleController.text.isEmpty ||
        categoryController.text.isEmpty ||
        selectedImage == null) {
      toasty(context, 'Please fill in all required fields.');
      return;
    }

    String id = randomAlphaNumeric(10);
    String? imageUrl;

    imageUrl = await DataBaseHelper().uploadImageToCloudinary(selectedImage!);

    if (imageUrl == null) {
      toasty(context, 'Failed to upload image. Try again.');
      return;
    }

    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String? userName = await _getUserName();
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userName == null || userId == null) {
      toasty(context, 'Failed to fetch user details.');
      return;
    }

    Map<String, dynamic> articleInfoMap = {
      "Title": titleController.text,
      "Description": articleController.text,
      "Category": categoryController.text,
      "imageUrl": imageUrl,
      "date": currentDate,
      "sourceName": userName,
      "authorId": userId,
      "isAudioArticle": isAudioArticle,
    };

    await DataBaseHelper()
        .addArticleDetails(userId, articleInfoMap, id)
        .then((_) async {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'articles': FieldValue.increment(1),
      }).then((_) {
        Fluttertoast.showToast(
          msg: "Article has been added!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        if (isAudioArticle) {
          finish(context, NBAudioArticleScreen());
        } else {
          Navigator.pop(context);
        }
      }).catchError((error) {
        log('Failed to increment articles count: $error');
      });
    }).catchError((error) {
      toasty(context, 'Failed to save article. Try again.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: nbAppBarWidget(context, title: 'Create New Article'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            16.height,
            GestureDetector(
              onTap: _pickImage,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(8.0),
                child: SizedBox(
                  height: 120,
                  child: selectedImage != null
                      ? Image.file(selectedImage!, fit: BoxFit.cover)
                          .cornerRadiusWithClipRRect(8)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(Icons.image_outlined),
                            8.width,
                            Text('Add Article Cover', style: boldTextStyle()),
                          ],
                        ),
                ),
              ),
            ),
            16.height,
            Text('Title', style: boldTextStyle()),
            8.height,
            nbAppTextFieldWidget(
              titleController,
              'Write a Title',
              TextFieldType.OTHER,
            ),
            16.height,
            Text('Write Article', style: boldTextStyle()),
            8.height,
            TextFormField(
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textAlign: TextAlign.left,
              controller: articleController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 8),
                filled: true,
                fillColor: grey.withAlpha(25),
                hintText: 'Write Something here',
                hintStyle: secondaryTextStyle(),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Audio Article', style: boldTextStyle()),
                Switch(
                  activeColor: NBPrimaryColor,
                  value: isAudioArticle,
                  onChanged: (value) {
                    setState(() {
                      isAudioArticle = value;
                    });
                  },
                ),
              ],
            ),
            16.height,
            Text('Categories', style: boldTextStyle()),
            8.height,
            GestureDetector(
              onTap: _navigateAndSelectCategory,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: grey.withAlpha(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryController.text.isNotEmpty
                          ? categoryController.text
                          : 'Select Categories',
                      style: boldTextStyle(),
                    ),
                    const Icon(Icons.arrow_forward_ios_outlined, size: 20),
                  ],
                ),
              ),
            ),
            16.height,
            Center(
              child: OutlinedButton(
                child: const Text(
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: NBPrimaryColor),
                    'Publish'),
                onPressed: _publishArticle,
              ),
            ),
            16.height,
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }
}
