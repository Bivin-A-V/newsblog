import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/main.dart';
import 'package:newsblog/utils/NBColors.dart';

class NBLanguageScreen extends StatefulWidget {
  static String tag = '/NBLanguageScreen';

  const NBLanguageScreen({super.key});

  @override
  NBLanguageScreenState createState() => NBLanguageScreenState();
}

class NBLanguageScreenState extends State<NBLanguageScreen> {
  final List<Map<String, String>> languages = [
    {'name': 'English', 'locale': 'en_US'},
    {'name': 'Chinese', 'locale': 'zh_CN'},
    {'name': 'French', 'locale': 'fr_FR'},
    {'name': 'Malay', 'locale': 'ms_MY'},
    {'name': 'Spanish', 'locale': 'es_ES'},
  ];

  String selectedLocale = 'en_US';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure you handle context-dependent operations here
    selectedLocale = context.locale.toString(); // Set the current locale
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: appStore.isDarkModeOn ? white : black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('select_language'.tr(), style: boldTextStyle(size: 20)),
        backgroundColor: context.cardColor,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: languages.length,
        itemBuilder: (_, index) {
          final language = languages[index];
          final isSelected = selectedLocale == language['locale'];

          return Row(
            children: [
              Text(language['name']!, style: primaryTextStyle()).expand(),
              if (isSelected)
                Checkbox(
                  value: true,
                  onChanged: (value) {},
                  activeColor: NBPrimaryColor,
                ),
            ],
          ).paddingOnly(top: 8, bottom: 8).onTap(() {
            setState(() {
              selectedLocale = language['locale']!;
              final localeParts = selectedLocale.split('_');
              context.setLocale(Locale(localeParts[0], localeParts[1]));
            });
          });
        },
      ),
    );
  }
}
