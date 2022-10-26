import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../model/CartModel.dart';
import '../model/Coupon_lines.dart';
import '../model/CreateOrderRequestModel.dart';
import '../model/CustomerResponse.dart';
import '../model/OrderModel.dart';
import '../model/ShippingMethodResponse.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'SignInScreen.dart';
import '../utils/dashed_ract.dart';
import '../utils/images.dart';
import '../utils/shared_pref.dart';
import '../app_localizations.dart';
import '../main.dart';
import 'DashBoardScreen.dart';
import 'WebViewPaymentScreen.dart';

class OrderSummaryScreen extends StatefulWidget {
  static String tag = '/OrderSummaryScreen';

  final List<CartModel>? mCartProduct;
  final mCouponData;
  final mPrice;
  final bool isNativePayment = false;
  final ShippingLines? shippingLines;
  final Method? method;
  final double? subtotal;
  final double? mRPDiscount;
  final double? discount;

  OrderSummaryScreen(
      {Key? key,
      this.mCartProduct,
      this.mCouponData,
      this.mPrice,
      this.shippingLines,
      this.method,
      this.subtotal,
      this.mRPDiscount,
      this.discount})
      : super(key: key);

  @override
  OrderSummaryScreenState createState() => OrderSummaryScreenState();
}

class OrderSummaryScreenState extends State<OrderSummaryScreen> {
  static const platform = const MethodChannel("razorpay_flutter");

  var mPaymentList = ["RazorPay", "Cash On Delivery"];

  late Razorpay _razorPay;
  Method? method;
  NumberFormat nf = NumberFormat('##.00');

  String? mShippingFirstName,
      mShippingLastName,
      mShippingCompany,
      mShippingAddress,
      mShippingAddress2,
      mShippingCity,
      mShippingPostcode,
      mShippingCountry,
      mShippingState;
  String? mBillingFirstName,
      mBillingLastName,
      mBillingAddress,
      mBillingAddress2,
      mBillingCompany,
      mBillingCity,
      mBillingPostcode,
      mBillingCountry,
      mBillingState,
      mBillingPhone,
      mBillingEmail;

  bool isNativePayment = false;
  bool? selectedCashDelivery;

  var mUserId, mCurrency;
  var mBilling, mShipping;
  var id;
  var isEnableCoupon;

  int? _currentTimeValue = 1;

  @override
  void initState() {
    super.initState();
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    init();
  }

  init() async {
    selectedCashDelivery = true;

    if (getStringAsync(PAYMENTMETHOD) == PAYMENT_METHOD_NATIVE) {
      isNativePayment = true;
    } else {
      isNativePayment = false;
    }
    mShipping = jsonDecode(getStringAsync(SHIPPING)) ?? "";
    if (mShipping != null) {
      mShippingFirstName = mShipping['first_name'];
      mShippingLastName = mShipping['last_name'];
      mShippingCompany = mShipping['company'];
      mShippingAddress = mShipping['address_1'];
      mShippingAddress2 = mShipping['address_2'];
      mShippingCity = mShipping['city'];
      mShippingPostcode = mShipping['postcode'];
      mShippingCountry = mShipping['country'];
      mShippingState = mShipping['state'];
    }
    mBilling = jsonDecode(getStringAsync(BILLING));

    if (mBilling != null) {
      mBillingFirstName = mBilling['first_name'];
      mBillingLastName = mBilling['last_name'];
      mBillingCompany = mBilling['company'];
      mBillingAddress = mBilling['address_1'];
      mBillingAddress2 = mBilling['address_2'];
      mBillingCity = mBilling['city'];
      mBillingPostcode = mBilling['postcode'];
      mBillingCountry = mBilling['country'];
      mBillingState = mBilling['state'];
      mBillingEmail = mBilling['email'];
      mBillingPhone = mBilling['phone'];
    }
    mUserId = getIntAsync(USER_ID);
    mCurrency = getStringAsync(DEFAULT_CURRENCY);
    setState(() {});
  }

