import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/LoginResponse.dart';
import '../utils/constants.dart';
import '../utils/shared_pref.dart';

import '../main.dart';
import 'NetworkUtils.dart';
import 'Woobox_API.dart';

Future createCustomer(request) async {
  return handleResponse(await WooBoxAPI()
      .postAsync('woobox-api/api/v1/auth/registration', data: request));
}

Future login(request) async {
  return handleResponse(
      await WooBoxAPI().postAsync('jwt-auth/v1/token', data: request));
}

Future<LoginResponse> login1(Map request, {bool isSocialLogin = false}) async {
  Response response = await WooBoxAPI().postAsync(
      isSocialLogin
          ? 'woobox-api/api/v1/customer/social_login'
          : 'jwt-auth/v1/token',
      data: request);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') &&
          json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    await setValue(TOKEN, loginResponse.token.validate());
    await setValue(USER_ID, loginResponse.userId.validate());
    await setValue(FIRST_NAME, loginResponse.firstName.validate());
    await setValue(LAST_NAME, loginResponse.lastName.validate());
    await setValue(USER_EMAIL, loginResponse.userEmail.validate());
    await setValue(USERNAME, loginResponse.userNicename.validate());

    await setValue(USER_DISPLAY_NAME, loginResponse.userDisplayName.validate());
    await setValue(BILLING, jsonEncode(loginResponse.billing));
    await setValue(SHIPPING, jsonEncode(loginResponse.shipping));

    await setValue(AVATAR, loginResponse.avatar);
    if (loginResponse.wooboxProfileImage != null) {
      setStringAsync(
          PROFILE_IMAGE, loginResponse.wooboxProfileImage.validate());
    }

    if (!isSocialLogin) await setValue(PASSWORD, request['password']);
    await setValue(IS_SOCIAL_LOGIN, isSocialLogin.validate());
    appStore.setLoggedIn(true);
    if (isSocialLogin) {
      FirebaseAuth.instance.signOut();
      await setValue(IS_REMEMBERED, true);
    } else {}
    return loginResponse;
  }).catchError((e) {
    log(e);
    throw e.toString();
  });
}

Future getProductDetail(int? productId) async {
  if (!await isGuestUser() && await isLoggedIn()) {
    return handleResponse(await WooBoxAPI().getAsync(
        'woobox-api/api/v1/woocommerce/get-product-details?product_id=$productId',
        requireToken: true));
  } else {
    return handleResponse(await WooBoxAPI().getAsync(
        'woobox-api/api/v1/woocommerce/get-product-details?product_id=$productId',
        requireToken: false));
  }
}

Future searchProduct(request) async {
  if (!await isGuestUser() && await isLoggedIn()) {
    return handleResponse(await WooBoxAPI().postAsync(
        'woobox-api/api/v1/woocommerce/get-product',
        data: request,
        requireToken: true));
  } else {
    return handleResponse(await WooBoxAPI().postAsync(
        'woobox-api/api/v1/woocommerce/get-product',
        data: request,
        requireToken: false));
  }
}

Future offerProductList() async {
  return handleResponse(await WooBoxAPI().getAsync(
      'woobox-api/api/v1/woocommerce/get-product?special_product=offer',
      requireToken: false));
}

Future getProductAttribute() async {
  return handleResponse(await WooBoxAPI()
      .getAsync('woobox-api/api/v1/woocommerce/get-product-attributes'));
}

Future updateCustomer(id, request) async {
  return handleResponse(await WooBoxAPI().postAsync(
    'wc/v3/customers/$id',
    data: request,
  ));
}

Future forgetPassword(request) async {
  return handleResponse(await WooBoxAPI()
      .postAsync('woobox-api/api/v1/customer/forget-password', data: request));
}

Future getCustomer(id) async {
  return handleResponse(
      await WooBoxAPI().getAsync('wc/v3/customers/$id', noHeader: true));
}

Future getCategories(page, total) async {
  return handleResponse(await WooBoxAPI().getAsync(
      'wc/v3/products/categories?page=$page&per_page=$total&parent=0'));
}

Future getSubCategories(parent, page) async {
  return handleResponse(await WooBoxAPI().getAsync(
    'wc/v3/products/categories?page=$page&parent=$parent',
  ));
}

Future getAllCategories(category, page, total) async {
  return handleResponse(await WooBoxAPI().getAsync(
    'wc/v3/products?category=$category&page=$page&per_page=$total',
  ));
}

Future getWishList() async {
  return handleResponse(await WooBoxAPI().getAsync(
      'woobox-api/api/v1/wishlist/get-wishlist/',
      requireToken: true));
}

Future saveProfileImage(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/customer/save-profile-image',
      data: request,
      requireToken: true));
}

Future changePassword(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/customer/change-password',
      data: request,
      requireToken: true));
}

Future getDashboardApi() async {
  if (!await isGuestUser() && await isLoggedIn()) {
    return handleResponse(await WooBoxAPI().getAsync(
        'woobox-api/api/v1/woocommerce/get-dashboard?per_page=$TOTAL_DASHBOARD_ITEM',
        requireToken: true));
  } else {
    return handleResponse(await WooBoxAPI().getAsync(
        'woobox-api/api/v1/woocommerce/get-dashboard?per_page=$TOTAL_DASHBOARD_ITEM',
        requireToken: false));
  }
}

Future addWishList(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/wishlist/add-wishlist/',
      data: request,
      requireToken: true));
}

Future removeWishList(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/wishlist/delete-wishlist/',
      data: request,
      requireToken: true));
}

Future addToCart(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/cart/add-cart/',
      data: request,
      requireToken: true));
}

