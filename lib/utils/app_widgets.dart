import 'dart:async';

import 'package:RomaStore/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_view/photo_view.dart';

import '../app_localizations.dart';
import '../main.dart';
import '../model/ProductResponse.dart';
import '../screens/DashBoardScreen.dart';
import '../screens/VendorListScreen.dart';
import '../screens/VendorProfileScreen.dart';
import 'common.dart';
import 'images.dart';

// ignore: must_be_immutable
class EditText extends StatefulWidget {
  var isPassword;
  var hintText;
  var isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var maxLine;
  Function? validator;
  Function? onChanged;
  TextEditingController? mController;
  VoidCallback? onPressed;

  EditText({
    var this.fontSize = 16,
    var this.textColor = textSecondaryColor,
    var this.hintText = '',
    var this.isPassword = true,
    var this.isSecure = false,
    var this.text = "",
    this.onChanged,
    this.validator,
    var this.mController,
    var this.maxLine = 1,
  });

  @override
  State<StatefulWidget> createState() {
    return EditTextState();
  }
}

class EditTextState extends State<EditText> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isSecure) {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        maxLines: widget.maxLine,
        style: primaryTextStyle(),
        onChanged: widget.onChanged as void Function(String)?,
        validator: widget.validator as String? Function(String?)?,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 12, 4, 12),
          labelText: widget.hintText,
          labelStyle: secondaryTextStyle(size: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(
                color: Theme.of(context).textTheme.subtitle1!.color!,
                width: 0.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorMaxLines: 2,
          errorStyle: primaryTextStyle(color: Colors.red, size: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(
                color: Theme.of(context).textTheme.subtitle1!.color!,
                width: 0.0),
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        validator: widget.validator as String? Function(String?)?,
        style: TextStyle(
            fontSize: widget.fontSize.toDouble(),
            color: Theme.of(context).textTheme.subtitle1!.color,
            fontFamily: widget.fontFamily),
        decoration: InputDecoration(
          suffixIcon: new GestureDetector(
            onTap: () {
              setState(() {
                widget.isPassword = !widget.isPassword;
              });
            },
            child: new Icon(
              widget.isPassword ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).textTheme.subtitle1!.color,
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 14, 4, 14),
          labelText: widget.hintText,
          labelStyle: primaryTextStyle(
              color: Theme.of(context).textTheme.subtitle1!.color),
          // filled: true,
          // fillColor: Theme.of(context).textTheme.headline4.color,
          enabledBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(
                color: Theme.of(context).textTheme.subtitle1!.color!,
                width: 0.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorMaxLines: 2,
          errorStyle: primaryTextStyle(color: Colors.red, size: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(
                color: Theme.of(context).textTheme.subtitle1!.color!,
                width: 0.0),
          ),
        ),
      );
    }
  }
}

// ignore: must_be_immutable
class SimpleEditText extends StatefulWidget {
  bool isPassword;
  bool isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var maxLine;
  Function? validator;
  TextInputType? keyboardType;
  var hintText;

  TextEditingController? mController;

  VoidCallback? onPressed;

  SimpleEditText(
      {this.fontSize = 20,
      this.textColor = textSecondaryColor,
      this.isPassword = false,
      this.isSecure = true,
      this.text = '',
      this.mController,
      this.maxLine = 1,
      this.hintText = '',
      this.keyboardType,
      this.validator});

  @override
  State<StatefulWidget> createState() {
    return SimpleEditTextState();
  }
}