  Future createOrderTracking(var mOrderId) async {
    setState(() {
      appStore.isLoading = true;
    });
    var request = {
      'customer_note': true,
      'note': "{\n" +
          "\"status\":\"Ordered\",\n" +
          "\"message\":\"Your order has been placed.\"\n" +
          "} ",
    };
    await createOrderNotes(mOrderId, request).then((res) {
      if (!mounted) return;
      appStore.isLoading = false;
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        toast(error.toString());
      });
    });
  }

  void createNativeOrder(String mPaymethod) async {
    hideKeyboard(context);

    var appLocalization = AppLocalizations.of(context)!;
    var mBilling = Billing();
    mBilling.firstName = mBillingFirstName;
    mBilling.lastName = mBillingLastName;
    mBilling.company = mBillingCompany;
    mBilling.address1 = mBillingAddress;
    mBilling.address2 = mBillingAddress2;
    mBilling.city = mBillingCity;
    mBilling.postcode = mBillingPostcode;
    mBilling.country = mBillingCountry;
    mBilling.state = mBillingState;
    mBilling.email = mBillingEmail;
    mBilling.phone = mBillingPhone;

    var mShipping = Shipping();
    mShipping.firstName = mShippingFirstName;
    mShipping.lastName = mShippingLastName;
    mShipping.company = mShippingCompany;
    mShipping.address1 = mShippingAddress;
    mShipping.address2 = mShippingPostcode;
    mShipping.city = mShippingCity;
    mShipping.state = mShippingState;
    mShipping.postcode = mShippingPostcode;
    mShipping.country = mShippingCountry;

    List<LineItemsRequest> lineItems = [];
    List<ShippingLines?> shipping = [];
    widget.mCartProduct!.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.productId = item.proId;
      lineItem.quantity = item.quantity;
      lineItem.variationId = item.proId;
      lineItems.add(lineItem);
    });

    var couponCode = widget.mCouponData;
    List<CouponLines> mCouponItems = [];
    if (couponCode.isNotEmpty) {
      var mCoupon = CouponLines();
      mCoupon.code = couponCode;
      mCouponItems.clear();
      mCouponItems.add(mCoupon);
    }

    if (widget.shippingLines != null) {
      shipping.add(widget.shippingLines);
    }

    var request = {
      'billing': mBilling,
      'shipping': mShipping,
      'line_items': lineItems,
      'payment_method': mPaymethod,
      'transaction_id': "",
      'customer_id': mUserId.toString(),
      'coupon_lines': couponCode.isNotEmpty ? mCouponItems : '',
      'status': "pending",
      'set_paid': false,
      'shipping_lines': shipping
    };
    setState(() {
      appStore.isLoading = true;
    });
    createOrderApi(request).then((response) async {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
      });
      createOrderTracking(response['id']);
      await showDialog(
          context: context,
          builder: (builder) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                width: context.width() * .70,
                padding: EdgeInsets.all(16),
                decoration: boxDecorationWithShadow(
                    backgroundColor: context.cardColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox().expand(),
                        Icon(Icons.close).onTap(() {
                          finish(context);
                        }),
                      ],
                    ),
                    Image.asset(Selected_icon,
                            height: context.height() * 0.20,
                            fit: BoxFit.contain)
                        .center(),
                    Text(
                      appLocalization
                          .translate('lbl_oder_placed_successfully')!,
                      style: boldTextStyle(
                          color: primaryColor,
                          size: textSizeLargeMedium,
                          decoration: TextDecoration.none),
                    ).center(),
                    spacing_standard_new.height,
                    Text(appLocalization.translate('lbl_total_amount_')!,
                        style: secondaryTextStyle()),
                    spacing_control.height,
                    PriceWidget(price: widget.mPrice, size: 18),
                    Text(appLocalization.translate('lbl_transaction_id')!,
                            style: secondaryTextStyle())
                        .paddingTop(16)
                        .visible(
                            response['transaction_id'].toString().isNotEmpty),
                    Text(response['transaction_id'],
                            style: boldTextStyle(size: 18))
                        .paddingTop(4)
                        .visible(
                            response['transaction_id'].toString().isNotEmpty),
                    Text(appLocalization.translate('lbl_transaction_date')!,
                            style: secondaryTextStyle())
                        .paddingTop(16),
                    Text(response['date_created'].toString(),
                            style: boldTextStyle(size: 18))
                        .paddingTop(4),
                    24.height,
                    AppButton(
                      width: context.width() * .65,
                      text: appLocalization.translate('lbl_done'),
                      textStyle: primaryTextStyle(color: white),
                      color: primaryColor,
                      onTap: () async {
                        if (!await isGuestUser()) {
                          clearCartItems().then((response) {
                            if (!mounted) return;
                            setState(() {});
                            appStore.setCount(0);
                            DashBoardScreen().launch(context, isNewTask: true);
                          }).catchError((error) {
                            setState(() {});
                            toast(error.toString());
                          });
                        } else {
                          appStore.setCount(0);
                          removeKey(CART_DATA);
                          DashBoardScreen().launch(context, isNewTask: true);
                        }
                      },
                    ),
                  ],
                ),
              ).center(),
            );
          });

      finish(context);
    }).catchError((error) {
      setState(() {
        appStore.isLoading = false;
      });
      toast(error.toString());
    });
  }

  Future createWebViewOrder() async {
    if (!accessAllowed) {
      return;
    }

    var request = CreateOrderRequestModel();
    if (widget.shippingLines != null) {
      List<ShippingLines?> shippingLines = [];
      shippingLines.add(widget.shippingLines);
      request.shippingLines = shippingLines;
    }
    List<LineItemsRequest> lineItems = [];
    widget.mCartProduct!.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.productId = item.proId;
      lineItem.quantity = item.quantity;
      lineItem.variationId = item.proId;
      lineItems.add(lineItem);
    });

    var shippingItem = Shipping();
    shippingItem.firstName = mShippingFirstName;
    shippingItem.lastName = mShippingLastName;
    shippingItem.address1 = mShippingAddress;
    shippingItem.company = mBillingCompany;
    shippingItem.address2 = mShippingAddress2;
    shippingItem.city = mShippingCity;
    shippingItem.state = "AP";
    shippingItem.postcode = mShippingPostcode;
    shippingItem.country = "IN";

    var mBilling = Billing();
    mBilling.firstName = mBillingFirstName;
    mBilling.lastName = mBillingLastName;
    mBilling.company = mBillingCompany;
    mBilling.address1 = mBillingAddress;
    mBilling.address2 = mBillingAddress2;
    mBilling.city = mBillingCity;
    mBilling.postcode = mBillingPostcode;
    mBilling.country = "IN";
    mBilling.state = "AP";
    mBilling.email = mBillingEmail;
    mBilling.phone = mBillingPhone;

    request.paymentMethod = "cod";
    request.transactionId = "";
    request.customerId = getIntAsync(USER_ID);
    request.status = "pending";
    request.setPaid = false;

    request.lineItems = lineItems;
    request.shipping = shippingItem;
    request.billing = mBilling;
    createOrder(request);
  }

  void createOrder(CreateOrderRequestModel mCreateOrderRequestModel) async {
    setState(() {
      appStore.isLoading = true;
    });
    await createOrderApi(mCreateOrderRequestModel.toJson()).then((response) {
      if (!mounted) return;
      processPaymentApi(response['id']);
    }).catchError((error) {
      setState(() {
        appStore.isLoading = false;
      });
      toast(error.toString());
    });
  }

  processPaymentApi(var mOrderId) async {
    log(mOrderId);
    var request = {"order_id": mOrderId};
    getCheckOutUrl(request).then((res) async {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
      });
      bool isPaymentDone =
          await WebViewPaymentScreen(checkoutUrl: res['checkout_url'])
                  .launch(context) ??
              false;
      if (isPaymentDone) {
        setState(() {
          appStore.isLoading = true;
        });
        if (!await isGuestUser()) {
          clearCartItems().then((response) {
            if (!mounted) return;
            setState(() {
              appStore.isLoading = false;
            });
            appStore.setCount(0);
            DashBoardScreen().launch(context, isNewTask: true);
          }).catchError((error) {
            setState(() {
              appStore.isLoading = false;
            });
            toast(error.toString());
          });
        } else {
          appStore.setCount(0);
          removeKey(CART_DATA);
          DashBoardScreen().launch(context, isNewTask: true);
        }
      } else {
        deleteOrder(mOrderId)
            .then((value) => {log(value)})
            .catchError((error) {});
        appStore.setCount(0);
      }
    }).catchError((error) {});
  }

  void onOrderNowClick() async {
    createNativeOrder("Cash On Delivery");
  }

  @override
  void dispose() {
    super.dispose();
    _razorPay.clear();
  }

  void openCheckout() async {
    var mAmount = double.parse(widget.mPrice) * 100.00;
    var options = {
      'key': razorKey,
      'amount': mAmount,
      'name': 'Woobox',
      'theme.color': '#C62828',
      'description': 'Woocommerce Store',
      'image': 'https://razorpay.com/assets/razorpay-glyph.svg',
      'prefill': {'contact': mBillingPhone, 'email': mBillingEmail},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId!);
    if (!await isGuestUser()) {
      createNativeOrder("RazorPay");
      clearCartItems().then((response) {
        if (!mounted) return;
        appStore.setCount(0);
        DashBoardScreen().launch(context, isNewTask: true);
        setState(() {});
      }).catchError((error) {
        appStore.isLoading = false;
        setState(() {});
        toast(error.toString());
      });
    } else {
      appStore.setCount(0);
      removeKey(CART_DATA);
      DashBoardScreen().launch(context, isNewTask: true);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName!);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_order_summary'),
            showBack: true) as PreferredSizeWidget?,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: context.width(),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: boxDecorationWithShadow(
                        backgroundColor: context.cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.height,
                        Text(appLocalization.translate("lbl_shipping_address")!,
                                style: boldTextStyle())
                            .visible(mShippingFirstName != null),
                        8.height,
                        Text('$mShippingFirstName $mShippingLastName\n$mShippingAddress\n$mShippingCity,$mShippingState,$mShippingCountry-$mShippingPostcode',
                                style: secondaryTextStyle(size: 16))
                            .visible(mShippingAddress != null),
                      ],
                    ).paddingOnly(right: 16, left: 16, bottom: 16),
                  ),
                  Container(
                    width: context.width(),
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    decoration: boxDecorationWithShadow(
                        backgroundColor: context.cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalization.translate('lbl_payment_methods')!,
                            style: boldTextStyle()),
                        spacing_standard.height,
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: mPaymentList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(8),
                              decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: context.cardColor,
                                  border: _currentTimeValue != index
                                      ? Border.all(color: Colors.transparent)
                                      : Border.all(color: primaryColor!)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (mPaymentList[index] == "Cash On Delivery")
                                    Image.asset(ic_cod, height: 36, width: 36)
                                  else
                                    Image.asset(ic_razor_pay,
                                        height: 40, width: 40),
                                  12.width,
                                  Text(mPaymentList[index],
                                          style: primaryTextStyle(),
                                          textAlign: TextAlign.left)
                                      .expand(),
                                  _currentTimeValue == index
                                      ? Container(
                                          child: Icon(Icons.check_circle,
                                              color: greenColor, size: 20))
                                      : SizedBox()
                                ],
                              ).onTap(() {
                                setState(() {
                                  _currentTimeValue = index;
                                });
                              }),
                            );
                          },
                        ),
                      ],
                    ).paddingAll(16).visible(isNativePayment == true),
                  ).visible(getStringAsync(PAYMENTMETHOD) != "webview"),
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    width: context.width(),
                    decoration: boxDecorationWithShadow(
                        backgroundColor: context.cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalization.translate("lbl_price_detail")!,
                            style: boldTextStyle()),
                        8.height,
                        Divider(),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(appLocalization.translate("lbl_total_mrp")!,
                                style:
                                    secondaryTextStyle(size: textSizeMedium)),
                            PriceWidget(
                                price: nf.format(widget.subtotal.validate()),
                                color: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .color,
                                size: 16)
                          ],
                        ),
                        6.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                appLocalization
                                    .translate("lbl_discount_on_mrp")!,
                                style:
                                    secondaryTextStyle(size: textSizeMedium)),
                            Row(
                              children: [
                                Text("-",
                                    style:
                                        primaryTextStyle(color: primaryColor)),
                                PriceWidget(
                                    price:
                                        widget.mRPDiscount!.toStringAsFixed(2),
                                    color: primaryColor,
                                    size: 16),
                              ],
                            )
                          ],
                        ).paddingBottom(6).visible(widget.mRPDiscount != 0.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                appLocalization
                                    .translate('lbl_coupon_discount')!,
                                style:
                                    secondaryTextStyle(size: textSizeMedium)),
                            Row(
                              children: [
                                Text("-",
                                    style:
                                        primaryTextStyle(color: primaryColor)),
                                PriceWidget(
                                  price: widget.discount.validate(),
                                  size: textSizeMedium.toDouble(),
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .color,
                                ),
                              ],
                            ),
                          ],
                        ).paddingBottom(6).visible(
                            widget.discount != 0.0 && isEnableCoupon == true),
                        widget.method != null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      appLocalization
                                          .translate("lbl_Shipping")!,
                                      style: secondaryTextStyle(
                                          size: textSizeMedium)),
                                  widget.method != null &&
                                          widget.method!.cost != null &&
                                          widget.method!.cost!.isNotEmpty
                                      ? PriceWidget(
                                          price: widget.method!.cost
                                              .toString()
                                              .validate(),
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .color,
                                          size: 16)
                                      : Text(
                                          appLocalization
                                              .translate('lbl_free')!,
                                          style: boldTextStyle(
                                              color: Colors.green))
                                ],
                              )
                            : SizedBox(),
                        SizedBox(
                                width: context.width(),
                                child: DashedRect(gap: 3, color: greyColor))
                            .paddingOnly(top: 8, bottom: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(appLocalization.translate('lbl_total_amount')!,
                                style: boldTextStyle(color: greenColor)),
                            PriceWidget(
                                price: widget.mPrice,
                                size: textSizeMedium.toDouble(),
                                color: greenColor),
                          ],
                        ),
                      ],
                    ).paddingAll(16),
                  ),
                ],
              ),
            ),
            mProgress().center().visible(appStore.isLoading!),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Theme.of(context).hoverColor.withOpacity(0.8),
                  blurRadius: 15.0,
                  offset: Offset(0.0, 0.75))
            ],
          ),
          child: AppButton(
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(8)),
            text: appLocalization.translate('lbl_pay_now'),
            textStyle: primaryTextStyle(color: white),
            color: primaryColor,
            onTap: () {
              if (appStore.isLoading!) {
                return;
              }
              if (isNativePayment == false) {
                if (getStringAsync(TOKEN) != '') {
                  createWebViewOrder();
                } else {
                  toast('try to login to complete pay ');
                  SignInScreen().launch(context);
                }
              } else {
                if (_currentTimeValue == 0) openCheckout();
                if (_currentTimeValue == 1) _cod();
              }
            },
          ).paddingOnly(
              top: spacing_standard.toDouble(),
              left: spacing_standard_new.toDouble(),
              bottom: spacing_standard_new.toDouble(),
              right: spacing_standard_new.toDouble()),
        ),
      ),
    );
  }

  void _cod() {
    onOrderNowClick();
  }
}
