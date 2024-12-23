import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/model/news_model.dart';
import 'package:newsblog/screen/NBAudioArticleScreen.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBDottedBorder.dart';
import 'package:newsblog/utils/NBWidgets.dart';
import 'package:newsblog/screen/NBCategoryScreen.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:newsblog/utils/user_state.dart';

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

  void _publishArticle() {
    if (titleController.text.isEmpty ||
        articleController.text.isEmpty ||
        categoryController.text.isEmpty ||
        selectedImage == null) {
      toasty(context, 'Please fill in all required fields.');
      return;
    }

    final newArticle = NewsModel(
      category: categoryController.text,
      title: titleController.text,
      imageUrl: selectedImage!.path,
      publishedAt: DateFormat('dd/MM/yy').format(DateTime.now()),
      description: articleController.text,
      sourceName: userState.name,
    );
    // Increment articles count
    setState(() {
      userState.articles++;
      userState.createdArticles.add(newArticle);
    });

    if (isAudioArticle) {
      // Navigate to NBAudioArticleScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NBAudioArticleScreen(
            newAudioArticle: newArticle,
          ),
        ),
      );
    } else {
      // Navigate to NBHomeScreen (replace with appropriate navigation logic)
      Navigator.pop(context, newArticle);
    }
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
            16.height, // Space between the title and description fields

            // Description text field (for writing the content of the article)
            Text('Write Article',
                style: boldTextStyle()), // Add the label "Write Article"
            8.height, // Space between label and text field

            TextFormField(
              maxLines: 8, // Allow multiple lines
              keyboardType: TextInputType.multiline, // Multi-line keyboard
              textAlign: TextAlign.left, // Left aligned text

              // Optional: Add a controller if you need to capture the value
              controller:
                  articleController, // Assuming you have a TextEditingController
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 8),
                filled: true,
                fillColor: grey.withAlpha(25),
                hintText:
                    'Write Something here', // Hint text for the description
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
            nbAppButtonWidget(
              context,
              'Publish',
              _publishArticle,
            ),
            16.height,
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }
}
