import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/images.dart';

import '../app_localizations.dart';

class EmptyScreen extends StatefulWidget {
  static String tag = '/EmptyScreen';

  @override
  EmptyScreenState createState() => EmptyScreenState();
}

class EmptyScreenState extends State<EmptyScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ic_data_not_found,
              height: 80, width: 80, fit: BoxFit.contain),
          16.height,
          Text(appLocalization.translate('txt_no_result')!,
              style: primaryTextStyle(size: 18)),
        ],
      ).center().paddingAll(16),
    );
  }
}
