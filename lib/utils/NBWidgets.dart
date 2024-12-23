import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/main.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBImages.dart';
import 'package:url_launcher/url_launcher.dart';

Widget nbAppTextFieldWidget(
  TextEditingController controller,
  String hintText,
  TextFieldType textFieldType, {
  FocusNode? focus,
  FocusNode? nextFocus,
  ValueNotifier<bool>? obscureTextNotifier,
}) {
  return ValueListenableBuilder<bool>(
    valueListenable: obscureTextNotifier ?? ValueNotifier(false),
    builder: (context, obscureText, child) {
      return AppTextField(
        controller: controller,
        textFieldType: textFieldType,
        textStyle: primaryTextStyle(size: 14),
        focus: focus,
        nextFocus: nextFocus,
        textInputAction: TextInputAction.next,
        obscureText:
            textFieldType == TextFieldType.PASSWORD ? obscureText : false,
        decoration: InputDecoration(
            contentPadding:
                EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            filled: true,
            fillColor: grey.withOpacity(0.1),
            hintText: hintText,
            hintStyle: secondaryTextStyle(),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            suffixIcon: textFieldType == TextFieldType.PASSWORD
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      if (obscureTextNotifier != null) {
                        obscureTextNotifier.value = !obscureTextNotifier.value;
                      }
                    })
                : null),
      );
    },
  );
}

Widget nbAppButtonWidget(BuildContext context, String text, Function? onTap) {
  return AppButton(
    text: text,
    textStyle: boldTextStyle(color: white),
    color: NBPrimaryColor,
    onTap: onTap != null ? () => onTap() : null,
    width: context.width(),
  ).cornerRadiusWithClipRRect(20);
}

AppBar nbAppBarWidget(BuildContext context, {String? title}) {
  return AppBar(
    leading: IconButton(
      icon:
          Icon(Icons.arrow_back, color: appStore.isDarkModeOn ? white : black),
      onPressed: () {
        finish(context);
      },
    ),
    title: Text('$title', style: boldTextStyle(size: 20)),
    backgroundColor: context.cardColor,
    centerTitle: true,
  );
}

InputDecoration nbInputDecoration(BuildContext context,
    {String? hintText, Widget? prefixIcon}) {
  return InputDecoration(
    contentPadding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
    filled: true,
    fillColor: grey.withOpacity(0.1),
    hintText: hintText,
    hintStyle: secondaryTextStyle(),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    prefixIcon: prefixIcon,
  );
}

Future<void> launchURL(String url, {bool forceWebView = false}) async {
  await launch(url, enableJavaScript: true, forceWebView: forceWebView)
      .catchError(
    (e) {
      throw '$url is not valid';
    },
  );
}

Widget commonCachedNetworkImage(
  String? url, {
  double? height,
  double? width,
  BoxFit? fit,
  AlignmentGeometry? alignment,
  bool usePlaceholderIfUrlEmpty = true,
  double? radius,
  Color? color,
}) {
  if (url!.validate().isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
      placeholder: (context, url) {
        Image.asset(NBPlaceholderImage);
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
    );
  } else {
    return Image.asset(url,
            height: height,
            width: width,
            fit: fit,
            alignment: alignment ?? Alignment.center)
        .cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget(
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    double? radius}) {
  return Image.asset('images/placeholder.jpg',
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          alignment: alignment ?? Alignment.center)
      .cornerRadiusWithClipRRect(radius ?? defaultRadius);
}
