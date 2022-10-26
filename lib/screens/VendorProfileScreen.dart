import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import '../component/ProductComponent.dart';
import '../model/ProductResponse.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';

import '../app_localizations.dart';
import '../main.dart';

class VendorProfileScreen extends StatefulWidget {
  static String tag = '/VendorProfileScreen';
  final int? mVendorId;

  VendorProfileScreen({Key? key, this.mVendorId}) : super(key: key);

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  VendorResponse mVendorModel = VendorResponse();
  List<ProductResponse> mVendorProductList = [];
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    log(widget.mVendorId.toString());
    fetchVendorProfile();
    fetchVendorProduct();
  }

  Future fetchVendorProfile() async {
    appStore.setLoading(true);
    await getVendorProfile(widget.mVendorId).then((res) {
      if (!mounted) return;
      VendorResponse methodResponse = VendorResponse.fromJson(res);
      appStore.setLoading(false);
      setState(() {
        mVendorModel = methodResponse;
        mErrorMsg = '';
      });
    }).catchError((error) {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {});
    });
  }

  Future fetchVendorProduct() async {
    appStore.setLoading(true);
    await getVendorProduct(widget.mVendorId).then((res) {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {
        mErrorMsg = '';
        Iterable list = res;
        mVendorProductList =
            list.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError(
      (error) {
        if (!mounted) return;
        appStore.setLoading(false);
        setState(() {});
      },
    );
  }

  Widget mOption(var value, int size, var color, {maxLine = 1}) {
    return Text(value,
            style: primaryTextStyle(size: size, color: color),
            maxLines: maxLine)
        .paddingOnly(left: 10, right: 16);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    String? addressText = "";

    if (mVendorModel != null) {
      if (mVendorModel.address != null) {
        if (mVendorModel.address!.street_1!.isNotEmpty && addressText.isEmpty) {
          addressText = mVendorModel.address!.street_1;
        }
        if (mVendorModel.address!.street_2!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel.address!.street_2;
          } else {
            addressText += ", " + mVendorModel.address!.street_2!;
          }
        }

        if (mVendorModel.address!.city!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel.address!.city;
          } else {
            addressText += ", " + mVendorModel.address!.city!;
          }
        }
        if (mVendorModel.address!.zip!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel.address!.zip;
          } else {
            addressText += " - " + mVendorModel.address!.zip!;
          }
        }
        if (mVendorModel.address!.state!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel.address!.state;
          } else {
            addressText += ", " + mVendorModel.address!.state!;
          }
        }
        if (mVendorModel.address!.country!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel.address!.country;
          } else {
            addressText += ", " + mVendorModel.address!.country!;
          }
        }
      }
    }

    final body = mVendorModel != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                mVendorModel.storeName != null
                    ? Text(mVendorModel.storeName.toString(),
                            style: boldTextStyle())
                        .paddingOnly(left: 12)
                    : SizedBox(),
                Row(
                  children: [
                    mVendorModel.avatar != null
                        ? CircleAvatar(
                            maxRadius: 40,
                            backgroundColor: context.cardColor,
                            backgroundImage:
                                NetworkImage(mVendorModel.avatar!.validate()))
                        : SizedBox(),
                    4.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                                mVendorModel.firstName.isEmptyOrNull
                                    ? ""
                                    : mVendorModel.firstName.toString() +
                                        " " +
                                        mVendorModel.lastName.toString(),
                                style: boldTextStyle())
                            .paddingLeft(8),
                        4.height,
                        mOption(
                                mVendorModel.phone != null
                                    ? mVendorModel.phone
                                    : '',
                                14,
                                Theme.of(context).textTheme.subtitle1!.color)
                            .visible(!mVendorModel.phone.isEmptyOrNull),
                        4.height,
                        mOption(addressText.isEmptyOrNull ? "" : addressText,
                            14, Theme.of(context).textTheme.subtitle1!.color,
                            maxLine: 3),
                      ],
                    ).expand(),
                  ],
                ).paddingOnly(left: 12, top: 16),
                8.height,
                Divider(),
                4.height,
                Text(appLocalization!.translate('lbl_product_list')!,
                        style: boldTextStyle(size: 18))
                    .visible(mVendorProductList.isNotEmpty)
                    .paddingLeft(12),
                6.height,
                mVendorProductList != null
                    ? StaggeredGridView.countBuilder(
                        scrollDirection: Axis.vertical,
                        itemCount: mVendorProductList.length,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(12),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        staggeredTileBuilder: (index) {
                          return StaggeredTile.fit(1);
                        },
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 8,
                        itemBuilder: (context, index) {
                          return ProductComponent(
                              mProductModel: mVendorProductList[index]);
                        },
                      )
                    : Text(appLocalization.translate('lbl_data_not_found')!,
                            style: boldTextStyle(color: primaryColor))
                        .visible(mVendorProductList.isEmpty)
                        .paddingOnly(left: 8, right: 8)
              ],
            ),
          )
        : mProgress().center().visible(appStore.isLoading!);

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        body: mInternetConnection(
          Stack(
            children: <Widget>[
              NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      elevation: 0,
                      expandedHeight: 300,
                      backgroundColor:
                          innerBoxIsScrolled ? primaryColor! : transparentColor,
                      title: Text(
                              innerBoxIsScrolled
                                  ? mVendorModel.storeName.toString()
                                  : "",
                              style: boldTextStyle(
                                  color: innerBoxIsScrolled ? white : black))
                          .visible(mVendorModel.storeName != null),
                      leading: BackButton(
                        color: innerBoxIsScrolled ? white : black,
                      ),
                      floating: true,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: mVendorModel.banner != null
                            ? Container(
                                    height: 200,
                                    child: Image.network(
                                        mVendorModel.banner.validate(),
                                        fit: BoxFit.cover))
                                .visible(mVendorModel.banner!.isNotEmpty)
                                .visible(mVendorModel.banner!.isNotEmpty)
                            : SizedBox().visible(mVendorModel.banner != null),
                      ),
                    ),
                  ];
                },
                body: body,
              ),
              mProgress().center().visible(appStore.isLoading!),
              Text(mErrorMsg.validate(), style: boldTextStyle(size: 20))
                  .center()
                  .visible(mErrorMsg.isNotEmpty),
            ],
          ),
        ),
      ),
    );
  }
}
