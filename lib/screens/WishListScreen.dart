import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/CartModel.dart';
import '../model/WishListResponse.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import '../utils/shared_pref.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'DashBoardScreen.dart';
import 'ProductDetailScreen.dart';
import 'SearchScreen.dart';
import 'SignInScreen.dart';
import 'SignUpScreen.dart';

class WishListScreen extends StatefulWidget {
  static String tag = '/WishListScreen';

  @override
  WishListScreenState createState() => WishListScreenState();
}

class WishListScreenState extends State<WishListScreen> {
  List<WishListResponse> mWishListModel = [];
  bool mIsLoggedIn = false;
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      mIsLoggedIn = getBoolAsync(IS_LOGGED_IN);
    });
    if (!await isGuestUser() && await isLoggedIn()) {
      fetchWishListData();
    } else if (await isGuestUser()) {
      fetchPrefWishListData();
    } else {
      setState(() {
        mIsLoggedIn = false;
      });
    }
  }

  Future fetchWishListData() async {
    appStore.setLoading(true);
    setState(() {});
    await getWishList().then((res) {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {
        Iterable list = res;
        mWishListModel =
            list.map((model) => WishListResponse.fromJson(model)).toList();
      });
    }).catchError((error) {
      appStore.setLoading(false);
      setState(() {});
      if (!mounted) return;
    });
  }

  fetchPrefWishListData() {
    if (appStore.mWishList.isEmpty) {
    } else {
      appStore.setLoading(false);
      setState(() {
        mWishListModel = appStore.mWishList;
      });
    }
  }

  Future addToCartApi(mProId) async {
    var removeWishListRequest = {
      'pro_id': mProId,
    };
    removeWishList(removeWishListRequest).then((res) {
      if (!mounted) return;
      var request = {
        'pro_id': mProId,
        'quantity': 1,
      };
      addToCart(request).then((res) {
        toast(res[msg]);
        fetchWishListData();
      }).catchError((error) {
        toast(error.toString());
        fetchWishListData();
      });
    }).catchError((error) {});
  }

  Future removeWishListItem(mProId) async {
    var removeWishListRequest = {
      'pro_id': mProId,
    };
    removeWishList(removeWishListRequest).then((res) {
      if (!mounted) return;
      fetchWishListData();
    }).catchError((error) {
      toast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    Widget mWishList = StaggeredGridView.countBuilder(
      scrollDirection: Axis.vertical,
      itemCount: mWishListModel.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 8),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            bool val =
                await (ProductDetailScreen(mProId: mWishListModel[index].proId)
                    .launch(context));
            if (val) fetchWishListData();
          },
          child: Container(
            decoration: boxDecorationWithRoundedCorners(
                backgroundColor: Theme.of(context).cardTheme.color!,
                border: Border.all(
                    color: Theme.of(context).colorScheme.background)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    mWishListModel[index].full == null
                        ? commonCacheImageWidget(
                                mWishListModel[index].gallery![0].validate(),
                                height: 180,
                                width: context.width(),
                                fit: BoxFit.cover)
                            .cornerRadiusWithClipRRectOnly(
                                topLeft: 8, topRight: 8)
                        : commonCacheImageWidget(mWishListModel[index].full,
                                height: 180,
                                width: context.width(),
                                fit: BoxFit.cover)
                            .visible(mWishListModel[index].full!.isNotEmpty)
                            .cornerRadiusWithClipRRectOnly(
                                topLeft: 8, topRight: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: Colors.red,
                              borderRadius: radiusOnly(topLeft: 8)),
                          child: Text(appLocalization.translate('lbl_sale')!,
                              style:
                                  secondaryTextStyle(color: white, size: 12)),
                          padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                        ).visible(mWishListModel[index].salePrice!.isNotEmpty),
                        Container(
                          margin: EdgeInsets.all(6),
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .cardTheme
                                  .color!
                                  .withOpacity(0.6)),
                          child: Icon(Icons.close,
                              color:
                                  Theme.of(context).textTheme.subtitle2!.color,
                              size: 16),
                        ).onTap(() async {
                          if (!await isGuestUser() && await isLoggedIn()) {
                            removeWishListItem(mWishListModel[index].proId);
                          } else {
                            appStore
                                .removeFromMyWishList(mWishListModel[index]);
                            setState(() {});
                          }
                        }),
                      ],
                    )
                  ],
                ),
                8.height,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(mWishListModel[index].name!,
                            style: primaryTextStyle(size: 14), maxLines: 1)
                        .paddingOnly(
                            left: spacing_standard.toDouble(),
                            right: spacing_standard.toDouble()),
                    Row(
                      children: <Widget>[
                        PriceWidget(
                          price: mWishListModel[index].salePrice!.isNotEmpty
                              ? mWishListModel[index].salePrice.toString()
                              : mWishListModel[index].price.toString(),
                          size: 16,
                          color: primaryColor,
                        ),
                        4.width,
                        PriceWidget(
                          price: mWishListModel[index].regularPrice.toString(),
                          size: 14,
                          color: Theme.of(context).textTheme.subtitle1!.color,
                          isLineThroughEnabled: true,
                        ).visible(mWishListModel[index]
                            .salePrice
                            .validate()
                            .isNotEmpty),
                      ],
                    ).paddingOnly(
                        left: spacing_standard.toDouble(),
                        right: spacing_standard.toDouble()),
                    Divider(color: view_color),
                    Text(appLocalization.translate('lbl_add_to_basket')!,
                            style:
                                boldTextStyle(size: 14, color: primaryColor!))
                        .onTap(() async {
                          if (!await isGuestUser()) {
                            addToCartApi(mWishListModel[index].proId);
                          } else {
                            CartModel mCartModel = CartModel();
                            mCartModel.name = mWishListModel[index].name;
                            mCartModel.proId = mWishListModel[index].proId;
                            mCartModel.salePrice =
                                mWishListModel[index].salePrice;
                            mCartModel.regularPrice =
                                mWishListModel[index].regularPrice;
                            mCartModel.price = mWishListModel[index].price;
                            mCartModel.gallery = mWishListModel[index].gallery;
                            mCartModel.quantity = "1";
                            mCartModel.stockQuantity = "1";
                            mCartModel.stockStatus = "";
                            mCartModel.thumbnail = "";
                            mCartModel.full = mWishListModel[index].full;
                            mCartModel.sku = "";
                            mCartModel.createdAt = "";
                            if (mWishListModel[index].salePrice!.isNotEmpty) {
                              mCartModel.onSale = true;
                            } else {
                              mCartModel.onSale = false;
                            }
                            appStore.increment();
                            toast(appLocalization.translate(
                                "txt_msg_successfully_added_to_cart")!);
                            appStore
                                .removeFromMyWishList(mWishListModel[index]);
                            appStore.addToCartList(mCartModel);
                            setState(() {});
                          }
                        })
                        .paddingOnly(bottom: 8)
                        .center(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      crossAxisCount: 2,
      staggeredTileBuilder: (index) {
        return StaggeredTile.fit(1);
      },
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
    );

    return Scaffold(
      appBar:
          mTop(context, appLocalization.translate('lbl_wish_list'), actions: [
        IconButton(
            icon: Icon(Icons.search_sharp, color: white),
            onPressed: () {
              SearchScreen().launch(context);
            })
      ]) as PreferredSizeWidget?,
      body: Observer(
        builder: (_) => Stack(
          children: [
            !mIsLoggedIn
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(ic_wishlist, height: 200, width: 200),
                      20.height,
                      Text(appLocalization.translate("msg_wishlist")!,
                              style: primaryTextStyle(size: 20),
                              textAlign: TextAlign.center)
                          .paddingOnly(left: 20, right: 20),
                      Text(appLocalization.translate("lbl_wishlist_msg")!,
                              style: secondaryTextStyle(size: 16),
                              textAlign: TextAlign.center)
                          .paddingOnly(left: 20, right: 20),
                      30.height,
                      AppButton(
                              width: context.width(),
                              textStyle: primaryTextStyle(color: white),
                              text: appLocalization.translate('lbl_sign_in'),
                              onTap: () {
                                SignInScreen().launch(context);
                              },
                              color: primaryColor)
                          .paddingOnly(left: 16, right: 16),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              appLocalization
                                  .translate('lbl_dont_t_have_an_account')!,
                              style: primaryTextStyle(size: 18)),
                          4.width,
                          Text(appLocalization.translate('lbl_sign_up_link')!,
                                  style: primaryTextStyle(
                                      size: 18, color: primaryColor))
                              .onTap(() {
                            SignUpScreen().launch(context);
                          })
                        ],
                      ).paddingAll(16)
                    ],
                  ).visible(!appStore.isLoading!)
                : Stack(
                    children: <Widget>[
                      mWishList.visible(mWishListModel.isNotEmpty),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(ic_wishlist, height: 200, width: 200),
                          8.height,
                          Text(
                                  appLocalization
                                      .translate('lbl_your_wishlist_empty')!,
                                  style: boldTextStyle(size: 20),
                                  textAlign: TextAlign.center)
                              .paddingOnly(left: 20, right: 20),
                          8.height,
                          Text(
                                  appLocalization
                                      .translate('lbl_wishlist_empty_msg')!,
                                  style: secondaryTextStyle(size: 16),
                                  textAlign: TextAlign.center)
                              .paddingOnly(left: 20, right: 20),
                          30.height,
                          AppButton(
                                  width: context.width(),
                                  textStyle: primaryTextStyle(color: white),
                                  text: appLocalization
                                      .translate('lbl_create_wishlist'),
                                  onTap: () {
                                    DashBoardScreen().launch(context);
                                  },
                                  color: primaryColor)
                              .paddingOnly(left: 16, right: 16),
                        ],
                      ).visible(mWishListModel.isEmpty && !appStore.isLoading!),
                      mProgress().center().visible(appStore.isLoading!),
                    ],
                  ).visible(mIsLoggedIn),
            Center(child: mProgress()).visible(appStore.isLoading!)
          ],
        ),
      ),
    );
  }
}