class SimpleEditTextState extends State<SimpleEditText> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      obscureText: widget.isPassword,
      cursorColor: appStore.isDarkMode! ? whiteColor : black,
      validator: widget.validator as String? Function(String?)?,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 14, 4, 14),
        labelText: widget.hintText,
        labelStyle: primaryTextStyle(
            color: Theme.of(context).textTheme.subtitle1!.color),
        enabledBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(
                color: Theme.of(context).textTheme.subtitle1!.color!,
                width: 0.0)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0)),
        errorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0)),
        errorMaxLines: 2,
        errorStyle: primaryTextStyle(color: Colors.red, size: 12),
        focusedBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(
                color: appStore.isDarkMode! ? whiteColor : primaryColor!,
                width: 0.0)),
      ),
    ).paddingBottom(16);
  }
}

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction?> showConfirmDialogs(
    context, msg, positiveText, negativeText) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(msg, style: TextStyle(fontSize: 16, color: primaryColor)),
        actions: <Widget>[
          TextButton(
            child: Text(
              negativeText,
              style: primaryTextStyle(
                  color: Theme.of(context).textTheme.subtitle1!.color),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          TextButton(
            child: Text(
              positiveText,
              style: primaryTextStyle(color: primaryColor),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}

// ignore: must_be_immutable
class PriceWidget extends StatefulWidget {
  static String tag = '/PriceWidget';
  var price;
  double? size = 22.0;
  Color? color;
  var isLineThroughEnabled = false;

  PriceWidget(
      {Key? key,
      this.price,
      this.color,
      this.size,
      this.isLineThroughEnabled = false})
      : super(key: key);

  @override
  PriceWidgetState createState() => PriceWidgetState();
}

class PriceWidgetState extends State<PriceWidget> {
  var currency = '₹';
  Color? primaryColor;

  @override
  void initState() {
    super.initState();
    get();
  }

  get() async {
    setState(() {
      currency = getStringAsync(DEFAULT_CURRENCY);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLineThroughEnabled) {
      return Text('$currency${widget.price.toString().replaceAll(".00", "")}',
          style: boldTextStyle(
              size: widget.size!.toInt(),
              color: widget.color != null ? widget.color : primaryColor));
    } else {
      return widget.price.toString().isNotEmpty
          ? Text('$currency${widget.price.toString().replaceAll(".00", "")}',
              style: TextStyle(
                  fontSize: widget.size,
                  color: widget.color ?? textPrimaryColor,
                  decoration: TextDecoration.lineThrough))
          : Text('');
    }
  }
}

Widget noInternet(context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        MaterialCommunityIcons.wifi_off,
        size: 80,
      ),
      20.height,
      Text(AppLocalizations.of(context)!.translate('lbl_no_internet')!,
          style: boldTextStyle(
              size: 24, color: Theme.of(context).textTheme.subtitle2!.color)),
      4.height,
      Text(
        AppLocalizations.of(context)!.translate('lbl_no_internet_msg')!,
        style: secondaryTextStyle(
            size: 14, color: Theme.of(context).textTheme.subtitle1!.color),
        textAlign: TextAlign.center,
      ).paddingOnly(left: 20, right: 20),
    ],
  );
}

Widget getVendorWidget(VendorResponse vendor, BuildContext context) {
  String img = vendor.banner!.isNotEmpty ? vendor.banner.validate() : '';

  String? addressText = "";
  if (vendor.address != null) {
    if (vendor.address!.street_1 != null) {
      if (vendor.address!.street_1!.isNotEmpty && addressText.isEmpty) {
        addressText = vendor.address!.street_1;
      }
    }
    if (vendor.address!.street_2 != null) {
      if (vendor.address!.street_2!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.street_2;
        } else {
          addressText += ", " + vendor.address!.street_2!;
        }
      }
    }
    if (vendor.address!.city != null) {
      if (vendor.address!.city!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.city;
        } else {
          addressText += ", " + vendor.address!.city!;
        }
      }
    }

    if (vendor.address!.zip != null) {
      if (vendor.address!.zip!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.zip;
        } else {
          addressText += " - " + vendor.address!.zip!;
        }
      }
    }
    if (vendor.address!.state != null) {
      if (vendor.address!.state!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.state;
        } else {
          addressText += ", " + vendor.address!.state!;
        }
      }
    }
    if (vendor.address!.country != null) {
      if (!vendor.address!.country!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.country;
        } else {
          addressText += ", " + vendor.address!.country!;
        }
      }
    }
  }

  return Container(
    width: context.width() * 0.85,
    height: 200,
    margin: EdgeInsets.all(4),
    decoration: boxDecorationRoundedWithShadow(8,
        backgroundColor: Theme.of(context).cardTheme.color!),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
                width: 130,
                height: 200,
                child: Image.asset(
                  ic_vendor_background,
                  fit: BoxFit.fitHeight,
                ).cornerRadiusWithClipRRectOnly(topLeft: 8, bottomLeft: 8)),
            Container(
              height: 150,
              width: 130,
              decoration: boxDecorationWithShadow(
                  border: Border.all(color: white, width: 4),
                  borderRadius: radius(0)),
              child: commonCacheImageWidget(
                img,
                fit: BoxFit.cover,
              ),
            ).center().paddingLeft(24),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.storeName!, style: boldTextStyle(size: 18)),
            8.height,
            Text(
              addressText!.trim(),
              maxLines: 4,
              style: secondaryTextStyle(
                  color: Theme.of(context).textTheme.subtitle1!.color),
            ),
            12.height,
            Row(
              children: [
                Icon(
                  Icons.add,
                  size: 12,
                  color: textSecondaryColor.withOpacity(0.6),
                ),
                4.width,
                Text('Explore',
                    style: secondaryTextStyle(
                        color: textSecondaryColor.withOpacity(0.6))),
              ],
            )
          ],
        ).paddingOnly(right: 8, left: 16).expand(),
        /*  Text(
          addressText!,
          maxLines: 2,
          style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
        ).paddingOnly(left: 8,right: 8,bottom: 4),*/
        /* commonCacheImageWidget(img, height: 130, width: width, fit: BoxFit.cover).cornerRadiusWithClipRRectOnly(bottomRight: 8,bottomLeft: 8),*/
      ],
    ),
  );
}

