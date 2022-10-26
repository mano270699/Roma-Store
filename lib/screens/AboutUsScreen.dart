import '../main.dart';
import '../utils/app_widgets.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';

import '../app_localizations.dart';

class AboutUsScreen extends StatefulWidget {
  static String tag = '/AboutUsScreen';

  @override
  AboutUsScreenState createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {
  PackageInfo? package;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    package = await PackageInfo.fromPlatform();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_about'),
            showBack: true) as PreferredSizeWidget?,
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                16.height,
                Container(
                  width: 120,
                  height: 120,
                  padding: EdgeInsets.all(8),
                  decoration: boxDecorationRoundedWithShadow(10),
                  child: Image.asset(splash),
                ),
                16.height,
                FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (_, snap) {
                      if (snap.hasData) {
                        return Text('${snap.data!.appName.validate()}',
                            style:
                                boldTextStyle(color: primaryColor, size: 20));
                      }
                      return SizedBox();
                    }),
                8.height
              ],
            ).center(),
          ),
        ),
        bottomNavigationBar: Container(
          height: 205,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: context.width(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(appLocalization.translate('llb_follow_us')!,
                            style: boldTextStyle())
                        .visible(getStringAsync(WHATSAPP).isNotEmpty),
                    10.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () async {
                            redirectUrl(
                                'https://wa.me/${getStringAsync(WHATSAPP)}');
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: spacing_standard_new.toDouble()),
                            padding: EdgeInsets.all(10),
                            child:
                                Image.asset(ic_WhatsUp, height: 35, width: 35),
                          ),
                        ).visible(getStringAsync(WHATSAPP).isNotEmpty),
                        InkWell(
                          onTap: () => redirectUrl(getStringAsync(INSTAGRAM)),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Image.asset(ic_Inst, height: 35, width: 35),
                          ),
                        ).visible(getStringAsync(INSTAGRAM).isNotEmpty),
                        InkWell(
                          onTap: () => redirectUrl(getStringAsync(TWITTER)),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child:
                                Image.asset(ic_Twitter, height: 35, width: 35),
                          ),
                        ).visible(getStringAsync(TWITTER).isNotEmpty),
                        InkWell(
                          onTap: () => redirectUrl(getStringAsync(FACEBOOK)),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Image.asset(ic_Fb, height: 35, width: 35),
                          ),
                        ).visible(getStringAsync(FACEBOOK).isNotEmpty),
                        InkWell(
                          onTap: () =>
                              redirectUrl('tel:${getStringAsync(CONTACT)}'),
                          child: Container(
                            margin: EdgeInsets.only(
                                right: spacing_standard_new.toDouble()),
                            padding: EdgeInsets.all(10),
                            child: Image.asset(ic_CallRing,
                                height: 35, width: 35, color: primaryColor),
                          ),
                        ).visible(getStringAsync(CONTACT).isNotEmpty)
                      ],
                    ),
                  ],
                ),
              ),
              FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return Text('V ${snap.data!.version.validate()}',
                          style: secondaryTextStyle());
                    }
                    return SizedBox();
                  }),
              6.height,
              Text(getStringAsync(COPYRIGHT_TEXT), style: secondaryTextStyle())
                  .visible(getStringAsync(COPYRIGHT_TEXT).isNotEmpty),
              8.height,
            ],
          ),
        ),
      ),
    );
  }
}