Future removeCartItem(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/cart/delete-cart/',
      data: request,
      requireToken: true));
}

Future getCartList() async {
  return handleResponse(await WooBoxAPI()
      .getAsync('woobox-api/api/v1/cart/get-cart/', requireToken: true));
}

Future updateCartItem(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/cart/update-cart/',
      data: request,
      requireToken: true));
}

Future getCouponList() async {
  return handleResponse(await WooBoxAPI().getAsync('wc/v3/Coupons'));
}

Future getProductReviews(id) async {
  return handleResponse(
      await WooBoxAPI().getAsync('wc/v1/products/$id/reviews'));
}

Future postReview(request) async {
  return handleResponse(
      await WooBoxAPI().postAsync('wc/v3/products/reviews', data: request));
}

Future updateReview(id1, request) async {
  return handleResponse(await WooBoxAPI()
      .postAsync('wc/v3/products/reviews/$id1', data: request));
}

Future createOrderApi(request) async {
  return handleResponse(
      await WooBoxAPI().postAsync('wc/v3/orders', data: request));
}

Future deleteReview(id1) async {
  return handleResponse(
      await WooBoxAPI().deleteAsync('wc/v3/products/reviews/$id1'));
}

Future getOrders() async {
  return handleResponse(await WooBoxAPI().getAsync(
      'woobox-api/api/v1/woocommerce/get-customer-orders',
      requireToken: true));
}

Future getOrdersTracking(orderId) async {
  return handleResponse(
      await WooBoxAPI().getAsync('wc/v3/orders/$orderId/notes'));
}

Future createOrderNotes(orderId, request) async {
  return handleResponse(await WooBoxAPI()
      .postAsync('wc/v3/orders/$orderId/notes', data: request));
}

Future cancelOrder(orderId, request) async {
  return handleResponse(
      await WooBoxAPI().postAsync('wc/v3/orders/$orderId', data: request));
}

Future getCheckOutUrl(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/woocommerce/get-checkout-url',
      data: request,
      requireToken: true));
}

Future getActivePaymentGatewaysApi() async {
  return handleResponse(await WooBoxAPI()
      .getAsync('woobox-api/api/v1/payment/get-active-payment-gateway'));
}

Future clearCartItems() async {
  return handleResponse(await WooBoxAPI()
      .getAsync('woobox-api/api/v1/cart/clear-cart/', requireToken: true));
}

Future getCountries() async {
  return handleResponse(
      await WooBoxAPI().getAsync('wc/v3/data/countries', requireToken: false));
}

Future getShippingMethod(request) async {
  return handleResponse(await WooBoxAPI().postAsync(
      'woobox-api/api/v1/woocommerce/get-shipping-methods',
      data: request,
      requireToken: false));
}

Future deleteOrder(id1) async {
  return handleResponse(await WooBoxAPI().deleteAsync('wc/v3/orders/$id1'));
}

Future getVendor() async {
  return handleResponse(
      await WooBoxAPI().getAsync('woobox-api/api/v1/woocommerce/get-vendors'));
}

Future getVendorProfile(id) async {
  return handleResponse(await WooBoxAPI().getAsync('dokan/v1/stores/$id'));
}

Future getVendorProduct(id) async {
  if (!await isGuestUser() && await isLoggedIn()) {
    return handleResponse(await WooBoxAPI().getAsync(
        'woobox-api/api/v1/woocommerce/get-vendor-products?vendor_id=$id',
        requireToken: true));
  } else {
    return handleResponse(await WooBoxAPI().getAsync(
        'woobox-api/api/v1/woocommerce/get-vendor-products?vendor_id=$id',
        requireToken: false));
  }
}

Future socialLoginApi(request) async {
  log(jsonEncode(request));
  return handleResponse(await WooBoxAPI()
      .postAsync('woobox-api/api/v1/customer/social_login', data: request));
}

Future getBlogList(page, total) async {
  return handleResponse(await WooBoxAPI().getAsync(
      'woobox-api/api/v1/blog/get-blog-list?paged=$page&posts_per_page=$total'));
}

Future getBlogDetail(id) async {
  return handleResponse(await WooBoxAPI()
      .getAsync('woobox-api/api/v1/blog/get-blog-detail?post_id=$id'));
}

Future getTrackingInfo(id) async {
  return handleResponse(
      await WooBoxAPI().getAsync('wc-ast/v3/orders/$id/shipment-trackings/'));
}

Future getSaleInfo(startDate, endDate) async {
  return handleResponse(await WooBoxAPI().getAsync(
      'woobox-api/api/v1/woocommerce/get-sale-product?start_date=$startDate&end_date=$endDate'));
}

Future<bool> updateProfile(
    {File? file, String? toastMessage, bool showToast = true}) async {
  var multiPartRequest = MultipartRequest(
      'POST',
      Uri.parse(
          '${getStringAsync(APP_URL)}${'woobox-api/api/v2/customer/save-profile-image'}'));

  if (file != null)
    multiPartRequest.files
        .add(await MultipartFile.fromPath('profile_image', file.path));

  var header = {
    "Authorization": "Bearer ${getStringAsync(TOKEN)}",
  };
  multiPartRequest.headers.addAll(header);

  log(multiPartRequest.fields);
  Response response = await Response.fromStream(await multiPartRequest.send());
  log(response.body);

  if (response.statusCode.isSuccessful()) {
    Map<String, dynamic> res = jsonDecode(response.body);

    await setValue(PROFILE_IMAGE, res['woobox_profile_image']);
    if (showToast) toast(toastMessage ?? res['message']);

    return true;
  } else {
    toast(errorSomethingWentWrong);
    return false;
  }
}
