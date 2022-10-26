import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../main.dart';
import '../model/CartModel.dart';
import '../model/WishListResponse.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

part 'AppStore.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  bool? isLoading = false;

  @observable
  bool isLoggedIn = false;

  @observable
  bool isGuestUserLoggedIn = false;

  @observable
  bool isDarkModeOn = false;

  @observable
  int? count = 0;

  @observable
  bool mIsUserExistInReview = false;

  @observable
  bool isNotificationOn = true;

  @observable
  bool? isDarkMode = false;

  @observable
  bool mIsInWishList = false;

  @observable
  bool mIsInCartList = false;

  @observable
  String selectedLanguageCode = defaultLanguage;

  @observable
  List<WishListResponse> mWishList = ObservableList<WishListResponse>();

  @observable
  List<CartModel> mCartList = ObservableList<CartModel>();

  @observable
  int? cancelOrderIndex = 0;

  @observable
  bool isWishlist = false;

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  void setWishList(List<WishListResponse> val) {
    mWishList.clear();
    mWishList.addAll(val);
  }

  @action
  void addToMyWishList(WishListResponse val) {
    mWishList.add(val);
  }

  @action
  void removeFromMyWishList(WishListResponse val) {
    mWishList.removeWhere((element) => element.proId == val.proId);
  }

  @action
  Future<void> toggleDarkMode({bool? value}) async {
    isDarkModeOn = value ?? !isDarkModeOn;
  }

  @action
  void setCartList(List<CartModel> val) {
    mCartList.clear();
    mCartList.addAll(val);
  }

  @action
  void addToCartList(CartModel val) {
    mCartList.add(val);
  }

  @action
  void removeFromCartList(CartModel val) {
    mCartList.removeWhere((element) => element.proId == val.proId);
  }

  @action
  void setLoggedIn(bool val) {
    isLoggedIn = val;
    setValue(IS_LOGGED_IN, val);
  }

  @action
  void setGuestUserLoggedIn(bool val) {
    isGuestUserLoggedIn = val;
    setValue(IS_GUEST_USER, val);
  }

  @action
  Future<void> setDarkMode({bool? aIsDarkMode}) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode!) {
      textPrimaryColorGlobal = Colors.white54;
      textSecondaryColorGlobal = Colors.white70;
      setStatusBarColor(darkColor);
    } else {
      textPrimaryColorGlobal = textPrimaryColour!;
      textSecondaryColorGlobal = textSecondaryColour!;
      setStatusBarColor(primaryColor!);
    }
  }

  @action
  void increment() {
    count = count! + 1;
  }

  @action
  void setCartCount(int counts) {
    count = counts;
  }

  @action
  void setCancelItemIndex(int i) {
    cancelOrderIndex = i;
  }

  @action
  void decrement() {
    count = count! - 1;
  }

  @action
  void setCount(int? aCount) => count = aCount;

  @action
  Future<void> setLanguage(String aSelectedLanguageCode) async {
    selectedLanguageCode = aSelectedLanguageCode;

    selectedLanguageDataModel = getSelectedLanguageModel();
  }

  @action
  void setNotification(bool val) {
    isNotificationOn = val;

    setValue(IS_NOTIFICATION_ON, val);

    if (isMobile) {
      OneSignal.shared.disablePush(!val);
    }
  }
}
