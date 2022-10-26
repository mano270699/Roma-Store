import '../utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../main.dart';

class ThemeSelectionComponent extends StatefulWidget {
  static String tag = '/ThemeSelectionComponent';

  @override
  ThemeSelectionComponentState createState() => ThemeSelectionComponentState();
}

class ThemeSelectionComponentState extends State<ThemeSelectionComponent> {
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    List<String?> themeModeList = [
      appLocalization.translate('lbl_light'),
      appLocalization.translate('lbl_dark'),
      appLocalization.translate('lbl_system_default')
    ];

    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: themeModeList.length,
        itemBuilder: (BuildContext context, int index) {
          return RadioListTile(
            activeColor: primaryColor,
            dense: true,
            value: index,
            groupValue: currentIndex,
            title: Text(themeModeList[index]!, style: primaryTextStyle()),
            onChanged: (dynamic val) {
              currentIndex = val;
              if (val == ThemeModeSystem) {
                appStore.setDarkMode(
                    aIsDarkMode: MediaQuery.of(context).platformBrightness ==
                        Brightness.dark);
              } else if (val == ThemeModeLight) {
                appStore.setDarkMode(aIsDarkMode: false);
              } else if (val == ThemeModeDark) {
                appStore.setDarkMode(aIsDarkMode: true);
              }
              setValue(THEME_MODE_INDEX, val);
              finish(context);
            },
          );
        },
      ),
    );
  }
}
