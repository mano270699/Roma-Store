import '../model/OrderModel.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../main.dart';
import '../utils/constants.dart';
import 'DashBoardScreen.dart';
import 'OrderDetailScreen.dart';

class OrderList extends StatefulWidget {
  static String tag = '/OrderList';

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<OrderResponseModel>? mOrderModel = [];
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future fetchOrderData() async {
    setState(() {
      appStore.isLoading = true;
    });

    await getOrders().then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        log("response $res");
        Iterable mOrderDetails = res;
        log("response $mOrderDetails");
        mOrderModel = mOrderDetails
            .map((model) => OrderResponseModel.fromJson(model))
            .toList();
        log("orderDetail: $mOrderModel");
      });
    }).catchError((error) {
      if (!mounted) return;
      log(error);
      setState(() {
        appStore.isLoading = false;
        mOrderModel!.clear();
        mErrorMsg = error.toString();
        log("Test " + error.toString());
      });
    });
  }

  init() async {
    fetchOrderData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    Widget mBody = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: mOrderModel!.length,
        itemBuilder: (context, i) {
          return Container(
            margin: EdgeInsets.only(top: 8, bottom: 8),
            decoration:
                boxDecorationWithShadow(backgroundColor: context.cardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                10.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (mOrderModel![i].lineItems!.isNotEmpty.validate())
                      if (mOrderModel![i]
                          .lineItems![0]
                          .productImages![0]
                          .src!
                          .isNotEmpty
                          .validate())
                        commonCacheImageWidget(
                                mOrderModel![i]
                                    .lineItems![0]
                                    .productImages![0]
                                    .src
                                    .validate(),
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover)
                            .cornerRadiusWithClipRRect(8),
                    10.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        8.height,
                        if (mOrderModel![i].lineItems!.isNotEmpty)
                          if (mOrderModel![i].lineItems!.length > 1)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    mOrderModel![i]
                                        .lineItems![0]
                                        .name
                                        .validate(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: primaryTextStyle()),
                                4.height,
                                Text(
                                    appLocalization
                                        .translate("lbl_more_items")
                                        .toString(),
                                    style: secondaryTextStyle(
                                        color: primaryColor!.withOpacity(0.5))),
                              ],
                            )
                          else
                            Text(mOrderModel![i].lineItems![0].name.validate(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: primaryTextStyle())
                        else
                          Text(mOrderModel![i].id.toString().validate(),
                              style:
                                  primaryTextStyle(size: textSizeLargeMedium)),
                        6.height,
                        Row(
                          children: [
                            PriceWidget(
                                    price: mOrderModel![i].total.toString(),
                                    size: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .color)
                                .expand(),
                            Text(
                                mOrderModel![i]
                                    .status!
                                    .toUpperCase()
                                    .toString(),
                                style: boldTextStyle(
                                    color: statusColor(mOrderModel![i].status)))
                          ],
                        ),
                      ],
                    ).expand(),
                  ],
                ),
                10.height,
              ],
            ).paddingOnly(left: 10, right: 10).onTap(() async {
              bool? isChanged =
                  await OrderDetailScreen(mOrderModel: mOrderModel![i])
                      .launch(context);
              if (isChanged != null) {
                setState(() {
                  appStore.isLoading = true;
                });
                init();
              }
            }),
          );
        });

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_orders'),
            showBack: true) as PreferredSizeWidget?,
        body: mInternetConnection(
          Stack(
            children: [
              mOrderModel!.isNotEmpty
                  ? mBody
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(ic_order, height: 250, width: 250),
                        Text(appLocalization.translate("msg_empty_order")!,
                                style: primaryTextStyle(size: 18),
                                textAlign: TextAlign.center)
                            .paddingOnly(left: 20, right: 20),
                        4.height,
                        Text(appLocalization.translate("msg_info_empty_order")!,
                                style: secondaryTextStyle(size: 14),
                                textAlign: TextAlign.center)
                            .paddingOnly(left: 20, right: 20),
                        30.height,
                        Container(
                          width: context.width(),
                          child: AppButton(
                              width: context.width(),
                              textStyle: primaryTextStyle(color: white),
                              text: appLocalization
                                  .translate('lbl_start_shopping'),
                              color: primaryColor,
                              onTap: () {
                                DashBoardScreen().launch(context);
                              }),
                        ).paddingOnly(left: 20, right: 20),
                      ],
                    ).visible(!appStore.isLoading! && mErrorMsg.isEmpty),
              mProgress().center().visible(appStore.isLoading!),
              Text(mErrorMsg,
                      style: primaryTextStyle(), textAlign: TextAlign.center)
                  .visible(!appStore.isLoading!)
                  .center()
                  .visible(mErrorMsg.isNotEmpty),
            ],
          ),
        ),
      ),
    );
  }
}

Color statusColor(String? status) {
  Color color = primaryColor!;
  switch (status) {
    case "pending":
      return pendingColor;
    case "processing":
      return processingColor;
    case "on-hold":
      return primaryColor!;
    case "completed":
      return completeColor;
    case "cancelled":
      return cancelledColor;
    case "refunded":
      return refundedColor;
    case "failed":
      return failedColor;
    case "any":
      return primaryColor!;
  }
  return color;
}
