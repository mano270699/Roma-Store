import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/CartModel.dart';
import '../model/Countries.dart';
import '../model/CustomerResponse.dart';
import '../model/Line_items.dart';
import '../model/OrderModel.dart';
import '../model/ShippingMethodResponse.dart';
import '../model/WishListResponse.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/dashed_ract.dart';
import '../utils/images.dart';
import '../utils/shared_pref.dart';
import '../app_localizations.dart';
import '../main.dart';
import 'DashBoardScreen.dart';
import 'EditProfileScreen.dart';
import 'OrderSummaryScreen.dart';
import 'ProductDetailScreen.dart';
import 'SignInScreen.dart';

// ignore: must_be_immutable
class MyCartScreen extends StatefulWidget {
  static String tag = '/MyCartScreen';

  bool? isShowBack = false;

  MyCartScreen({this.isShowBack});

  @override
  MyCartScreenState createState() => MyCartScreenState();
}

class MyCartScreenState extends State<MyCartScreen> {
  List<CartModel> mCartModelList = [];
  List<LineItems> mLineItems = [];
  List<Method> shippingMethods = [];
  List<Country> countryList = [];
  List<int> quantity = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  Shipping? shipping;
  ShippingMethodResponse? shippingMethodResponse;

  bool mIsLoggedIn = false;
  bool mIsGuest = false;
  bool isCoupons = false;
  bool isEnableCoupon = false;
  bool isOutOfStock = false;

  String mErrorMsg = '';

  double? mTotalDiscount = 0;
  double? mSaveDiscount = 0;
  double mTotalCount = 0.0;
  double mTotalMrpDiscount = 0.0;
  double mTotalMrp = 0.0;
  int _currentTimeValue = 0;

  late var mDiscountedAmount;
  var selectedShipment = 0;
  var mDiscountInfo;

