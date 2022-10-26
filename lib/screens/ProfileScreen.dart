import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import '../component/ThemeSelectionComponent.dart';
import '../utils/app_widgets.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import '../utils/images.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'AboutUsScreen.dart';
import 'BlogListScreen.dart';
import 'ChangePasswordScreen.dart';
import 'DashBoardScreen.dart';
import 'EditProfileScreen.dart';
import 'OfferScreen.dart';
import 'OrderListScreen.dart';
import 'SignInScreen.dart';

class ProfileScreen extends StatefulWidget {
  static String tag = '/ProfileScreen';

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String mProfileImage = '';
  String userName = '';
  String userEmail = '';

  bool mIsLoggedIn = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      mIsLoggedIn = getBoolAsync(IS_LOGGED_IN);
      userName = mIsLoggedIn
          ? '${getStringAsync(FIRST_NAME) + ' ' + getStringAsync(LAST_NAME)}'
          : '';
      userEmail = mIsLoggedIn ? getStringAsync(USER_EMAIL) : '';
      mProfileImage = getStringAsync(PROFILE_IMAGE);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    return Observer(
      builder: (_) => SafeArea(
        top: isIos ? false : true,
        child: Scaffold(
          appBar: mTop(context, appLocalization!.translate('title_account'))
              as PreferredSizeWidget?,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Container(
                  width: context.width(),
                  child: mIsLoggedIn
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            mProfileImage.isNotEmpty
                                ? CircleAvatar(
                                    backgroundColor: context.cardColor,
                                    backgroundImage:
                                        NetworkImage(mProfileImage.validate()),
                                    radius: 50)
                                : CircleAvatar(
                                    backgroundColor: context.cardColor,
                                    backgroundImage:
                                        Image.asset(User_Profile).image,
                                    radius: 50),
                            8.height,
                            Text(userName, style: boldTextStyle())
                                .paddingOnly(top: 2),
                            Text(userEmail,
                                    style: boldTextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .color))
                                .paddingOnly(top: 2),
                          ],
                        )
                          .paddingOnly(left: spacing_control.toDouble())
                          .paddingOnly(
                              left: spacing_standard.toDouble(),
                              right: spacing_standard.toDouble())
                          .onTap(() async {
                          bool? isLoad =
                              await EditProfileScreen().launch(context);
                          log("isLoad" + isLoad.toString());
                          if (isLoad != null) {
                            mProfileImage = getStringAsync(PROFILE_IMAGE);
                            userName = mIsLoggedIn
                                ? '${getStringAsync(FIRST_NAME) + ' ' + getStringAsync(LAST_NAME)}'
                                : '';
                            userEmail =
                                mIsLoggedIn ? getStringAsync(USER_EMAIL) : '';
                          } else {
                            mProfileImage = getStringAsync(PROFILE_IMAGE);
                            userName = mIsLoggedIn
                                ? '${getStringAsync(FIRST_NAME) + ' ' + getStringAsync(LAST_NAME)}'
                                : '';
                            userEmail =
                                mIsLoggedIn ? getStringAsync(USER_EMAIL) : '';
                          }
                          setState(() {});
                        })
                      : Column(
                          children: [
                            Text(appLocalization.translate('msg_Sign_in')!,
                                style: primaryTextStyle(size: 18),
                                textAlign: TextAlign.center),
                            20.height,
                            AppButton(
                                    width: context.width(),
                                    color: primaryColor,
                                    height: 40,
                                    text:
                                        '${appLocalization.translate('lbl_sign_in')}',
                                    onTap: () {
                                      SignInScreen().launch(context);
                                    },
                                    textStyle:
                                        boldTextStyle(size: 18, color: white),
                                    shapeBorder: RoundedRectangleBorder(
                                        borderRadius: radius(8)),
                                    elevation: 0)
                                .paddingOnly(left: 16, right: 16)
                                .visible(!mIsLoggedIn),
                            20.height,
                          ],
                        ),
                ),
                Divider(
                        height: 4,
                        thickness: 12,
                        color: Theme.of(context).textTheme.headline4!.color)
                    .paddingOnly(top: 16, bottom: 8),
                SettingItemWidget(
                    subTitle:
                        "${appLocalization.translate("subtext_guest_user")}",
                    subTitleTextStyle:
                        secondaryTextStyle(color: textSecondaryColor),
                    leading: Icon(FontAwesome.user_o,
                        size: 22, color: textSecondaryColor),
                    padding:
                        EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
                    title: '${appLocalization.translate('lbl_guest_user')}',
                    trailing:
                        Icon(Icons.chevron_right, color: context.iconColor),
                    titleTextStyle: boldTextStyle(),
                    onTap: () async {
                      await setValue(FIRST_NAME, "Guest");
                      await setValue(LAST_NAME, "");
                      await setValue(USER_EMAIL, "Guest@gmail.com");
                      await setValue(USERNAME, "Guest");
                      await setValue(USER_DISPLAY_NAME, "Guest");
                      await setValue(IS_LOGGED_IN, true);
                      await setValue(IS_GUEST_USER, true);
                      await setValue(BILLING, "");
                      await setValue(SHIPPING, "");
                      DashBoardScreen().launch(context, isNewTask: true);
                    }).visible(!mIsLoggedIn),
                Divider(
                        thickness: 1.2,
                        color: Theme.of(context).textTheme.headline4!.color)
                    .visible(!mIsLoggedIn && !getBoolAsync(IS_GUEST_USER)),
                SettingItemWidget(
                  subTitle: "${appLocalization.translate("subtext_order")}",
                  subTitleTextStyle:
                      secondaryTextStyle(color: textSecondaryColor),
                  leading: Icon(SimpleLineIcons.social_dropbox,
                      size: 22, color: textSecondaryColor),
                  padding: mIsLoggedIn && !getBoolAsync(IS_GUEST_USER)
                      ? EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4)
                      : EdgeInsets.zero,
                  title: '${appLocalization.translate('lbl_orders')}',
                  trailing: Icon(Icons.chevron_right, color: context.iconColor),
                  onTap: () {
                    OrderList().launch(context);
                  },
                  titleTextStyle: boldTextStyle(),
                ).visible(mIsLoggedIn && !getBoolAsync(IS_GUEST_USER)),
                Divider(
                        thickness: 1.2,
                        color: Theme.of(context).textTheme.headline4!.color)
                    .visible(mIsLoggedIn && !getBoolAsync(IS_GUEST_USER)),
                /*SettingItemWidget(
                  subTitle: "${appLocalization.translate("lbl_offer_subtext")}",
                  subTitleTextStyle: secondaryTextStyle(color: textSecondaryColor),
                  leading: Icon(AntDesign.gift, size: 24, color: textSecondaryColor),
                  padding: EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 12),
                  title: "${appLocalization.translate("lbl_offer_zone")}",
                  trailing: Icon(Icons.chevron_right, color: context.iconColor),
                  onTap: () {
                    OfferScreen().launch(context);
                  },
                  titleTextStyle: boldTextStyle(),
                ),
                Divider(thickness: 1.2, color: Theme.of(context).textTheme.headline4!.color).visible(mIsLoggedIn && !getBoolAsync(IS_GUEST_USER)),*/
                SettingItemWidget(
                  subTitle: "${appLocalization.translate("subtext_password")}",
                  subTitleTextStyle:
                      secondaryTextStyle(color: textSecondaryColor),
                  leading: Icon(Ionicons.key_outline,
                      size: 24, color: textSecondaryColor),
                  padding:
                      EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
                  title: '${appLocalization.translate('lbl_change_pwd')}',
                  trailing: Icon(Icons.chevron_right, color: context.iconColor),
                  onTap: () {
                    ChangePasswordScreen().launch(context);
                  },
                  titleTextStyle: boldTextStyle(),
                ).visible(mIsLoggedIn && !getBoolAsync(IS_GUEST_USER)),
                Divider(
                    thickness: 1.2,
                    color: Theme.of(context).textTheme.headline4!.color),
                SettingItemWidget(
                  subTitle: "${appLocalization.translate("subtext_blog")}",
                  subTitleTextStyle:
                      secondaryTextStyle(color: textSecondaryColor),
                  leading:
                      Icon(Ionicons.reader_outline, color: textSecondaryColor),
                  padding:
                      EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
                  title: '${appLocalization.translate('lbl_blog')}',
                  trailing: Icon(Icons.chevron_right, color: context.iconColor),
                  onTap: () {
                    BlogListScreen().launch(context);
                  },
                  titleTextStyle: boldTextStyle(),
                ),
                Divider(
                    thickness: 1.2,
                    color: Theme.of(context).textTheme.headline4!.color),
                SettingItemWidget(
                  subTitle: "${appLocalization.translate("subtext_theme")}",
                  subTitleTextStyle:
                      secondaryTextStyle(color: textSecondaryColor),
                  leading: Icon(Ionicons.sunny_outline,
                      size: 26, color: textSecondaryColor),
                  padding:
                      EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
                  title: '${appLocalization.translate('lbl_select_theme')}',
                  onTap: () {
                    showInDialog(
                      context,
                      child: ThemeSelectionComponent(),
                      contentPadding: EdgeInsets.zero,
                      shape: dialogShape(),
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      title: Text(
                          appLocalization.translate('lbl_select_theme')!,
                          style: boldTextStyle(size: 20)),
                    );
                    setState(() {});
                  },
                  titleTextStyle: boldTextStyle(),
                ),
                Divider(
                    thickness: 1.2,
                    color: Theme.of(context).textTheme.headline4!.color),
                SettingItemWidget(
                  subTitle:
                      "${appLocalization.translate("lbl_select_language")}",
                  subTitleTextStyle:
                      secondaryTextStyle(color: textSecondaryColor),
                  leading: Icon(Ionicons.language_outline,
                      color: textSecondaryColor),
                  padding:
                      EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 12),
                  title: "${appLocalization.translate("lbl_select_language")}",
                  trailing: LanguageListWidget(
                    widgetType: WidgetType.DROPDOWN,
                    onLanguageChange: (data) {
                      appStore.setLanguage(data.languageCode!);
                    },
                  ),
                  titleTextStyle: boldTextStyle(),
                ),
                Divider(
                    thickness: 1.2,
                    color: Theme.of(context).textTheme.headline4!.color),
                SettingItemWidget(
                    subTitle:
                        "${appLocalization.translate("subtext_notification")}",
                    subTitleTextStyle:
                        secondaryTextStyle(color: textSecondaryColor),
                    leading: Icon(Ionicons.ios_notifications_outline,
                        color: textSecondaryColor),
                    padding:
                        EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 12),
                    title:
                        '${appStore.isNotificationOn ? appLocalization.translate('disable') : appLocalization.translate('enable')} ${appLocalization.translate('push_notification')}',
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        activeColor: primaryColor,
                        value: appStore.isNotificationOn,
                        onChanged: (v) {
                          appStore.setNotification(v);
                        },
                      ).withHeight(0.5),
                    ),
                    onTap: () {
                      appStore.setNotification(!getBoolAsync(IS_NOTIFICATION_ON,
                          defaultValue: true));
                    },
                    titleTextStyle: boldTextStyle()),
                Divider(
                    thickness: 12,
                    color: Theme.of(context).textTheme.headline4!.color),
                SettingItemWidget(
                  padding:
                      EdgeInsets.only(left: 26, right: 8, top: 12, bottom: 4),
                  title: '${appLocalization.translate('lbl_about')}',
                  trailing: Icon(Icons.chevron_right, color: context.iconColor),
                  onTap: () {
                    // AboutUsScreen().launch(context);
                    redirectUrl('https://romasstore.online/about/');
                  },
                  titleTextStyle: primaryTextStyle(),
                ),
                Divider(
                    thickness: 1.2,
                    color: Theme.of(context).textTheme.headline4!.color),
                /* SettingItemWidget(
                  padding: EdgeInsets.only(left: 26, right: 8, top: 4, bottom: 4),
                  title: '${appLocalization.translate('lbl_terms_conditions')}',
                  trailing: Icon(Icons.chevron_right, color: context.iconColor),
                  onTap: () {
                    redirectUrl(getStringAsync(TERMS_AND_CONDITIONS).isEmptyOrNull ? TERMS_CONDITION_URL : getStringAsync(TERMS_AND_CONDITIONS));
                  },
                  titleTextStyle: primaryTextStyle(),
                ),
                Divider(thickness: 1.2, color: Theme.of(context).textTheme.headline4!.color),*/
                SettingItemWidget(
                  padding:
                      EdgeInsets.only(left: 26, right: 8, top: 4, bottom: 8),
                  title: '${appLocalization.translate('llb_privacy_policy')}',
                  trailing: Icon(Icons.chevron_right, color: context.iconColor),
                  onTap: () {
                    redirectUrl('https://romasstore.online/privacy-policy/');
                  },
                  titleTextStyle: primaryTextStyle(),
                ),
                Divider(
                    thickness: 12,
                    color: Theme.of(context).textTheme.headline4!.color),
                AppButton(
                  width: context.width(),
                  color: context.cardColor,
                  text: '${appLocalization.translate('btn_deleteAccount')}',
                  onTap: () async {
                    await removeAccount(context);
                  },
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: radius(8), side: BorderSide(width: 0.1)),
                  elevation: 0,
                  textStyle: boldTextStyle(size: 18),
                )
                    .paddingOnly(left: 16, right: 16, top: 16)
                    .visible(mIsLoggedIn),
                16.height,
                AppButton(
                  width: context.width(),
                  color: context.cardColor,
                  text: '${appLocalization.translate('btn_sign_out')}',
                  onTap: () async {
                    await logout(context);
                  },
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: radius(8), side: BorderSide(width: 0.1)),
                  elevation: 0,
                  textStyle: boldTextStyle(size: 18),
                )
                    .paddingOnly(left: 16, right: 16, top: 10)
                    .visible(mIsLoggedIn),
                10.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
