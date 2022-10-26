import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../model/ProductResponse.dart';
import '../screens/VendorProfileScreen.dart';
import '../utils/app_widgets.dart';
import '../utils/images.dart';

// ignore: must_be_immutable
class VendorListComponent extends StatefulWidget {
  static String tag = '/VendorListComponent';
  List<VendorResponse>? mVendorList = [];

  VendorListComponent({Key? key, this.mVendorList}) : super(key: key);

  @override
  VendorListComponentState createState() => VendorListComponentState();
}

class VendorListComponentState extends State<VendorListComponent> {
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

  Widget getVendorWidget(
      VendorResponse vendor, BuildContext context, String? value) {
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
      height: 200,
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 12),
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
                child: Image.asset(ic_vendor_background, fit: BoxFit.fitHeight)
                    .cornerRadiusWithClipRRectOnly(topLeft: 8, bottomLeft: 8),
              ),
              Container(
                height: 150,
                width: 130,
                decoration: boxDecorationWithRoundedCorners(
                    border: Border.all(color: white, width: 4),
                    borderRadius: radius(0)),
                child: commonCacheImageWidget(img, fit: BoxFit.cover),
              ).center().paddingLeft(24),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vendor.storeName!, style: boldTextStyle(size: 18)),
              4.height,
              Text(vendor.phone!, style: primaryTextStyle()),
              4.height,
              Text(addressText!.trim(),
                  maxLines: 4, style: secondaryTextStyle()),
              12.height,
              Row(
                children: [
                  Icon(Icons.add,
                      size: 12, color: textSecondaryColor.withOpacity(0.6)),
                  4.width,
                  Text(value!,
                      style: secondaryTextStyle(
                          color: textSecondaryColor.withOpacity(0.6))),
                ],
              )
            ],
          ).paddingOnly(right: 8, left: 16).expand(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    List<VendorResponse> mVendorList = widget.mVendorList!;
    return ListView.builder(
        itemCount: mVendorList.length,
        padding: EdgeInsets.only(top: 12, left: 4, right: 4),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, i) {
          return getVendorWidget(mVendorList[i], context,
                  appLocalization!.translate('lbl_explore'))
              .onTap(() {
            VendorProfileScreen(mVendorId: mVendorList[i].id).launch(context);
          });
        });
  }
}