  ScrollController _scrollController = ScrollController();
  NumberFormat nf = NumberFormat('##.00');

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    mIsGuest = getBoolAsync(IS_GUEST_USER, defaultValue: false);
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN, defaultValue: false);
    if (!await isGuestUser() && await isLoggedIn()) {
      fetchCartData();
    } else if (await isGuestUser()) {
      fetchPrefData();
    } else {
      setState(() {
        appStore.isLoading = false;
      });
    }
  }

  fetchShipmentData() async {
    if (countryList.isEmpty) {
      String countries = getStringAsync(COUNTRIES);
      if (countries == '') {
        await getCountries().then((value) async {
          setState(() {
            appStore.isLoading = false;
          });
          setValue(COUNTRIES, jsonEncode(value));
          fetchShippingMethod(value);
        }).catchError((error) {
          setState(() {
            appStore.isLoading = false;
          });
          toast(error);
        });
      } else {
        fetchShippingMethod(jsonDecode(countries));
      }
    } else {
      setState(() {
        appStore.isLoading = false;
      });
      loadShippingMethod();
    }
  }

  fetchShippingMethod(var value) async {
    // setState(() {
    //   appStore.isLoading = false;
    // });
    Iterable list = value;
    var countries = list.map((model) => Country.fromJson(model)).toList();
    setState(() {
      countryList.addAll(countries);
    });

    if (getStringAsync(SHIPPING).isNotEmpty) {
      if (jsonDecode(getStringAsync(SHIPPING)) != null) {
        setState(() {
          shipping = Shipping.fromJson(jsonDecode(getStringAsync(SHIPPING)));
        });
        var mShippingPostcode = shipping!.postcode;
        var mShippingCountry = shipping!.country;
        var mShippingState = shipping!.state;
        String? countryCode = "";
        String? stateCode = "";
        if (mShippingCountry != null && mShippingCountry.isNotEmpty) {
          countryList.forEach((element) {
            if (element.code == mShippingCountry) {
              countryCode = element.code;
              if (mShippingState != null && mShippingState.isNotEmpty) {
                if (element.states != null && element.states!.isNotEmpty) {
                  element.states!.forEach((state) {
                    if (state.code == mShippingState) {
                      stateCode = state.code;
                    }
                  });
                }
              }
            }
          });
        }
        var request = {
          "country_code": countryCode,
          "state_code": stateCode,
          "postcode": mShippingPostcode
        };
        setState(() {
          appStore.isLoading = true;
        });
        await getShippingMethod(request).then((value) {
          shippingMethodResponse = ShippingMethodResponse.fromJson(value);
          print("shippingMethodResponse->${shippingMethodResponse != null}");
          setState(() {
            loadShippingMethod();
            appStore.isLoading = false;
          });
          setState(() {});
        }).catchError((error) {
          print("error$error");
          setState(() {
            appStore.isLoading = false;
          });
          toast(error);
        });
      }
    }
  }

  loadShippingMethod() {
    setState(() {
      shippingMethods.clear();
      if (shippingMethodResponse != null &&
          shippingMethodResponse!.data!.methods != null) {
        shippingMethodResponse!.data!.methods!.forEach((method) {
          if (shouldApply(method)!) {
            shippingMethods.add(method);
          } else {
            log("Title" + method.title!);
          }
        });
        if (shippingMethods.isNotEmpty) {
          selectedShipment = 0;
        }
      }
    });
  }

  fetchCartData() async {
    setState(() {
      appStore.setLoading(true);
      isEnableCoupon = getBoolAsync(ENABLECOUPON);
    });
    await getCartList().then((res) {
      if (!mounted) return;
      setState(() {
        appStore.setLoading(false);
        mErrorMsg = '';
        mTotalCount = 0.0;
        mTotalMrpDiscount = 0.0;
        mTotalMrp = 0.0;
        mLineItems.clear();
        Iterable list = res['data'];
        mCartModelList =
            list.map((model) => CartModel.fromJson(model)).toList();
        appStore.setCount(res['total_quantity']);
        if (mCartModelList.isEmpty) {
          mErrorMsg = res['message'].toString();
          appStore.setCount(0);
        } else {
          for (var i = 0; i < mCartModelList.length; i++) {
            if (mCartModelList[i].stockStatus == "outofstock") {
              isOutOfStock = true;
            }
            var mItem = LineItems();
            mItem.proId = mCartModelList[i].proId;
            mItem.quantity = mCartModelList[i].quantity;
            mLineItems.add(mItem);
            if (mCartModelList[i].onSale) {
              mTotalCount += double.parse(mCartModelList[i].salePrice) *
                  int.parse(mCartModelList[i].quantity);
              mTotalMrpDiscount -= (double.parse(mCartModelList[i].salePrice) *
                      int.parse(mCartModelList[i].quantity)) -
                  (double.parse(mCartModelList[i].regularPrice) *
                      int.parse(mCartModelList[i].quantity));
              mTotalMrp += double.parse(mCartModelList[i].regularPrice) *
                  int.parse(mCartModelList[i].quantity);
            } else {
              mTotalCount += double.parse(
                      mCartModelList[i].regularPrice.toString().isNotEmpty
                          ? mCartModelList[i].regularPrice
                          : mCartModelList[i].price) *
                  int.parse(mCartModelList[i].quantity);
              mTotalMrp += double.parse(
                      mCartModelList[i].regularPrice.toString().isNotEmpty
                          ? mCartModelList[i].regularPrice
                          : mCartModelList[i].price) *
                  int.parse(mCartModelList[i].quantity);
            }
          }
          fetchShipmentData();
        }
      });
    }).catchError((error) {
      log(error);
      setState(() {
        appStore.setLoading(false);
        mCartModelList.clear();
        appStore.setCount(0);
        mErrorMsg = error.toString();
      });
    });
  }

  fetchPrefData() {
    setState(() {
      mCartModelList = appStore.mCartList;
      mTotalCount = 0.0;
      mTotalMrpDiscount = 0.0;
      mTotalMrp = 0.0;
      mLineItems.clear();
      if (mCartModelList.isEmpty) {
        mErrorMsg = "";
        appStore.setLoading(false);
        appStore.setCount(0);
      } else {
        appStore.setLoading(false);
        mErrorMsg = '';
        for (var i = 0; i < mCartModelList.length; i++) {
          var mItem = LineItems();
          mItem.proId = mCartModelList[i].proId;
          mItem.quantity = mCartModelList[i].quantity.toString();
          mLineItems.add(mItem);
          if (mCartModelList[i].onSale) {
            mTotalCount += double.parse(mCartModelList[i].salePrice) *
                int.parse(mCartModelList[i].quantity);
            mTotalMrpDiscount -= (double.parse(mCartModelList[i].salePrice) *
                    int.parse(mCartModelList[i].quantity)) -
                (double.parse(mCartModelList[i].regularPrice) *
                    int.parse(mCartModelList[i].quantity));
            mTotalMrp += double.parse(mCartModelList[i].regularPrice) *
                int.parse(mCartModelList[i].quantity);
          } else {
            mTotalCount += double.parse(
                    mCartModelList[i].regularPrice.toString().isNotEmpty
                        ? mCartModelList[i].regularPrice
                        : mCartModelList[i].price) *
                int.parse(mCartModelList[i].quantity);
            mTotalMrp += double.parse(
                    mCartModelList[i].regularPrice.toString().isNotEmpty
                        ? mCartModelList[i].regularPrice
                        : mCartModelList[i].price) *
                int.parse(mCartModelList[i].quantity);
          }
        }
        fetchShipmentData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future updateCartItemApi(request) async {
    updateCartItem(request).then((res) {
      setState(() {
        appStore.setLoading(false);
      });
      fetchCartData();
    }).catchError((error) {
      toast(error.toString());
      appStore.setLoading(false);
      fetchCartData();
    });
  }

  Future removeCartItemApi(proId, index) async {
    var request = {
      'pro_id': proId,
    };
    mCartModelList.removeAt(index);
    setState(() {
      appStore.isLoading = true;
    });
    removeCartItem(request).then((res) {
      fetchCartData();
    }).catchError((error) {
      fetchCartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    setValue(CARTCOUNT, appStore.count);
    var appLocalization = AppLocalizations.of(context)!;
    Widget mCartInfo = ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        return Divider(thickness: 6, color: grey.withOpacity(0.1));
      },
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: mCartModelList.length,
      itemBuilder: (context, i) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            mCartModelList[i].full == null
                ? CachedNetworkImage(
                        imageUrl:
                            mCartModelList[i].gallery.toString().validate()[0],
                        fit: BoxFit.cover,
                        height: 110,
                        width: 110)
                    .cornerRadiusWithClipRRect(8)
                : CachedNetworkImage(
                        imageUrl: mCartModelList[i].full.toString().validate(),
                        fit: BoxFit.cover,
                        height: 110,
                        width: 110)
                    .cornerRadiusWithClipRRect(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mCartModelList[i].name,
                        maxLines: 2, style: primaryTextStyle())
                    .paddingLeft(16),
                8.height,
                Row(
                  children: [
                    Row(
                      children: [
                        PriceWidget(
                          price: nf.format(
                              double.parse(mCartModelList[i].price) *
                                  double.parse(mCartModelList[i].quantity)),
                          size: 14,
                          color: primaryColor,
                        ),
                        PriceWidget(
                          price: mCartModelList[i]
                                  .regularPrice
                                  .toString()
                                  .isEmpty
                              ? ''
                              : nf.format(
                                  double.parse(mCartModelList[i].regularPrice) *
                                      double.parse(mCartModelList[i].quantity)),
                          size: 14,
                          isLineThroughEnabled: true,
                          color: Theme.of(context).textTheme.subtitle1!.color,
                        ).paddingOnly(left: 4).visible(mCartModelList[i]
                                .salePrice
                                .toString()
                                .validate()
                                .isNotEmpty &&
                            mCartModelList[i].onSale == true),
                      ],
                    ).paddingLeft(16).expand(),
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.only(left: 8, right: 4),
                      decoration: boxDecorationWithRoundedCorners(
                          border: Border.all(width: 0.1),
                          backgroundColor: context.cardColor),
                      child: Row(
                        children: [
                          Text('Qty:${mCartModelList[i].quantity}',
                              style: primaryTextStyle(size: 14)),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ).onTap(
                      () {
                        showBottomSheet(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          context: context,
                          builder: (builder) {
                            return Container(
                              height: 110,
                              decoration: boxDecorationRoundedWithShadow(8,
                                  backgroundColor: context.cardColor),
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          appLocalization
                                              .translate("txt_select_qty")!,
                                          style: boldTextStyle()),
                                      Icon(Icons.close).onTap(() {
                                        finish(context);
                                      })
                                    ],
                                  ),
                                  8.height,
                                  Container(
                                    height: 50,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: quantity.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          height: 50,
                                          width: 35,
                                          margin: EdgeInsets.all(8),
                                          alignment: Alignment.center,
                                          decoration:
                                              boxDecorationWithRoundedCorners(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  backgroundColor:
                                                      context.cardColor,
                                                  border: Border.all(
                                                      width: 0.1,
                                                      color: context
                                                          .primaryColor)),
                                          child: Text(
                                              quantity[index].toString(),
                                              style: boldTextStyle()),
                                        ).onTap(
                                          () async {
                                            finish(context);
                                            var value = quantity[index];
                                            appStore.isLoading = true;
                                            if (!await isGuestUser()) {
                                              var request = {
                                                'pro_id':
                                                    mCartModelList[i].proId,
                                                'cart_id':
                                                    mCartModelList[i].cartId,
                                                'quantity': value
                                              };
                                              updateCartItemApi(request);
                                            } else {
                                              setState(() {
                                                appStore.isLoading = false;
                                              });
                                              CartModel mCartModel =
                                                  CartModel();
                                              mCartModel.name =
                                                  mCartModelList[i].name;
                                              mCartModel.proId =
                                                  mCartModelList[i].proId;
                                              mCartModel.onSale =
                                                  mCartModelList[i].onSale;
                                              mCartModel.salePrice =
                                                  mCartModelList[i].salePrice;
                                              mCartModel.regularPrice =
                                                  mCartModelList[i]
                                                      .regularPrice;
                                              mCartModel.price =
                                                  mCartModelList[i].price;
                                              mCartModel.gallery =
                                                  mCartModelList[i].gallery;
                                              mCartModel.quantity =
                                                  value.toString();
                                              mCartModel.full =
                                                  mCartModelList[i].full;
                                              mCartModel.cartId =
                                                  mCartModelList[i].cartId;
                                              appStore.removeFromCartList(
                                                  mCartModelList[i]);
                                              appStore
                                                  .addToCartList(mCartModel);
                                              fetchPrefData();
                                            }
                                            setState(() {});
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                4.height,
                Text(appLocalization.translate('lbl_sold_out')!,
                        style: primaryTextStyle(color: Colors.red, size: 14))
                    .paddingLeft(16)
                    .visible(mCartModelList[i].stockStatus == "outofstock"),
                8.height,
                Divider(
                    thickness: 1.2, color: grey.withOpacity(0.2), indent: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.all(4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, size: 20, color: lightGrey),
                          8.width,
                          Text(appLocalization.translate("lbl_wishlist")!,
                              style: secondaryTextStyle(size: 14)),
                        ],
                      ),
                    ).onTap(() async {
                      if (!await isGuestUser()) {
                        var request = {'pro_id': mCartModelList[i].proId};
                        mCartModelList.removeAt(i);
                        setState(() {
                          appStore.isLoading = true;
                        });
                        removeCartItem(request).then((res) async {
                          setState(() {
                            appStore.isLoading = false;
                          });
                          await addWishList(request).then((res) {
                            if (!mounted) return;
                            fetchCartData();
                          }).catchError((error) {
                            setState(() {
                              toast(error.toString());
                            });
                          });
                        }).catchError((error) {
                          setState(() {
                            appStore.isLoading = false;
                          });
                          fetchCartData();
                        });
                      } else {
                        var mList = <String?>[];
                        mList.add(mCartModelList[i].full);
                        WishListResponse mWishListModel = WishListResponse();
                        mWishListModel.name = mCartModelList[i].name;
                        mWishListModel.proId = mCartModelList[i].proId;
                        mWishListModel.salePrice = mCartModelList[i].salePrice;
                        mWishListModel.regularPrice =
                            mCartModelList[i].regularPrice;
                        mWishListModel.price = mCartModelList[i].price;
                        mWishListModel.gallery = mList;
                        mWishListModel.stockQuantity = 1;
                        mWishListModel.thumbnail = "";
                        mWishListModel.full = (mCartModelList[i].full);
                        mWishListModel.sku = "";
                        mWishListModel.createdAt = "";
                        appStore.removeFromCartList(mCartModelList[i]);
                        appStore.addToMyWishList(mWishListModel);

                        setState(() {});
                      }
                    }),
                    Container(
                      height: 10,
                      color: grey.withOpacity(0.2),
                      width: 2,
                      margin: EdgeInsets.only(left: 8, right: 8),
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, size: 20, color: lightGrey),
                          8.width,
                          Text(appLocalization.translate('lbl_remove')!,
                              style: secondaryTextStyle(size: 14)),
                        ],
                      ).onTap(
                        () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:
                                    Theme.of(context).cardTheme.color,
                                content: Text(appLocalization
                                    .translate("msg_confirmation")!),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                        appLocalization
                                            .translate("lbl_cancel")!,
                                        style: secondaryTextStyle()),
                                    onPressed: () {
                                      finish(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                        appLocalization
                                            .translate("lbl_remove")!,
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () async {
                                      if (!await isGuestUser()) {
                                        removeCartItemApi(
                                            mCartModelList[i].proId, i);
                                        finish(context);
                                      } else {
                                        appStore.removeFromCartList(
                                            mCartModelList[i]);
                                        finish(context);
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                8.height,
              ],
            ).expand()
          ],
        ).paddingOnly(left: 16, right: 16, top: 8, bottom: 8).onTap(
          () {
            ProductDetailScreen(mProId: mCartModelList[i].proId)
                .launch(context);
          },
        );
      },
    );

    String getTotalAmount() {
      if (shippingMethodResponse != null &&
          shippingMethods.isNotEmpty &&
          shippingMethods[selectedShipment].cost != null &&
          shippingMethods[selectedShipment].cost!.isNotEmpty) {
        return ((mDiscountInfo != null
                    ? isCoupons
                        ? mDiscountedAmount
                        : mTotalCount
                    : mTotalCount) +
                double.parse(shippingMethods[selectedShipment].cost!))
            .toString();
      } else {
        return mDiscountInfo != null
            ? isCoupons
                ? mDiscountedAmount.toString()
                : mTotalCount.toString()
            : mTotalCount.toString();
      }
    }

    Widget mPaymentInfo() {
      return Container(
        margin: EdgeInsets.only(top: 8, bottom: 8),
        decoration: boxDecorationWithShadow(backgroundColor: context.cardColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(appLocalization.translate('lbl_price_detail')!,
                    style: boldTextStyle()),
                2.width,
                Text("(" + mCartModelList.length.toString() + " Items)",
                    style: boldTextStyle()),
              ],
            ),
            8.height,
            Divider(),
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_total_mrp')!,
                    style: secondaryTextStyle(size: textSizeMedium)),
                PriceWidget(
                    price: mTotalMrp,
                    color: Theme.of(context).textTheme.subtitle1!.color,
                    size: 16)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_discount_on_mrp')!,
                    style: secondaryTextStyle(size: textSizeMedium)),
                Row(
                  children: [
                    Text("-", style: primaryTextStyle(color: primaryColor)),
                    PriceWidget(
                        price: mTotalMrpDiscount.toStringAsFixed(2),
                        color: primaryColor,
                        size: 16),
                  ],
                ),
              ],
            ).paddingTop(6).visible(mTotalMrpDiscount != 0.0),
            6.height,
            shippingMethodResponse != null && shippingMethods.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appLocalization.translate("lbl_Shipping")!,
                          style: secondaryTextStyle(size: textSizeMedium)),
                      shippingMethods[selectedShipment].cost != null &&
                              shippingMethods[selectedShipment].cost!.isNotEmpty
                          ? PriceWidget(
                              price: shippingMethods[selectedShipment].cost,
                              color:
                                  Theme.of(context).textTheme.subtitle1!.color,
                              size: 16)
                          : Text(appLocalization.translate('lbl_free')!,
                              style: boldTextStyle(color: Colors.green))
                    ],
                  )
                : SizedBox(),
            spacing_standard.height,
            SizedBox(
                width: context.width(),
                child: DashedRect(gap: 3, color: greyColor)),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_total_amount_')!,
                    style: boldTextStyle(color: greenColor)),
                PriceWidget(
                    price: getTotalAmount(),
                    size: textSizeMedium.toDouble(),
                    color: greenColor),
              ],
            ),
            spacing_standard_new.height,
          ],
        ).paddingAll(16),
      );
    }

    Widget _shipping = getBoolAsync(IS_GUEST_USER) == true ||
            shipping != null && shippingMethodResponse != null
        ? Container(
            margin: EdgeInsets.only(top: 8, bottom: 8),
            decoration:
                boxDecorationWithShadow(backgroundColor: context.cardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(appLocalization.translate("lbl_Shipping")!,
                        style: boldTextStyle()),
                    Text(appLocalization.translate("lbl_change")!,
                            style: secondaryTextStyle(
                                color: primaryColor, size: textSizeSMedium))
                        .onTap(() async {
                      bool isChanged =
                          await (EditProfileScreen().launch(context));
                      if (isChanged) {
                        setState(() {
                          countryList.clear();
                          appStore.isLoading = true;
                          shippingMethodResponse = null;
                        });
                        init();
                      }
                      setState(() {});
                    }),
                  ],
                ),
                6.height,
                shippingMethods.isNotEmpty
                    ? Text(shipping!.getAddress()!,
                            style: secondaryTextStyle(size: 16))
                        .visible(shipping!.getAddress()!.isNotEmpty)
                    : SizedBox(),
                shippingMethods.isNotEmpty
                    ? Text(
                        appLocalization
                            .translate('lbl_please_update_shipping_address')!,
                        style: primaryTextStyle(
                            color:
                                Theme.of(context).textTheme.subtitle1!.color),
                      ).paddingTop(8).visible(shipping!.getAddress()!.isEmpty)
                    : SizedBox(),
                shippingMethods.isNotEmpty
                    ? ListView.builder(
                        itemCount: shippingMethods.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 8),
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          Method method = shippingMethods[index];
                          return Column(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                    unselectedWidgetColor:
                                        Theme.of(context).iconTheme.color),
                                child: RadioListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  dense: true,
                                  activeColor: primaryColor,
                                  toggleable: true,
                                  value: index,
                                  groupValue: _currentTimeValue,
                                  onChanged: (dynamic ind) {
                                    setState(() {
                                      _currentTimeValue = ind;
                                      selectedShipment = index;
                                    });
                                  },
                                  title: Row(
                                    children: [
                                      Text(
                                          method.id != "free_shipping"
                                              ? method.methodTitle! + ":"
                                              : method.methodTitle!,
                                          style: primaryTextStyle()),
                                      Text(
                                              getStringAsync(DEFAULT_CURRENCY) +
                                                  method.cost.toString(),
                                              style: primaryTextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2!
                                                      .color))
                                          .paddingLeft(8)
                                          .visible(method.id != "free_shipping")
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ).visible(shipping!.getAddress()!.isNotEmpty)
                    : Text(appLocalization.translate('lbl_free_shipping')!,
                        style: primaryTextStyle())
              ],
            ).paddingAll(16),
          )
        : Container();

    Widget mBody = Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 200),
          child: Column(
            children: [mCartInfo, _shipping, mPaymentInfo()],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Theme.of(context).hoverColor.withOpacity(0.8),
                    blurRadius: 15.0,
                    offset: Offset(0.20, 0.75))
              ],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PriceWidget(
                        price: getTotalAmount(),
                        size: textSizeMedium.toDouble(),
                        color: Theme.of(context).textTheme.subtitle2!.color),
                    8.height,
                    Text(appLocalization.translate('lbl_view_details')!,
                            style: primaryTextStyle(color: primaryColor))
                        .onTap(() {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          curve: Curves.easeOut,
                          duration: Duration(milliseconds: 300));
                    })
                  ],
                ).expand(),
                spacing_standard_new.height,
                AppButton(
                  text: appLocalization.translate('lbl_place_order'),
                  textStyle: primaryTextStyle(color: white),
                  color: primaryColor,
                  onTap: () async {
                    ShippingLines? shippingLine;
                    Method? method;
                    if (isOutOfStock == false) {
                      if (shippingMethodResponse != null &&
                          !appStore.isLoading! &&
                          shipping!.getAddress()!.isNotEmpty) {
                        if (shippingMethodResponse != null &&
                            shippingMethods.isNotEmpty) {
                          method = shippingMethods[selectedShipment];
                          shippingLine = ShippingLines(
                              methodId: shippingMethods[selectedShipment].id,
                              methodTitle:
                                  shippingMethods[selectedShipment].methodTitle,
                              total: shippingMethods[selectedShipment].cost);
                        }
                        //   if (getStringAsync(TOKEN) != null) {
                        OrderSummaryScreen(
                                mCartProduct: mCartModelList,
                                mCouponData: mDiscountInfo != null && isCoupons
                                    ? mDiscountInfo['code']
                                    : '',
                                mPrice: getTotalAmount().toString(),
                                shippingLines: shippingLine,
                                method: method,
                                subtotal: mTotalMrp,
                                discount: isCoupons ? mTotalDiscount : 0,
                                mRPDiscount: mTotalMrpDiscount)
                            .launch(context);
                        // } else {
                        //   SignInScreen().launch(context);
                        // }
                      } else {
                        print("in edite Page");
                        appStore.isLoading = false;
                        toast(appLocalization
                            .translate('lbl_please_add_shipping_details'));
                        bool isChanged =
                            await (EditProfileScreen().launch(context));
                        if (isChanged) {
                          setState(() {
                            countryList.clear();
                            appStore.isLoading = true;
                            shippingMethodResponse = null;
                          });
                          init();
                        }
                        setState(() {});
                      }
                    } else {
                      toast(appLocalization
                          .translate('lbl_confirmation_sold_out'));
                    }
                  },
                ).expand(),
              ],
            ).paddingAll(16),
          ),
        )
      ],
    ).visible(mCartModelList.isNotEmpty);

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_my_cart'),
                showBack: widget.isShowBack! ? true : false)
            as PreferredSizeWidget?,
        body: Stack(
          children: [
            !mIsLoggedIn
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(ic_empty_shopping_cart,
                          height: 100,
                          width: 100,
                          color: textPrimaryColorGlobal.withOpacity(0.3)),
                      20.height,
                      Text(appLocalization.translate("msg_empty_basket")!,
                              style: boldTextStyle(size: 22),
                              textAlign: TextAlign.center)
                          .paddingOnly(left: 20, right: 20),
                      8.height,
                      Text(
                              appLocalization
                                  .translate("msg_empty_basket_massage")!,
                              style: primaryTextStyle(),
                              textAlign: TextAlign.center)
                          .paddingOnly(left: 20, right: 20),
                      24.height,
                      AppButton(
                              width: context.width(),
                              text: appLocalization.translate('lbl_start_shopping'),
                              textStyle: primaryTextStyle(color: white),
                              color: primaryColor,
                              onTap: () {
                                DashBoardScreen().launch(context);
                              })
                          .paddingAll(spacing_standard_new.toDouble())
                          .paddingOnly(left: 20, right: 20),
                    ],
                  ).visible(!appStore.isLoading!)
                : Stack(
                    children: [
                      mBody.visible(mCartModelList.isNotEmpty),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(ic_empty_shopping_cart,
                              height: 100,
                              width: 100,
                              color: textPrimaryColorGlobal.withOpacity(0.3)),
                          20.height,
                          Text(appLocalization.translate("msg_empty_basket")!,
                                  style: boldTextStyle(size: 22),
                                  textAlign: TextAlign.center)
                              .paddingOnly(left: 20, right: 20),
                          8.height,
                          Text(
                                  appLocalization
                                      .translate("msg_empty_basket_massage")!,
                                  style: primaryTextStyle(),
                                  textAlign: TextAlign.center)
                              .paddingOnly(left: 20, right: 20),
                          24.height,
                          AppButton(
                                  width: context.width(),
                                  text: appLocalization
                                      .translate('lbl_start_shopping'),
                                  textStyle: primaryTextStyle(color: white),
                                  color: primaryColor,
                                  onTap: () {
                                    DashBoardScreen().launch(context);
                                  })
                              .paddingAll(spacing_standard_new.toDouble())
                              .paddingOnly(left: 20, right: 20),
                        ],
                      ).center().visible(mCartModelList.isEmpty),
                      mProgress().center().visible(appStore.isLoading!),
                    ],
                  ).visible(mIsLoggedIn && !appStore.isLoading!),
            Center(child: mProgress()).visible(appStore.isLoading!)
          ],
        ),
      ),
    );
  }

  // ignore: missing_return
  bool? shouldApply(Method method) {
    if (method.enabled == "yes") {
      if (method.id == "free_shipping") {
        if (method.requires!.isEmpty) {
          return true;
        } else {
          if (method.requires == "min_amount") {
            return freeShippingOnMinAmount(method);
          } else if (method.requires == "coupon") {
            return freeShippingOnCoupon(method);
          } else if (method.requires == "either") {
            return freeShippingOnMinAmount(method) == true ||
                freeShippingOnCoupon(method) == true;
          } else if (method.requires == "both") {
            return freeShippingOnMinAmount(method) == true &&
                freeShippingOnCoupon(method) == true;
          }
        }
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  bool? freeShippingOnMinAmount(Method method) {
    return isCoupons
        ? method.instanceSettings!.ignoreDiscounts == "yes"
            ? mTotalCount >= double.parse(method.minAmount!)
            : mDiscountedAmount >= double.parse(method.minAmount!)
        : mTotalCount >= double.parse(method.minAmount!);
  }

  bool? freeShippingOnCoupon(Method method) {
    if (isCoupons && mDiscountInfo != null) {
      return mDiscountInfo['free_shipping'];
    } else {
      return false;
    }
  }
}
