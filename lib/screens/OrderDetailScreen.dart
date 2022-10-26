import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/Coupon_lines.dart';
import '../model/OrderModel.dart';
import '../model/OrderTracking.dart';
import '../model/TrackingResponse.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/dashed_ract.dart';
import '../utils/images.dart';

import '../app_localizations.dart';
import '../main.dart';
import '../utils/constants.dart';
import 'OrderListScreen.dart';
import 'ProductDetailScreen.dart';
import 'ExternalProductScreen.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';
  final OrderResponseModel? mOrderModel;

  OrderDetailScreen({Key? key, this.mOrderModel}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<OrderResponseModel> mOrderModel = [];
  List<OrderTracking> mOrderTrackingModel = [];
  List<TrackingResponse> mGetTrackingModel = [];
  List mCancelList = [
    "cancel_list_msg1",
    "cancel_list_msg2",
    "cancel_list_msg3",
    "cancel_list_msg4",
    "cancel_list_msg5",
    "cancel_list_msg6",
  ].toList();

  NumberFormat nf = NumberFormat('##.00');
  String? mValue = "";
  String? value = "";

  @override
  void initState() {
    super.initState();
    init();
    fetchTrackingData();
    getTracking();
  }

  init() async {
    if (widget.mOrderModel!.metaData != null) {
      widget.mOrderModel!.metaData!.forEach((element) {
        if (element.key == "delivery_date") {
          value = element.value;
          log("element:- $value");
        }
      });
    } else {
      value = "";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future fetchTrackingData() async {
    setState(() {
      appStore.isLoading = true;
    });
    await getOrdersTracking(widget.mOrderModel!.id).then((res) {
      if (!mounted) return;
      appStore.isLoading = false;
      setState(() {
        Iterable mCategory = res;
        mOrderTrackingModel =
            mCategory.map((model) => OrderTracking.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        toast(error.toString());
      });
    });
  }

  Future getTracking() async {
    setState(() {
      appStore.isLoading = true;
    });
    await getTrackingInfo(widget.mOrderModel!.id).then((res) {
      if (!mounted) return;
      appStore.isLoading = false;
      setState(() {
        Iterable mTracking = res;
        mGetTrackingModel =
            mTracking.map((model) => TrackingResponse.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        toast(error.toString());
      });
    });
  }

  void cancelOrderData(String? mValue) async {
    setState(() {
      appStore.isLoading = true;
    });
    var request = {
      "status": "cancelled",
      "customer_note": mValue,
    };
    await cancelOrder(widget.mOrderModel!.id, request).then((res) {
      if (!mounted) return;
      setState(() {
        var request = {
          'customer_note': true,
          'note': "{\n" +
              "\"status\":\"Cancelled\",\n" +
              "\"message\":\"Order Canceled by you due to " +
              mValue! +
              ".\"\n" +
              "} ",
        };
        createOrderNotes(widget.mOrderModel!.id, request).then((res) {
          if (!mounted) return;
          appStore.isLoading = false;
          setState(() {
            finish(context, true);
          });
        }).catchError((error) {
          if (!mounted) return;
          setState(() {
            appStore.isLoading = false;
            finish(context, true);
            toast(error.toString());
          });
        });
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        toast(error.toString());
        finish(context, true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    Widget mData(OrderTracking orderTracking) {
      Tracking tracking;
      try {
        var x = jsonDecode(orderTracking.note!) as Map<String, dynamic>;
        tracking = Tracking.fromJson(x);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(tracking.status.validate(), style: boldTextStyle()),
            Text(tracking.message.validate(), style: secondaryTextStyle())
          ],
        );
      } on FormatException catch (e) {
        log(e);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(appLocalization.translate('lbl_by_admin')!,
                style: boldTextStyle()),
            Text(orderTracking.note.validate(),
                style: secondaryTextStyle(size: 16)),
          ],
        );
      }
    }

    Widget mTracking() {
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: mOrderTrackingModel.length,
        itemBuilder: (context, i) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: primaryColor, borderRadius: radius(16)),
                  ),
                  SizedBox(
                      height: 100,
                      child: DashedRect(gap: 2, color: primaryColor)),
                ],
              ),
              8.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  mData(mOrderTrackingModel[i]),
                  8.height,
                  Text(
                      convertDate(
                          mOrderTrackingModel[i].dateCreated.validate()),
                      style: secondaryTextStyle()),
                ],
              ).expand()
            ],
          );
        },
      );
    }

    Widget mCancelOrder(BuildContext context) {
      if (widget.mOrderModel!.status == COMPLETED ||
          widget.mOrderModel!.status == REFUNDED ||
          widget.mOrderModel!.status == CANCELED ||
          widget.mOrderModel!.status == TRASH ||
          widget.mOrderModel!.status == FAILED) {
        return SizedBox();
      } else {
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              builder: (context) {
                return BottomSheet(
                  backgroundColor: context.cardColor,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return Container(
                          height: 500,
                          padding: EdgeInsets.all(16),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                          appLocalization
                                              .translate("title_cancel_order")!,
                                          style: boldTextStyle())
                                      .expand(),
                                  Icon(Icons.close).onTap(() {
                                    finish(context);
                                  })
                                ],
                              ),
                              24.height,
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: mCancelList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      mValue = appLocalization
                                          .translate(mCancelList[index])!;
                                      print(mValue);
                                      setState(() {
                                        appStore.setCancelItemIndex(index);
                                        print(appStore.cancelOrderIndex
                                            .toString());
                                      });
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            decoration:
                                                boxDecorationWithRoundedCorners(
                                              borderRadius: radius(4),
                                              border: Border.all(
                                                  color: primaryColor!),
                                              backgroundColor:
                                                  appStore.cancelOrderIndex ==
                                                          index
                                                      ? primaryColor!
                                                      : context.cardColor,
                                            ),
                                            width: 16,
                                            height: 16,
                                            child: Icon(Icons.done,
                                                size: 12,
                                                color: context.cardColor)),
                                        4.width,
                                        Text(
                                                appLocalization.translate(
                                                    mCancelList[index])!,
                                                style: primaryTextStyle())
                                            .paddingLeft(
                                                spacing_standard.toDouble())
                                            .expand(),
                                      ],
                                    ).paddingOnly(top: 8, bottom: 8),
                                  );
                                },
                              ),
                              24.height,
                              AppButton(
                                width: context.width(),
                                textStyle: primaryTextStyle(color: white),
                                text: appLocalization
                                    .translate('lbl_cancel_order'),
                                color: primaryColor,
                                onTap: () {
                                  Navigator.pop(context);
                                  appStore.isLoading = true;
                                  setState(() {});
                                  cancelOrderData(mValue);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  onClosing: () {},
                );
              },
            );
          },
          child: Container(
            padding: EdgeInsets.only(
                top: spacing_middle.toDouble(),
                bottom: spacing_middle.toDouble()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_cancel_order')!,
                        style: primaryTextStyle(color: primaryColor))
                    .expand(),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      }
    }

    Widget mBody(BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: context.width(),
              decoration:
                  boxDecorationWithShadow(backgroundColor: context.cardColor),
              margin: EdgeInsets.only(bottom: 8, top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  commonCacheImageWidget(
                          widget
                              .mOrderModel!.lineItems![0].productImages![0].src,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(8)
                      .paddingOnly(top: 16, bottom: 16, left: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.mOrderModel!.lineItems![0].name!,
                          style: primaryTextStyle(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5),
                      6.height,
                      PriceWidget(
                          price: widget.mOrderModel!.lineItems![0].total
                              .toString(),
                          size: 16,
                          color: greenColor.withOpacity(0.8)),
                      8.height,
                      Text(widget.mOrderModel!.status!.toUpperCase(),
                          style: boldTextStyle(
                              color: statusColor(widget.mOrderModel!.status!))),
                    ],
                  )
                      .paddingOnly(top: 20, bottom: 16, left: 10, right: 16)
                      .expand()
                ],
              ),
            ),
            Container(
                width: context.width(),
                decoration:
                    boxDecorationWithShadow(backgroundColor: context.cardColor),
                margin: EdgeInsets.only(bottom: 8, top: 8),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(ic_tracking,
                        height: 30, width: 30, color: textPrimaryColorGlobal),
                    10.width,
                    createRichText(list: [
                      TextSpan(
                          text: appLocalization.translate('lbl_deliver_on')! +
                              " ",
                          style: primaryTextStyle()),
                      TextSpan(
                          text: createDateFormat(value),
                          style: primaryTextStyle(color: primaryColor!)),
                    ])
                  ],
                )).visible(value!.isNotEmpty),
            GestureDetector(
              onTap: () {
                ExternalProductScreen(
                        mExternal_URL: mGetTrackingModel[0].trackingLink,
                        title: "Track your order")
                    .launch(context);
              },
              child: Container(
                width: context.width(),
                decoration:
                    boxDecorationWithShadow(backgroundColor: context.cardColor),
                margin: EdgeInsets.only(top: 8, bottom: 8),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(ic_tracking,
                        height: 30, width: 30, color: textPrimaryColorGlobal),
                    16.width,
                    Text(appLocalization.translate('lbl_tracking_tap')!,
                            style: primaryTextStyle())
                        .expand(),
                  ],
                ),
              ).visible(mGetTrackingModel.isNotEmpty &&
                  (widget.mOrderModel!.status == "pending" ||
                      widget.mOrderModel!.status == "processing" ||
                      widget.mOrderModel!.status == "on-hold")),
            ),
            Container(
              width: context.width(),
              decoration:
                  boxDecorationWithShadow(backgroundColor: context.cardColor),
              margin: EdgeInsets.only(top: 8, bottom: 8),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(appLocalization.translate('lbl_delivery_address')!,
                      style: boldTextStyle()),
                  8.height,
                  Text(
                      widget.mOrderModel!.shipping!.firstName! +
                          " " +
                          widget.mOrderModel!.shipping!.lastName!,
                      style: primaryTextStyle()),
                  2.height,
                  Text(
                      widget.mOrderModel!.shipping!.address1! +
                          " " +
                          widget.mOrderModel!.shipping!.city! +
                          " " +
                          widget.mOrderModel!.shipping!.country! +
                          " " +
                          widget.mOrderModel!.shipping!.state!,
                      style: secondaryTextStyle()),
                ],
              ),
            ),
            Container(
              decoration:
                  boxDecorationWithShadow(backgroundColor: context.cardColor),
              margin: EdgeInsets.only(top: 8, bottom: 8),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appLocalization.translate("lbl_total_order_price")!,
                        style:
                            boldTextStyle(color: greenColor.withOpacity(0.8)),
                      ),
                      PriceWidget(
                          price: widget.mOrderModel!.total,
                          size: 14,
                          color: greenColor.withOpacity(0.8)),
                    ],
                  ),
                  6.height,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(appLocalization.translate("lbl_view_details")!,
                            style:
                                boldTextStyle(size: 14, color: primaryColor!))
                        .onTap(() {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        builder: (BuildContext context) {
                          return Container(
                            height: 330,
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        appLocalization
                                            .translate('lbl_payment_detail')!
                                            .validate(),
                                        style: boldTextStyle(
                                            color: primaryColor!)),
                                    Icon(Icons.close_rounded).onTap(() {
                                      finish(context);
                                    }),
                                  ],
                                ).paddingOnly(top: 8, bottom: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        appLocalization
                                            .translate('lbl_total_mrp')!,
                                        style: secondaryTextStyle(size: 16)),
                                    PriceWidget(
                                        price: widget.mOrderModel!.total,
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .color,
                                        size: 16)
                                  ],
                                ).paddingOnly(top: 8, bottom: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        appLocalization
                                            .translate('lbl_discount_on_mrp')!,
                                        style: secondaryTextStyle(size: 16)),
                                    Row(
                                      children: [
                                        Text("-",
                                            style: primaryTextStyle(
                                                color: primaryColor)),
                                        PriceWidget(
                                            price: widget
                                                .mOrderModel!.discountTotal,
                                            color: primaryColor,
                                            size: 16),
                                      ],
                                    ),
                                  ],
                                ).paddingOnly(top: 8, bottom: 8).visible(
                                    widget.mOrderModel!.discountTotal.toInt() !=
                                        0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        appLocalization
                                            .translate('lbl_shipping_fee')!,
                                        style: secondaryTextStyle(size: 16)),
                                    PriceWidget(
                                        price:
                                            widget.mOrderModel!.shippingTotal,
                                        color: primaryColor,
                                        size: 16)
                                  ],
                                ).paddingOnly(top: 8, bottom: 8),
                                SizedBox(
                                    width: context.width(),
                                    child: DashedRect(
                                      gap: 3,
                                      color: greyColor,
                                    )),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        appLocalization
                                            .translate('lbl_total_amount_')!,
                                        style: boldTextStyle(
                                            size: 18, color: greenColor)),
                                    PriceWidget(
                                        price: widget.mOrderModel!.total,
                                        size: 18,
                                        color: greenColor),
                                  ],
                                ).paddingOnly(top: 16, bottom: 8),
                                16.height,
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 16),
                                  width: context.width(),
                                  alignment: Alignment.center,
                                  decoration: boxDecorationWithRoundedCorners(
                                      backgroundColor: context.cardColor,
                                      border: Border.all(width: 0.2)),
                                  child: Row(
                                    children: [
                                      if (widget.mOrderModel!.paymentMethod ==
                                          "Cash On Delivery")
                                        Image.asset(ic_cod,
                                            height: 30, width: 30)
                                      else if (widget
                                              .mOrderModel!.paymentMethod ==
                                          "RazorPay")
                                        Image.asset(ic_razor_pay,
                                            height: 35, width: 35)
                                      else
                                        Image.asset(
                                          ic_web_payment,
                                          height: 30,
                                          width: 30,
                                          color: textSecondaryColour,
                                        ),
                                      8.width,
                                      Text(
                                          widget.mOrderModel!.paymentMethod
                                              .toString(),
                                          style: boldTextStyle()),
                                    ],
                                  ),
                                ).paddingOnly(top: 8, bottom: 8)
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  )
                ],
              ),
            ),
            Container(
              width: context.width(),
              decoration:
                  boxDecorationWithShadow(backgroundColor: context.cardColor),
              margin: EdgeInsets.only(top: 8, bottom: 8),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  mTracking(),
                  mCancelOrder(context),
                ],
              ),
            ).visible(mOrderTrackingModel.isNotEmpty),
            Container(
              width: context.width(),
              decoration:
                  boxDecorationWithShadow(backgroundColor: context.cardColor),
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  spacing_standard.height,
                  Text(appLocalization.translate('lbl_other_item_in_cart')!,
                      style: boldTextStyle()),
                  4.height,
                  Text(
                      appLocalization.translate('lbl_order_id')! +
                          widget.mOrderModel!.id.toString(),
                      style: secondaryTextStyle()),
                  8.height,
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.mOrderModel!.lineItems!.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          ProductDetailScreen(
                                  mProId: widget
                                      .mOrderModel!.lineItems![i].productId)
                              .launch(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          decoration: boxDecorationWithShadow(
                              borderRadius: radius(8.0),
                              backgroundColor: context.scaffoldBackgroundColor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              commonCacheImageWidget(
                                widget.mOrderModel!.lineItems![i]
                                    .productImages![0].src
                                    .validate(),
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRect(8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.mOrderModel!.lineItems![i].name!,
                                      style: primaryTextStyle(size: 14),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5),
                                  8.height,
                                  Row(
                                    children: [
                                      PriceWidget(
                                        price: widget
                                            .mOrderModel!.lineItems![i].total
                                            .toString(),
                                        size: 14,
                                        color: primaryColor!.withOpacity(0.8),
                                      ).expand(),
                                      4.width,
                                      Text(
                                        appLocalization.translate('lbl_qty')! +
                                            " " +
                                            widget.mOrderModel!.lineItems![i]
                                                .quantity
                                                .toString(),
                                        style: primaryTextStyle(
                                            size: 14,
                                            color:
                                                primaryColor!.withOpacity(0.8)),
                                      ),
                                    ],
                                  )
                                ],
                              )
                                  .paddingOnly(
                                      left: spacing_standard_new.toDouble(),
                                      right: spacing_standard_new.toDouble(),
                                      top: spacing_control.toDouble())
                                  .expand()
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  8.height,
                  createRichText(list: [
                    TextSpan(
                        text: appLocalization.translate('lbl_you_saved')! + " ",
                        style: secondaryTextStyle()),
                    TextSpan(
                        text: widget.mOrderModel!.discountTotal,
                        style: boldTextStyle(
                            color: Theme.of(context).accentColor)),
                    TextSpan(
                        text: " " +
                            appLocalization.translate('lbl_on_this_order')!,
                        style: secondaryTextStyle()),
                  ]).visible(
                      int.parse(widget.mOrderModel!.discountTotal.toString()) >
                          0),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: mTop(context, appLocalization.translate('lbl_order_details'),
              showBack: true) as PreferredSizeWidget?,
          body: Stack(
            children: [
              mBody(context),
              mProgress().center().visible(appStore.isLoading!),
            ],
          )),
    );
  }
}
