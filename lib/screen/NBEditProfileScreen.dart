import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/utils/NBImages.dart';
import 'package:newsblog/utils/NBWidgets.dart';
import 'package:newsblog/utils/user_state.dart';

class NBEditProfileScreen extends StatefulWidget {
  static String tag = '/NBEditProfileScreen';

  const NBEditProfileScreen({super.key});

  @override
  NBEditProfileScreenState createState() => NBEditProfileScreenState();
}

class NBEditProfileScreenState extends State<NBEditProfileScreen> {
  TextEditingController userNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();

  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  File? imageFile;

  Future<void> getImage() async {
    // Directly open the image picker without asking for permission
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        userState.profileImage = imageFile;
        userState.profileImageUrl =
            null; // Reset URL when a new image is uploaded
      });
    } else {
      toasty(context, 'No image selected');
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the text fields with user state data
    userNameCont.text = userState.name;
    emailCont.text = userState.email;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void saveProfile() {
    userState.name = userNameCont.text;
    userState.email = emailCont.text;
    toasty(context, 'Profile updated Successfully');
    finish(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: nbAppBarWidget(context, title: 'Edit Profile'),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  imageFile != null
                      ? Image.file(imageFile!,
                              fit: BoxFit.cover, width: 100, height: 100)
                          .cornerRadiusWithClipRRect(50)
                      : Image.asset(NBProfileImage,
                              fit: BoxFit.cover, width: 100, height: 100)
                          .cornerRadiusWithClipRRect(50),
                  8.height,
                  Text(
                    'Upload Image',
                    style: boldTextStyle(),
                  ).onTap(() {
                    getImage(); // Directly open the image picker
                  }),
                ],
              ),
            ),
            16.height,
            nbAppTextFieldWidget(
              userNameCont,
              'Edit Username',
              TextFieldType.OTHER,
              focus: userNameFocus,
              nextFocus: emailFocus,
            ),
            16.height,
            nbAppTextFieldWidget(
              emailCont,
              'Change Email',
              TextFieldType.EMAIL,
              focus: emailFocus,
            ),
            16.height,
            nbAppButtonWidget(
              context,
              'Save',
              () {
                saveProfile();
              },
            )
          ],
        ).paddingAll(16),
      ),
    );
  }
}
