import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../screens/SplashScreen.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'AppTheme.dart';
import 'Store/AppStore.dart';
import 'app_localizations.dart';
import 'model/BuilderResponse.dart';

BuilderResponse builderResponse = BuilderResponse();
Color? primaryColor;
Color? colorAccent;
Color? textPrimaryColour;
Color? textSecondaryColour;
Color? backgroundColor;
String? baseUrl;
String? consumerKey;
String? consumerSecret;
AppStore appStore = AppStore();
int mAdShowCount = 0;

Future<String> loadBuilderData() async {
  return await rootBundle.loadString('assets/woobox.json');
}

Future<BuilderResponse> loadContent() async {
  String jsonString = await loadBuilderData();
  final jsonResponse = json.decode(jsonString);
  return BuilderResponse.fromJson(jsonResponse);
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (isMobile) {
    await OneSignal.shared.setAppId(mOneSignalAPPKey);
    OneSignal.shared.consentGranted(true);
    OneSignal.shared.promptUserForPushNotificationPermission();
    // MobileAds.instance.initialize();
    await Firebase.initializeApp();
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  await initialize(aLocaleLanguageList: getLanguages());

  builderResponse = await loadContent();
  setValue(PRIMARY_COLOR, builderResponse.appsetup!.primaryColor!);

  setValue(SECONDARY_COLOR, builderResponse.appsetup!.secondaryColor!);

  setValue(TEXT_PRIMARY_COLOR, builderResponse.appsetup!.textPrimaryColor!);
  setValue(TEXT_SECONDARY_COLOR, builderResponse.appsetup!.textSecondaryColor!);
  setValue(BACKGROUND_COLOR, builderResponse.appsetup!.backgroundColor!);
  setValue(APP_URL, builderResponse.appsetup!.appUrl!);
  setValue(CONSUMER_KEY, builderResponse.appsetup!.consumerKey!);
  setValue(CONSUMER_SECRET, builderResponse.appsetup!.consumerSecret!);

  primaryColor = Colors
      .black; //getColorFromHex(getStringAsync(PRIMARY_COLOR), defaultColor: Color(0xFF040404));
  colorAccent = getColorFromHex(getStringAsync(SECONDARY_COLOR),
      defaultColor: Color(0xFF040404));
  textPrimaryColour = getColorFromHex(getStringAsync(TEXT_PRIMARY_COLOR),
      defaultColor: Color(0xFF212121));
  textSecondaryColour = getColorFromHex(getStringAsync(TEXT_SECONDARY_COLOR),
      defaultColor: Color(0xFF757575));
  backgroundColor = getColorFromHex(getStringAsync(BACKGROUND_COLOR),
      defaultColor: Color(0xFFFCFDFD));
  baseUrl = getStringAsync(APP_URL);
  consumerKey = getStringAsync(CONSUMER_KEY);
  consumerSecret = getStringAsync(CONSUMER_SECRET);

  defaultLoaderAccentColorGlobal = primaryColor!;

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(aIsDarkMode: false);
  }
  if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(aIsDarkMode: true);
  }
  appStore.setCount(getIntAsync(CARTCOUNT, defaultValue: 0));
  appStore
      .setNotification(getBoolAsync(IS_NOTIFICATION_ON, defaultValue: true));
  appStore.setLanguage(
      getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage));
  FlutterNativeSplash.remove();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appStore.isDarkMode! ? ThemeMode.dark : ThemeMode.light,
          supportedLocales: LanguageDataModel.languageLocales(),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(appStore.selectedLanguageCode),
          home: SplashScreen(),
          builder: scrollBehaviour(),
        );
      },
    );
  }
}

class SBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
