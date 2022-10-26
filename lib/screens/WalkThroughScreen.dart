import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/images.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'DashBoardScreen.dart';

class WalkThroughScreen extends StatefulWidget {
  static String tag = '/WalkThroughScreen';

  @override
  WalkThroughScreenState createState() => WalkThroughScreenState();
}

class WalkThroughScreenState extends State<WalkThroughScreen> {
  List<Widget> pages = [];
  int selectedIndex = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  init() async {
    var appLocalization = AppLocalizations.of(context);
    pages = [
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(walk_Img1, height: context.height(), fit: BoxFit.cover),
          Container(height: context.height(), color: black.withOpacity(0.4)),
          Positioned(
            bottom: 200,
            child: Text(appLocalization!.translate("txt_walk_through1")!,
                style: boldTextStyle(size: 20, color: white.withOpacity(0.6))),
          ),
          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child: Text(appLocalization.translate("msg_txt_walk_through1")!,
                textAlign: TextAlign.center,
                style: secondaryTextStyle(color: white.withOpacity(0.6))),
          )
        ],
      ).center(),
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(walk_Img2, height: context.height(), fit: BoxFit.cover),
          Container(height: context.height(), color: black.withOpacity(0.4)),
          Positioned(
            bottom: 200,
            child: Text(appLocalization.translate("txt_walk_through2")!,
                style: boldTextStyle(size: 20, color: white.withOpacity(0.6))),
          ),
          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child: Text(appLocalization.translate("msg_txt_walk_through2")!,
                textAlign: TextAlign.center,
                style: secondaryTextStyle(color: white.withOpacity(0.6))),
          )
        ],
      ).center(),
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(walk_Img3, height: context.height(), fit: BoxFit.cover),
          Container(
            height: context.height(),
            color: black.withOpacity(0.4),
          ),
          Positioned(
            bottom: 200,
            child: Text(appLocalization.translate("txt_walk_through3")!,
                style: boldTextStyle(size: 20, color: white.withOpacity(0.6))),
          ),
          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child: Text(
              appLocalization.translate("msg_txt_walk_through3")!,
              textAlign: TextAlign.center,
              style:
                  secondaryTextStyle(size: 14, color: white.withOpacity(0.6)),
            ),
          )
        ],
      ).center()
    ];
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    init();

    return Scaffold(
      body: Stack(
        children: [
          PageView(
              children: pages,
              controller: _pageController,
              onPageChanged: (index) {
                selectedIndex = index;
                setState(() {});
              }),
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            bottom: 70,
            left: 0,
            right: 0,
            child: DotIndicator(
              pageController: _pageController,
              pages: pages,
              indicatorColor: primaryColor,
              unselectedIndicatorColor: grey.withOpacity(0.2),
              currentBoxShape: BoxShape.rectangle,
              boxShape: BoxShape.rectangle,
              borderRadius: radius(2),
              currentBorderRadius: radius(3),
              currentDotSize: 18,
              currentDotWidth: 6,
              dotSize: 6,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 20,
            child: AnimatedCrossFade(
                firstChild: AppButton(
                  height: 20,
                  padding: EdgeInsets.all(8),
                  text: appLocalization!.translate("btn_get_start")!,
                  textStyle: boldTextStyle(color: white),
                  color: primaryColor,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onTap: () {
                    DashBoardScreen().launch(context, isNewTask: true);
                  },
                ),
                secondChild: SizedBox(),
                duration: Duration(milliseconds: 300),
                firstCurve: Curves.easeIn,
                secondCurve: Curves.easeOut,
                crossFadeState: selectedIndex == (pages.length - 1)
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: AnimatedCrossFade(
              duration: Duration(seconds: 1),
              firstChild: AppButton(
                height: 20,
                padding: EdgeInsets.all(8),
                text: appLocalization.translate("btn_skip")!,
                textStyle: boldTextStyle(color: white),
                color: primaryColor,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  DashBoardScreen().launch(context, isNewTask: true);
                },
              ),
              firstCurve: Curves.easeIn,
              secondCurve: Curves.easeOut,
              crossFadeState: selectedIndex == (pages.length - 1)
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              secondChild: SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