Widget vendorList(List<VendorResponse> product) {
  return HorizontalList(
    itemCount: product.length,
    wrapAlignment: WrapAlignment.start,
    crossAxisAlignment: WrapCrossAlignment.start,
    padding: EdgeInsets.only(left: 8, right: 8),
    itemBuilder: (context, i) {
      return GestureDetector(
        onTap: () {
          VendorProfileScreen(mVendorId: product[i].id).launch(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getVendorWidget(product[i], context),
          ],
        ),
      );
    },
  );
}

Widget mVendorWidget(
    BuildContext context, List<VendorResponse> mVendorModel, var title, var all,
    {size: textSizeMedium}) {
  return mVendorModel.isNotEmpty
      ? Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 8),
              width: context.width(),
              decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(0), backgroundColor: context.cardColor),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(ic_heading, fit: BoxFit.cover),
                  Column(
                    children: [
                      Text(title,
                          style: GoogleFonts.alegreyaSc(
                              color: appStore.isDarkMode!
                                  ? white.withOpacity(0.7)
                                  : primaryColor!,
                              fontSize: 22)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(all,
                                  style: GoogleFonts.alegreyaSc(
                                      fontSize: 16, color: textSecondaryColour))
                              .onTap(() {
                            VendorListScreen().launch(context);
                          }),
                          Icon(
                            Icons.chevron_right,
                            color: textSecondaryColour,
                            size: 20,
                          )
                        ],
                      )
                    ],
                  )
                ],
              )
                  .paddingOnly(top: 16, bottom: 16)
                  .visible(mVendorModel.isNotEmpty),
            ),
            8.height,
            vendorList(mVendorModel).paddingBottom(8)
          ],
        )
      : SizedBox();
}

Widget mCart(BuildContext context, bool mIsLoggedIn,
    {Color color = Colors.white}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Image.asset(ic_shopping_cart, height: 25, width: 25, color: white)
          .onTap(() {
        checkLoggedIn(context);
      }).paddingRight(14),
      if (appStore.count.toString() != "0")
        Positioned(
          top: 8,
          right: 10,
          child: Observer(
            builder: (_) => CircleAvatar(
              maxRadius: 7,
              minRadius: 5,
              backgroundColor: color,
              child: FittedBox(
                  child: Text('${appStore.count}',
                      style: Theme.of(context).textTheme.headline3)),
            ),
          ),
        ).visible(mIsLoggedIn ||
            getBoolAsync(IS_GUEST_USER, defaultValue: false) == true)
    ],
  );
}

Widget mTop(BuildContext context, var title,
    {List<Widget>? actions, bool showBack = false}) {
  return AppBar(
    elevation: 0,
    leading: showBack
        ? IconButton(
            icon: Icon(Icons.arrow_back, color: white),
            onPressed: () {
              finish(context);
            },
          )
        : null,
    actions: actions,
    title: Text(title,
        style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium)),
    automaticallyImplyLeading: false,
  );
}

Widget mTopNew(BuildContext context, var title,
    {List<Widget>? actions, bool showBack = false}) {
  return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: white),
              onPressed: () {
                finish(context);
              },
            )
          : null,
      actions: actions,
      title: Text(title,
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium)),
      automaticallyImplyLeading: false);
}

