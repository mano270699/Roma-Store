import 'package:RomaStore/utils/app_widgets.dart';
import 'package:RomaStore/utils/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_localizations.dart';
import '../main.dart';
import '../screens/DashBoardScreen.dart';
import '../screens/MyCartScreen.dart';
import '../screens/SignInScreen.dart';
import 'colors.dart';
import 'constants.dart';

String convertDate(date) {
  try {
    return date != null
        ? DateFormat(orderDateFormat).format(DateTime.parse(date))
        : '';
  } catch (e) {
    log(e);
    return '';
  }
}

String createDateFormat(date) {
  try {
    return date != null
        ? DateFormat(CreateDateFormat).format(DateTime.parse(date))
        : '';
  } catch (e) {
    log(e);
    return '';
  }
}

String reviewConvertDate(date) {
  try {
    return date != null
        ? DateFormat(reviewDateFormat).format(DateTime.parse(date))
        : '';
  } catch (e) {
    log(e);
    return '';
  }
}

void redirectUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    toast('Please check URL');
    throw 'Could not launch $url';
  }
}

Future<bool> checkLogin(context) async {
  if (!await isLoggedIn()) {
    SignInScreen().launch(context);
    return false;
  } else {
    return true;
  }
}

removeAccount(BuildContext context) async {
  ConfirmAction? res = await showConfirmDialogs(
    context,
    AppLocalizations.of(context)!.translate('msg_deletation'),
    AppLocalizations.of(context)!.translate('lbl_yes'),
    AppLocalizations.of(context)!.translate('lbl_cancel'),
  );

  if (res == ConfirmAction.ACCEPT) {
    FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
    var primaryColor = getStringAsync(THEME_COLOR);
    await setValue(THEME_COLOR, primaryColor);

    await removeKey(PROFILE_IMAGE);
    await removeKey(BILLING);
    await removeKey(SHIPPING);
    await removeKey(USERNAME);
    if (getBoolAsync(IS_SOCIAL_LOGIN) || !getBoolAsync(IS_REMEMBERED)) {
      await removeKey(PASSWORD);
      await removeKey(USER_EMAIL);
    }
    await removeKey(FIRST_NAME);
    await removeKey(LAST_NAME);
    await removeKey(TOKEN);
    await removeKey(USER_DISPLAY_NAME);
    await removeKey(USER_ID);
    await removeKey(AVATAR);
    await removeKey(COUNTRIES);
    await removeKey(CART_DATA);
    await removeKey(WISH_LIST_DATA);
    await removeKey(GUEST_USER_DATA);
    await removeKey(CARTCOUNT);
    await removeKey(DEFAULT_CURRENCY);
    await removeKey(CURRENCY_CODE);
    await removeKey(CURRENCY_CODE);
    await setValue(IS_GUEST_USER, false);
    await setValue(IS_LOGGED_IN, false);
    await setValue(IS_SOCIAL_LOGIN, false);
    appStore.setCount(0);

    DashBoardScreen().launch(context, isNewTask: true);
  }
}

Future logout(BuildContext context) async {
  ConfirmAction? res = await showConfirmDialogs(
    context,
    AppLocalizations.of(context)!.translate('lbl_logout'),
    AppLocalizations.of(context)!.translate('lbl_yes'),
    AppLocalizations.of(context)!.translate('lbl_cancel'),
  );
  if (res == ConfirmAction.ACCEPT) {
    var primaryColor = getStringAsync(THEME_COLOR);
    await setValue(THEME_COLOR, primaryColor);

    await removeKey(PROFILE_IMAGE);
    await removeKey(BILLING);
    await removeKey(SHIPPING);
    await removeKey(USERNAME);
    if (getBoolAsync(IS_SOCIAL_LOGIN) || !getBoolAsync(IS_REMEMBERED)) {
      await removeKey(PASSWORD);
      await removeKey(USER_EMAIL);
    }
    await removeKey(FIRST_NAME);
    await removeKey(LAST_NAME);
    await removeKey(TOKEN);
    await removeKey(USER_DISPLAY_NAME);
    await removeKey(USER_ID);
    await removeKey(AVATAR);
    await removeKey(COUNTRIES);
    await removeKey(CART_DATA);
    await removeKey(WISH_LIST_DATA);
    await removeKey(GUEST_USER_DATA);
    await removeKey(CARTCOUNT);
    await removeKey(DEFAULT_CURRENCY);
    await removeKey(CURRENCY_CODE);
    await removeKey(CURRENCY_CODE);
    await setValue(IS_GUEST_USER, false);
    await setValue(IS_LOGGED_IN, false);
    await setValue(IS_SOCIAL_LOGIN, false);
    appStore.setCount(0);

    DashBoardScreen().launch(context, isNewTask: true);
  }
}

checkLoggedIn(context) async {
  var pref = await getSharedPref();
  if (pref.getBool(IS_LOGGED_IN) != null && pref.getBool(IS_LOGGED_IN)!) {
    MyCartScreen(isShowBack: true).launch(context);
  } else {
    SignInScreen().launch(context);
  }
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

InputDecoration inputDecoration(BuildContext context,
    {String? hint, Widget? prefixIcon}) {
  return InputDecoration(
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: appStore.isDarkMode! ? whiteColor : primaryColor!,
        )),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: viewLineColor)),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: viewLineColor)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: greyColor.withOpacity(0.7))),
    labelText: hint,
    hintStyle: secondaryTextStyle(size: 16),
    labelStyle: primaryTextStyle(),
    contentPadding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
    prefixIcon: prefixIcon,
  );
}

List<LanguageDataModel> getLanguages() {
  return <LanguageDataModel>[
    LanguageDataModel(
      id: 0,
      name: 'English',
      languageCode: 'en',
    ),
    LanguageDataModel(id: 1, name: 'Afrikaans', languageCode: 'af'),
    LanguageDataModel(id: 2, name: 'Arabic', languageCode: 'ar'),
    LanguageDataModel(id: 3, name: 'Chinese', languageCode: 'zh'),
    LanguageDataModel(id: 4, name: 'Dutch', languageCode: 'nl'),
    LanguageDataModel(id: 5, name: 'French', languageCode: 'fr'),
    LanguageDataModel(id: 6, name: 'German', languageCode: 'de'),
    LanguageDataModel(id: 7, name: 'Hebrew', languageCode: 'he'),
    LanguageDataModel(id: 8, name: 'Hindi', languageCode: 'hi'),
    LanguageDataModel(id: 9, name: 'Italian', languageCode: 'it'),
    LanguageDataModel(id: 10, name: 'Japanese', languageCode: 'ja'),
    LanguageDataModel(id: 11, name: 'Korean', languageCode: 'ko'),
    LanguageDataModel(id: 12, name: 'Nepali', languageCode: 'ne'),
    LanguageDataModel(id: 13, name: 'Portuguese', languageCode: 'pt'),
    LanguageDataModel(id: 14, name: 'Romanian', languageCode: 'ro'),
    LanguageDataModel(id: 15, name: 'Spanish', languageCode: 'es'),
    LanguageDataModel(id: 16, name: 'Thai', languageCode: 'th'),
    LanguageDataModel(id: 17, name: 'Turkish', languageCode: 'tr'),
    LanguageDataModel(id: 18, name: 'Vietnamese', languageCode: 'vi'),
  ];
}
