import 'package:flutter/material.dart';
import 'package:newsblog/utils/NBColors.dart';

class NBTermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NBPrimaryColor,
        title: const Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '1. Introduction\n\n'
              'By using this app, you agree to comply with the terms and conditions set out in this document. '
              'If you do not agree with these terms, please do not use the app.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '2. Use of the App\n\n'
              'You agree to use the app for lawful purposes only. You must not use the app to transmit any harmful material or violate any laws.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '3. Privacy Policy\n\n'
              'We take your privacy seriously. Please refer to our Privacy Policy to understand how we collect and use your data.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '4. Modifications\n\n'
              'We reserve the right to modify or discontinue the app at any time without prior notice.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '5. Limitation of Liability\n\n'
              'We are not liable for any damages resulting from the use of the app, including but not limited to loss of data or interruption of service.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '6. Contact Us\n\n'
              'If you have any questions regarding these terms, please contact us at support@newsapp.com.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