Widget mView(Widget widget, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    decoration: boxDecorationWithRoundedCorners(
        borderRadius: BorderRadius.zero,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor),
    child: widget,
  );
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double innerCircleRadius = 10.0;

    Path path = Path();
    path.lineTo(0, rect.height);
    path.quadraticBezierTo(rect.width / 2, rect.height + 15,
        rect.width / 2 - 75, rect.height + 50);
    path.cubicTo(
        rect.width / 2 - 0,
        rect.height + innerCircleRadius - 0,
        rect.width / 2 + 0,
        rect.height + innerCircleRadius - 0,
        rect.width / 2 + 75,
        rect.height + 50);
    path.quadraticBezierTo(rect.width / 2 + (innerCircleRadius / 2) + 30,
        rect.height + 15, rect.width, rect.height);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}

Widget mProgress() {
  return Container(
    alignment: Alignment.center,
    child: Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 4,
      margin: EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: radius(50)),
      child: Container(
        width: 45,
        height: 45,
        padding: EdgeInsets.all(8.0),
        child: Theme(
          data: ThemeData(accentColor: primaryColor),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: primaryColor,
          ),
        ),
      ),
    ),
  );
}

Widget mSale(ProductResponse product, String value) {
  return Positioned(
    left: 0,
    child: Container(
      decoration: boxDecorationWithRoundedCorners(
          backgroundColor: Colors.red,
          borderRadius: radiusOnly(topLeft: 8, bottomRight: 8)),
      child: Text(value, style: secondaryTextStyle(color: white, size: 12)),
      padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
    ),
  ).visible(product.onSale == true);
}

Function(BuildContext, String) placeholderWidgetFn() =>
    (_, s) => placeholderWidget();

Widget placeholderWidget() => Image.asset(ic_placeHolder, fit: BoxFit.cover);

Widget commonCacheImageWidget(String? url,
    {double? width, BoxFit? fit, double? height}) {
  if (url.validate().startsWith('https') || url.validate().startsWith('http')) {
    if (isMobile) {
      return CachedNetworkImage(
        placeholder:
            placeholderWidgetFn() as Widget Function(BuildContext, String)?,
        imageUrl: '$url',
        height: height,
        width: width,
        fit: fit,
      );
    } else {
      return Image.network(url!, height: height, width: width, fit: fit);
    }
  } else {
    return Image.asset(url!, height: height, width: width, fit: fit);
  }
}

class CustomTheme extends StatelessWidget {
  final Widget? child;

  CustomTheme({this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appStore.isDarkModeOn
          ? ThemeData.dark().copyWith(
              accentColor: primaryColor,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            )
          : ThemeData.light(),
      child: child!,
    );
  }
}

void openPhotoViewer(context, ImageProvider imageProvider) {
  Scaffold(
    body: Stack(
      children: <Widget>[
        PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: 1.0,
        ),
        Positioned(top: 35, left: 16, child: BackButton(color: Colors.white)),
      ],
    ),
  ).launch(context);
}

Widget mInternetConnection(Widget widget) {
  Stream connectivityStream = Connectivity().onConnectivityChanged;
  return StreamBuilder<ConnectivityResult>(
      stream: connectivityStream as Stream<ConnectivityResult>?,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final connectivityResult = snapshot.data;
          if (connectivityResult == ConnectivityResult.none) {
            return noInternet(context);
          }
          return widget;
        } else if (snapshot.hasError) {
          return noInternet(context);
        }
        return widget;
      });
}

Future<void> setLogoutData(BuildContext context) async {
  if (getBoolAsync(IS_LOGGED_IN) == true) {
    var primaryColor = getStringAsync(THEME_COLOR);
    await setValue(THEME_COLOR, primaryColor);
    await removeKey(PROFILE_IMAGE);
    await removeKey(BILLING);
    await removeKey(SHIPPING);
    await removeKey(USERNAME);
    await removeKey(FIRST_NAME);
    await removeKey(FIRST_NAME);
    await removeKey(LAST_NAME);
    await removeKey(TOKEN);
    await removeKey(USER_DISPLAY_NAME);
    await removeKey(USER_ID);
    await removeKey(USER_EMAIL);
    await removeKey(AVATAR);
    await removeKey(COUNTRIES);
    await removeKey(CART_DATA);
    await removeKey(WISH_LIST_DATA);
    await removeKey(GUEST_USER_DATA);
    await removeKey(CARTCOUNT);
    await setValue(IS_GUEST_USER, false);
    await setValue(IS_LOGGED_IN, false);
    await setValue(IS_SOCIAL_LOGIN, false);
    appStore.setCount(0);
    DashBoardScreen().launch(context, isNewTask: true);
  } else {
    DashBoardScreen().launch(context, isNewTask: true);
  }
}
