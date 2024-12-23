import 'package:flutter/material.dart';
import 'package:newsblog/utils/NBColors.dart';

class NBHelpAndSupportScreen extends StatelessWidget {
  const NBHelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NBPrimaryColor,
        title: const Text('Help and Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Welcome to Help and Support!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'If you are facing issues with the app, here are some steps you can follow:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '1. Check your internet connection.\n'
              '2. Restart the app.\n'
              '3. Contact our support team via the email below if the issue persists.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Contact Us:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Email: support@newsapp.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: +1-800-123-4567',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
