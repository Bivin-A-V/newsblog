import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/screen/NBDashboardScreen.dart';
import 'package:newsblog/utils/NBWidgets.dart';

class NBEditProfileScreen extends StatefulWidget {
  const NBEditProfileScreen({super.key});

  @override
  NBEditProfileScreenState createState() => NBEditProfileScreenState();
}

class NBEditProfileScreenState extends State<NBEditProfileScreen> {
  final TextEditingController userNameCont = TextEditingController();
  final TextEditingController currentEmailCont = TextEditingController();
  File? imageFile;
  String? profileImageUrl;

  final ValueNotifier<bool> obscureTextNotifier = ValueNotifier(true);
  FocusNode passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          userNameCont.text = data?['name'] ?? '';
          currentEmailCont.text = user.email ?? '';
          profileImageUrl = data?['profileImageUrl'] ?? null;
          setState(() {});
        }
      }
    } catch (e) {
      toast('Error fetching user data: $e');
    }
  }

  // Upload image to Cloudinary and return the URL
  Future<String?> uploadImageToCloudinary(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/daowmjqmw/image/upload'),
      );
      request.fields['upload_preset'] = 'user_image'; // Cloudinary preset
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return json['secure_url']; // Returning the URL of the uploaded image
      } else {
        toast('Failed to upload image');
      }
    } catch (e) {
      toast('Error uploading image: $e');
    }
    return null;
  }

  // Check if email is verified and prompt for new email if valid
  Future<void> saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        toast('User not logged in');
        return;
      }

      // Update profile image if a new one is selected
      if (imageFile != null) {
        final imageUrl = await uploadImageToCloudinary(imageFile!);
        if (imageUrl != null) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .update({
            'profileImageUrl': imageUrl, // Save URL in Firestore
          });
          profileImageUrl = imageUrl; // Update local image URL

          // Show a success toast
          toast('Profile image updated successfully!');
        }
      }

      // Update username if changed
      if (userNameCont.text.trim().isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'name': userNameCont.text.trim(),
        });
      }
      // Delay to allow Firestore updates to settle
      await Future.delayed(Duration(milliseconds: 500));

      toast('Profile saved successfully!');
    } catch (e) {
      toast('Error saving profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 50,
              backgroundImage: imageFile != null
                  ? FileImage(imageFile!) // Display selected image
                  : profileImageUrl != null
                      ? NetworkImage(profileImageUrl!) // Display Cloudinary URL
                      : const AssetImage('images/placeholder.jpg')
                          as ImageProvider,
            ),
            TextButton(
              onPressed: () async {
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    imageFile = File(pickedFile.path); // Update selected image
                  });
                }
              },
              child: const Text('Change Profile Picture'),
            ),
            16.height,
            // Username Field
            nbAppTextFieldWidget(
              userNameCont,
              'Edit Username',
              TextFieldType.NAME,
            ),
            16.height,
            // Current Email Field
            nbAppTextFieldWidget(
              currentEmailCont,
              'Current Email',
              TextFieldType.EMAIL,
            ),
            16.height,
            // Save Button
            ElevatedButton(
              onPressed: saveProfile,
              child: const Text('Save Changes'),
            ),
          ],
        ).paddingAll(16),
      ),
    );
  }
}
