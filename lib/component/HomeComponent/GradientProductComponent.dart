import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../app_localizations.dart';
import '../../model/ProductResponse.dart';
import '../../model/WishListResponse.dart';
import '../../network/rest_apis.dart';
import '../../screens/ProductDetailScreen.dart';
import '../../screens/SignInScreen.dart';
import '../../utils/app_widgets.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/shared_pref.dart';

import '../../main.dart';

class GradientProductComponent extends StatefulWidget {
  static String tag = '/GradientProductComponent';
  final double? width;
  final ProductResponse? mProductModel;

  GradientProductComponent({Key? key, this.width, this.mProductModel})
      : super(key: key);

  @override
  GradientProductComponentState createState() =>
      GradientProductComponentState();
}

class GradientProductComponentState extends State<GradientProductComponent> {
  bool mIsInWishList = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (!await isGuestUser() && await isLoggedIn()) {
      if (widget.mProductModel!.isAddedWishList == false) {
        mIsInWishList = false;
      } else {
        mIsInWishList = true;
      }
    } else if (await isGuestUser()) {
      fetchPrefData();
    } else {}
  }

  void fetchPrefData() {
    if (appStore.mWishList.isNotEmpty) {
      appStore.mWishList.forEach((element) {
        if (element.proId == widget.mProductModel!.id) {
          mIsInWishList = true;
        }
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void checkLogin() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    } else {
      setState(() {
        if (mIsInWishList == true)
          removeWishListItem();
        else
          addToWishList();
        mIsInWishList = !mIsInWishList;
      });
    }
  }

  void removeWishListItem() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    await removeWishList({
      'pro_id': widget.mProductModel!.id,
    }).then((res) {
      if (!mounted) return;
      setState(() {
        toast(res[msg]);
        log("removeWishList" + mIsInWishList.toString());
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

  void addToWishList() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    var request = {'pro_id': widget.mProductModel!.id};
    await addWishList(request).then((res) {
      if (!mounted) return;
      setState(() {
        toast(res[msg]);
        log("addToWishList" + mIsInWishList.toString());
        mIsInWishList = true;
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

  void removePrefData() async {
    if (!await isGuestUser()) {
      checkLogin();
    } else {
      mIsInWishList = !mIsInWishList;
      var mList = <String?>[];
      widget.mProductModel!.images.forEachIndexed((element, index) {
        mList.add(element.src);
      });
      WishListResponse mWishListModel = WishListResponse();
      mWishListModel.name = widget.mProductModel!.name;
      mWishListModel.proId = widget.mProductModel!.id;
      mWishListModel.salePrice = widget.mProductModel!.salePrice;
      mWishListModel.regularPrice = widget.mProductModel!.regularPrice;
      mWishListModel.price = widget.mProductModel!.price;
      mWishListModel.gallery = mList;
      mWishListModel.stockQuantity = 1;
      mWishListModel.thumbnail = "";
      mWishListModel.full = widget.mProductModel!.images![0].src;
      mWishListModel.sku = "";
      mWishListModel.createdAt = "";
      if (mIsInWishList != true) {
        appStore.removeFromMyWishList(mWishListModel);
      } else {
        appStore.addToMyWishList(mWishListModel);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    var productWidth = MediaQuery.of(context).size.width;

    String? img = widget.mProductModel!.images!.isNotEmpty
        ? widget.mProductModel!.images!.first.src
        : '';

    return GestureDetector(
      onTap: () async {
        var result = await ProductDetailScreen(mProId: widget.mProductModel!.id)
            .launch(context);
        if (result == null) {
          mIsInWishList = mIsInWishList;
          setState(() {});
        } else {
          mIsInWishList = result;
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientColor, productGradientColor],
          ),
        ),
        padding: EdgeInsets.all(4),
        child: Container(
          width: widget.width,
          decoration: boxDecorationRoundedWithShadow(8,
              backgroundColor: Theme.of(context).cardTheme.color!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  commonCacheImageWidget(img.validate(),
                          height: 190, width: productWidth, fit: BoxFit.cover)
                      .cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8),
                  Positioned(
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: radiusOnly(topLeft: 8, bottomRight: 8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [gradientColor, productGradientColor],
                        ),
                      ),
                      child: Text(appLocalization.translate('lbl_sale')!,
                          style: secondaryTextStyle(color: white, size: 12)),
                      padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                    ),
                  ).visible(widget.mProductModel!.onSale == true),
                  Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.only(right: 4, top: 4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: greyColor.withOpacity(0.6)),
                    child: mIsInWishList == false
                        ? Icon(Icons.favorite_border,
                            color: Theme.of(context).textTheme.subtitle2!.color,
                            size: 16)
                        : Icon(Icons.favorite, color: Colors.red, size: 16),
                  )
                      .visible(!widget.mProductModel!.type!.contains("grouped"))
                      .onTap(() {
                    removePrefData();
                  })
                ],
              ),
              2.height,
              Text(widget.mProductModel!.name,
                      style: primaryTextStyle(size: 14), maxLines: 1)
                  .paddingOnly(top: 4, left: 8),
              4.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriceWidget(
                    price: widget.mProductModel!.onSale == true
                        ? widget.mProductModel!.salePrice.validate().isNotEmpty
                            ? double.parse(
                                    widget.mProductModel!.salePrice.toString())
                                .toStringAsFixed(2)
                            : double.parse(
                                    widget.mProductModel!.price.validate())
                                .toStringAsFixed(2)
                        : widget.mProductModel!.regularPrice!.isNotEmpty
                            ? double.parse(widget.mProductModel!.regularPrice
                                    .validate()
                                    .toString())
                                .toStringAsFixed(2)
                            : double.parse(widget.mProductModel!.price
                                    .validate()
                                    .toString())
                                .toStringAsFixed(2),
                    size: 14,
                    color: primaryColor,
                  ).paddingOnly(left: 4),
                  spacing_control.width,
                  PriceWidget(
                    price: widget.mProductModel!.regularPrice
                        .validate()
                        .toString(),
                    size: 12,
                    isLineThroughEnabled: true,
                    color: Theme.of(context).textTheme.subtitle1!.color,
                  ).expand().visible(
                      widget.mProductModel!.salePrice.validate().isNotEmpty &&
                          widget.mProductModel!.onSale == true),
                ],
              )
                  .visible(!widget.mProductModel!.type!.contains("grouped"))
                  .paddingOnly(bottom: 8, left: 4, right: 4),
              4.height,
            ],
          ),
        ),
      ),
    );
  }
}
