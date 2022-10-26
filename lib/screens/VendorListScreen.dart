import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../component/VendorListComponent.dart';
import '../main.dart';
import '../model/ProductResponse.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';

import '../app_localizations.dart';

class VendorListScreen extends StatefulWidget {
  static String tag = '/VendorListScreen';

  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  List<VendorResponse> mVendorList = [];
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchVendorData();
  }

  Future fetchVendorData() async {
    appStore.setLoading(true);
    await getVendor().then((res) {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {
        Iterable list = res;
        mVendorList =
            list.map((model) => VendorResponse.fromJson(model)).toList();
        mErrorMsg = '';
      });
    }).catchError((error) {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {
        mErrorMsg = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_vendors'),
            showBack: true) as PreferredSizeWidget?,
        body: mInternetConnection(
          mVendorList.isNotEmpty
              ? Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    VendorListComponent(mVendorList: mVendorList),
                    mProgress().center().visible(appStore.isLoading!),
                  ],
                )
              : Center(child: mProgress()),
        ),
      ),
    );
  }
}
