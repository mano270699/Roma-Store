import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/HomeCategoryListComponent.dart';
import '../component/HomeComponent/DashboardComponent.dart';
import '../component/HomeComponent/GradientProductComponent.dart';
import '../model/CartModel.dart';
import '../model/CategoryData.dart';
import '../model/ProductResponse.dart';
import '../model/SaleBannerResponse.dart';
import '../model/SliderModel.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import '../utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../main.dart';
import 'SearchScreen.dart';
import 'ViewAllScreen.dart';
import 'ExternalProductScreen.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen1';

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<String?> mSliderImages = [];
  List<String?> mSaleBannerImages = [];
  List<ProductResponse> mNewestProductModel = [];
  List<ProductResponse> mFeaturedProductModel = [];
  List<ProductResponse> mDealProductModel = [];
  List<ProductResponse> mSellingProductModel = [];
  List<ProductResponse> mSaleProductModel = [];
  List<ProductResponse> mOfferProductModel = [];
  List<ProductResponse> mSuggestedProductModel = [];
  List<ProductResponse> mYouMayLikeProductModel = [];
  List<VendorResponse> mVendorModel = [];
  List<Category> mCategoryModel = [];
  List<Widget> data = [];
  List<SliderModel> mSliderModel = [];
  List<Salebanner> mSaleBanner = [];
  CartResponse mCartModel = CartResponse();

  PageController salePageController = PageController(initialPage: 0);
  PageController bannerPageController = PageController(initialPage: 0);

  int selectIndex = 0;
  int _currentPage = 0;

  String mErrorMsg = '';

  bool isWasConnectionLoss = false;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  setTimer() {
    Timer.periodic(Duration(seconds: 25), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (bannerPageController.hasClients) {
        bannerPageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
    Timer.periodic(Duration(seconds: 15), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (salePageController.hasClients) {
        salePageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  init() async {
    await setValue(CARTCOUNT, appStore.count);
    setTimer();
    fetchDashboardData();
    fetchCategoryData();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isWasConnectionLoss = true;
        Scaffold(body: noInternet(context)).launch(context);
      } else {
        if (isWasConnectionLoss) finish(context);
      }
    });
  }

  Future fetchCategoryData() async {
    await getCategories(1, TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable mCategory = res;
        mCategoryModel =
            mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
    });
  }

  Future fetchDashboardData() async {
    var appLocalization = AppLocalizations.of(context)!;
    appStore.isLoading = true;
    setState(() {});
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        if (!await isGuestUser() && await isLoggedIn()) {
          await getCartList().then((res) {
            if (!mounted) return;
            setState(() {
              mCartModel = CartResponse.fromJson(res);
              if (mCartModel.data!.isNotEmpty) {
                appStore.setCount(mCartModel.totalQuantity);
              }
            });
          }).catchError((error) {
            log(error.toString());
            setState(() {});
          });
        }
        await getDashboardApi().then((res) async {
          if (!mounted) return;
          appStore.isLoading = false;
          setStringAsync(DEFAULT_CURRENCY,
              parseHtmlString(res['currency_symbol']['currency_symbol']));
          setStringAsync(CURRENCY_CODE, res['currency_symbol']['currency']);
          await setValue(DASHBOARD_DATA, jsonEncode(res));
          setProductData(res);
          if (res['social_link'] != null) {
            setStringAsync(WHATSAPP, res['social_link']['whatsapp']);
            setStringAsync(FACEBOOK, res['social_link']['facebook']);
            setStringAsync(TWITTER, res['social_link']['twitter']);
            setStringAsync(INSTAGRAM, res['social_link']['instagram']);
            setStringAsync(CONTACT, res['social_link']['contact']);
            setStringAsync(
                PRIVACY_POLICY, res['social_link']['privacy_policy']);
            setStringAsync(
                TERMS_AND_CONDITIONS, res['social_link']['term_condition']);
            setStringAsync(
                COPYRIGHT_TEXT, res['social_link']['copyright_text']);
          }
          await setValue(PAYMENTMETHOD, res['payment_method']);
          await setValue(ENABLECOUPON, res['enable_coupons']);
        }).catchError((error) {
          if (!mounted) return;
          appStore.isLoading = false;
          mErrorMsg = error.toString();
          log("test" + error.toString());
        });

        isDone = true;
      } else {
        toast(appLocalization.translate("toast_txt_internet_connection"));
        if (!mounted) return;
        appStore.isLoading = false;
      }
      setState(() {});
    });
  }

  void setProductData(res) async {
    Iterable newest = res['newest'];
    mNewestProductModel =
        newest.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable featured = res['featured'];
    mFeaturedProductModel =
        featured.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable deal = res['deal_of_the_day'];
    mDealProductModel =
        deal.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable selling = res['best_selling_product'];
    mSellingProductModel =
        selling.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable sale = res['sale_product'];
    mSaleProductModel =
        sale.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable offer = res['offer'];
    mOfferProductModel =
        offer.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable suggested = res['suggested_for_you'];
    mSuggestedProductModel =
        suggested.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable youMayLike = res['you_may_like'];
    mYouMayLikeProductModel =
        youMayLike.map((model) => ProductResponse.fromJson(model)).toList();

    if (res['vendors'] != null) {
      Iterable vendorList = res['vendors'];
      mVendorModel =
          vendorList.map((model) => VendorResponse.fromJson(model)).toList();
    }

    if (res['slider'] != null) {
      mSaleBannerImages.clear();
      Iterable bannerList = res['slider'];
      mSaleBanner =
          bannerList.map((model) => Salebanner.fromJson(model)).toList();
      mSaleBanner.forEach((s) => mSaleBannerImages.add(s.image));
    }

    mSliderImages.clear();
    Iterable list = res['banner'];
    mSliderModel = list.map((model) => SliderModel.fromJson(model)).toList();
    log("$mSliderModel");
    mSliderModel.forEach((s) => mSliderImages.add(s.image));

    setState(() {});
  }

  List<T?> map<T>(List list, Function handler) {
    List<T?> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void dispose() {
    salePageController.dispose();
    bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    Widget availableOfferAndDeal(String title, List<ProductResponse> product) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColor1.withOpacity(0.25),
                  gradientColor2.withOpacity(0.25)
                ],
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(ic_header),
                    Column(
                      children: [
                        Text(title.toUpperCase(),
                            style: GoogleFonts.alegreyaSc(
                                color: appStore.isDarkMode!
                                    ? white.withOpacity(0.7)
                                    : primaryColor!,
                                fontSize: 22)),
                        Row(
                          children: [
                            Divider(
                                    thickness: 1,
                                    height: 10,
                                    color: primaryColor,
                                    indent: 50,
                                    endIndent: 10)
                                .expand(),
                            Icon(Entypo.infinity, color: primaryColor!),
                            Divider(
                                    thickness: 1,
                                    height: 10,
                                    color: primaryColor,
                                    indent: 10,
                                    endIndent: 50)
                                .expand()
                          ],
                        ),
                        if (title ==
                            builderResponse.dashboard!.todayDeal!.title)
                          Text(
                              appLocalization
                                  .translate("txt_deal_of_the_day")!
                                  .toUpperCase(),
                              style: GoogleFonts.alegreyaSc(
                                  color: textSecondaryColour))
                        else
                          Text(
                              appLocalization
                                  .translate("txt_available_offer")!
                                  .toUpperCase(),
                              style: GoogleFonts.alegreyaSc(
                                  color: textSecondaryColour))
                      ],
                    ).paddingOnly(left: 12, top: 24, bottom: 16)
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      HorizontalList(
                        padding:
                            EdgeInsets.only(left: 12, right: 8, bottom: 16),
                        itemCount: product.length > 6 ? 6 : product.length,
                        itemBuilder: (context, i) {
                          return GradientProductComponent(
                                  mProductModel: product[i],
                                  width: context.width() * 0.4)
                              .paddingOnly(right: 4, top: 8);
                        },
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: boxDecorationRoundedWithShadow(8,
                            backgroundColor:
                                Theme.of(context).cardTheme.color!),
                        child: Row(
                          children: [
                            Text(
                              builderResponse
                                  .dashboard!.youMayLikeProduct!.viewAll!,
                              style: boldTextStyle(color: primaryColor),
                            ).paddingOnly(right: 10, top: 8, bottom: 8).onTap(
                              () {
                                if (title ==
                                    builderResponse
                                        .dashboard!.todayDeal!.title) {
                                  ViewAllScreen(title,
                                          isSpecialProduct: true,
                                          specialProduct: "deal_of_the_day")
                                      .launch(context);
                                } else if (title ==
                                    builderResponse
                                        .dashboard!.offerProduct!.title) {
                                  ViewAllScreen(
                                          appLocalization
                                              .translate('lbl_offer'),
                                          isSpecialProduct: true,
                                          specialProduct: "offer")
                                      .launch(context);
                                } else {
                                  ViewAllScreen(title);
                                }
                              },
                            ),
                            Icon(Icons.arrow_forward_outlined,
                                color: primaryColor!)
                          ],
                        ),
                      ).visible(product.length > 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
          12.height,
        ],
      ).paddingOnly(
        top: spacing_standard_new.toDouble(),
      );
    }

    Widget _category() {
      return mCategoryModel.isNotEmpty
          ? HomeCategoryListComponent(mCategoryModel: mCategoryModel)
          : SizedBox();
    }

    Widget carousel() {
      return mSliderModel.isNotEmpty
          ? Column(
              children: [
                Container(
                  height: 200,
                  child: PageView(
                    controller: bannerPageController,
                    onPageChanged: (i) {
                      selectIndex = i;
                      setState(() {});
                    },
                    children: mSliderModel.map((i) {
                      return Container(
                        margin: EdgeInsets.only(left: 12, right: 12, top: 8),
                        child: commonCacheImageWidget(i.image.validate(),
                                width: context.width() * .95, fit: BoxFit.cover)
                            .cornerRadiusWithClipRRect(8),
                      ).onTap(() {
                        if (i.url!.isNotEmpty) {
                          ExternalProductScreen(
                                  mExternal_URL: i.url, title: i.title)
                              .launch(context);
                        } else {
                          toast(appLocalization.translate("txt_sorry"));
                        }
                      });
                    }).toList(),
                  ),
                ),
                DotIndicator(
                  pageController: bannerPageController,
                  pages: mSliderModel,
                  indicatorColor: primaryColor,
                  unselectedIndicatorColor: grey.withOpacity(0.2),
                  currentBoxShape: BoxShape.rectangle,
                  boxShape: BoxShape.rectangle,
                  borderRadius: radius(2),
                  currentBorderRadius: radius(3),
                  currentDotSize: 18,
                  currentDotWidth: 6,
                  dotSize: 6,
                ),
              ],
            )
          : SizedBox();
    }

    Widget mSaleBannerWidget() {
      return mSaleBanner.isNotEmpty
          ? Column(
              children: [
                Container(
                  height: 240,
                  margin: EdgeInsets.only(top: 12),
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        saleBannerGradient1.shade500,
                        saleBannerGradient2.shade200
                      ],
                    ),
                  ),
                  child: PageView(
                    controller: salePageController,
                    onPageChanged: (i) {
                      selectIndex = i;
                      setState(() {});
                    },
                    children: mSaleBanner.map((i) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                        child: commonCacheImageWidget(i.image.validate(),
                                width: double.infinity, fit: BoxFit.cover)
                            .cornerRadiusWithClipRRect(8),
                      );
                    }).toList(),
                  ),
                ),
                DotIndicator(
                  pageController: salePageController,
                  pages: mSaleBanner,
                  indicatorColor: primaryColor,
                  unselectedIndicatorColor: grey.withOpacity(0.2),
                  currentBoxShape: BoxShape.rectangle,
                  boxShape: BoxShape.rectangle,
                  borderRadius: radius(2),
                  currentBorderRadius: radius(3),
                  currentDotSize: 18,
                  currentDotWidth: 6,
                  dotSize: 6,
                ),
              ],
            )
          : SizedBox();
    }

    Widget _newProduct() {
      return DashboardComponent(
        title: builderResponse.dashboard!.newArrivals!.title!,
        subTitle: builderResponse.dashboard!.newArrivals!.viewAll!,
        product: mNewestProductModel,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.newArrivals!.title,
                  isNewest: true)
              .launch(context);
        },
      );
    }

    Widget _featureProduct() {
      return DashboardComponent(
        title: builderResponse.dashboard!.featureProduct!.title!,
        subTitle: builderResponse.dashboard!.featureProduct!.viewAll!,
        product: mFeaturedProductModel,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.featureProduct!.title,
                  isFeatured: true)
              .launch(context);
        },
      );
    }

    Widget _dealOfTheDay() {
      return Column(
        children: [
          availableOfferAndDeal(
            builderResponse.dashboard!.todayDeal!.title!,
            mDealProductModel,
          ).visible(mDealProductModel.isNotEmpty),
        ],
      );
    }

    Widget _bestSelling() {
      return DashboardComponent(
        title: builderResponse.dashboard!.topProduct!.title!,
        subTitle: builderResponse.dashboard!.topProduct!.viewAll!,
        product: mSellingProductModel,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.topProduct!.title,
                  isBestSelling: true)
              .launch(context);
        },
      );
    }

    Widget _saleProduct() {
      return DashboardComponent(
        title: builderResponse.dashboard!.hotProduct!.title!,
        subTitle: builderResponse.dashboard!.hotProduct!.viewAll!,
        product: mSaleProductModel,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.hotProduct!.title,
                  isSale: true)
              .launch(context);
        },
      );
    }

    Widget _offer() {
      return Column(
        children: [
          availableOfferAndDeal(builderResponse.dashboard!.offerProduct!.title!,
                  mOfferProductModel)
              .visible(mOfferProductModel.isNotEmpty),
        ],
      );
    }

    Widget _suggested() {
      return DashboardComponent(
        title: builderResponse.dashboard!.recommendedProduct!.title!,
        subTitle: builderResponse.dashboard!.recommendedProduct!.viewAll!,
        product: mSuggestedProductModel,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.recommendedProduct!.title,
                  isSpecialProduct: true, specialProduct: "suggested_for_you")
              .launch(context);
        },
      );
    }

    Widget _youMayLike() {
      return DashboardComponent(
        title: builderResponse.dashboard!.youMayLikeProduct!.title!,
        subTitle: builderResponse.dashboard!.youMayLikeProduct!.viewAll!,
        product: mYouMayLikeProductModel,
        onTap: () {
          ViewAllScreen(
            builderResponse.dashboard!.youMayLikeProduct!.title,
            isSpecialProduct: true,
            specialProduct: "you_may_like",
          ).launch(context);
        },
      );
    }

    Widget body = ListView(
      shrinkWrap: true,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 16),
          itemCount: builderResponse.dashboard == null
              ? 0
              : builderResponse.dashboard!.sortDashboard!.length,
          itemBuilder: (_, index) {
            if (builderResponse.dashboard!.sortDashboard![index] == 'slider') {
              return carousel()
                  .visible(builderResponse.dashboard!.sliderView!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'categories') {
              return _category()
                  .visible(builderResponse.dashboard!.category!.enable!)
                  .paddingOnly(top: 8, bottom: 8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'Sale_Banner') {
              return mSaleBannerWidget()
                  .visible(builderResponse.dashboard!.saleBanner!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'newest_product') {
              return _newProduct()
                  .visible(builderResponse.dashboard!.newArrivals!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'vendor') {
              return mVendorWidget(
                      context,
                      mVendorModel,
                      builderResponse.dashboard!.seller!.title!.toUpperCase(),
                      builderResponse.dashboard!.seller!.viewAll)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'feature_products') {
              return _featureProduct()
                  .visible(builderResponse.dashboard!.featureProduct!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'deal_of_the_day') {
              return _dealOfTheDay()
                  .visible(builderResponse.dashboard!.todayDeal!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'best_selling_product') {
              return _bestSelling()
                  .visible(builderResponse.dashboard!.topProduct!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'sale_product') {
              return _saleProduct()
                  .visible(builderResponse.dashboard!.hotProduct!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'offer') {
              return _offer()
                  .visible(builderResponse.dashboard!.offerProduct!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'suggested_for_you') {
              return _suggested()
                  .visible(
                      builderResponse.dashboard!.recommendedProduct!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sortDashboard![index] ==
                'you_may_like') {
              return _youMayLike()
                  .visible(
                      builderResponse.dashboard!.youMayLikeProduct!.enable!)
                  .paddingTop(8);
            } else {
              return 0.height;
            }
          },
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: mTop(
        context,
        appLocalization.translate('app_name'),
        actions: [
          IconButton(
            icon: Icon(Icons.search_sharp, color: white),
            onPressed: () {
              SearchScreen().launch(context);
            },
          )
        ],
      ) as PreferredSizeWidget?,
      key: scaffoldKey,
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).cardTheme.color,
        color: primaryColor!,
        onRefresh: () {
          return fetchDashboardData();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            body.visible(!appStore.isLoading!),
            mProgress().center().visible(appStore.isLoading!),
          ],
        ),
      ),
    );
  }
}
