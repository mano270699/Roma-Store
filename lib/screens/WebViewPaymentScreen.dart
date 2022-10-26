import '../utils/app_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../app_localizations.dart';
import '../main.dart';

class WebViewPaymentScreen extends StatefulWidget {
  static String tag = '/WebViewPaymentScreen';
  final String? checkoutUrl;

  WebViewPaymentScreen({this.checkoutUrl});

  @override
  WebViewPaymentScreenState createState() => WebViewPaymentScreenState();
}

class WebViewPaymentScreenState extends State<WebViewPaymentScreen> {
  bool mIsError = false;

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: mTop(context, appLocalization.translate('title_payment'),
            showBack: true) as PreferredSizeWidget?,
        body: Stack(
          children: [
            WebView(
              initialUrl: widget.checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              onPageFinished: (String url) {
                if (mIsError) return;
                if (url.contains('checkout/order-received')) {
                  appStore.setLoading(true);
                  toast(appLocalization.translate('lbl_order_place_success'));
                  appStore.setCount(0);
                  setState(() {});
                  Navigator.pop(context, true);
                } else {
                  appStore.setLoading(false);
                  setState(() {});
                }
              },
              onWebResourceError: (s) {
                mIsError = true;
              },
            ),
            Center(child: mProgress()).visible(appStore.isLoading!)
          ],
        ),
      ),
    );
  }
}
