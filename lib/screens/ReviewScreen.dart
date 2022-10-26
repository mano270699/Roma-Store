import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/ProductReviewModel.dart';
import '../network/rest_apis.dart';
import '../utils/admob_utils.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import '../utils/shared_pref.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'SignInScreen.dart';

class ReviewScreen extends StatefulWidget {
  static String tag = '/ReviewScreen';
  final mProductId;

  ReviewScreen({Key? key, this.mProductId}) : super(key: key);

  @override
  ReviewScreenState createState() => ReviewScreenState();
}

class ReviewScreenState extends State<ReviewScreen> {
  List<ProductReviewModel> mReviewModel = [];
  var reviewCont = TextEditingController();
  String mProfileImage = '';
  var mErrorMsg = '';
  String mUserEmail = '';

  double avgRating = 0.0;
  double ratings = 0.0;
  double isUpdate = 0.0;

  var fiveStars = 0;
  var fourStars = 0;
  var threeStars = 0;
  var twoStars = 0;
  var oneStars = 0;

  var fiveStarPercent = 0.0;
  var fourPercent = 0.0;
  var threePercent = 0.0;
  var twoPercent = 0.0;
  var onePercent = 0.0;

  bool mIsLoggedIn = false;
  bool mIsUserExistInReview = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    getPrefs();
  }

  void getPrefs() async {
    mIsLoggedIn = await isLoggedIn();
    setState(() {});
    if (await getBool(IS_LOGGED_IN)) {
      mUserEmail = await getString(USER_EMAIL);
      log('Email:- $mUserEmail');
    }
  }

  Future fetchData() async {
    setState(() {
      appStore.isLoading = true;
    });
    await getProductReviews(widget.mProductId).then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        Iterable list = res;
        mReviewModel =
            list.map((model) => ProductReviewModel.fromJson(model)).toList();
        if (mReviewModel.isEmpty) {
          fiveStars = 0;
          fourStars = 0;
          threeStars = 0;
          twoStars = 0;
          oneStars = 0;
          avgRating = 0.0;
          fiveStarPercent = 0.0;
          fourPercent = 0.0;
          threePercent = 0.0;
          twoPercent = 0.0;
          onePercent = 0.0;
        } else {
          mErrorMsg = '';
          mReviewModel.forEachIndexed((element, index) {
            if (element.reviewerEmail!.contains(mUserEmail)) {
              mIsUserExistInReview = true;
              setState(() {});
            }
          });
          setReviews();
        }
      });
    }).catchError((error) {
      setState(() {
        mErrorMsg = error.toString();
        appStore.isLoading = false;
      });
    });
  }

  Future setReviews() async {
    if (mReviewModel.isEmpty) return;

    var fiveStar = 0;
    var fourStar = 0;
    var threeStar = 0;
    var twoStar = 0;
    var oneStar = 0;

    var totalRatings = 0;

    mReviewModel.forEach((item) {
      if (item.rating == 1) {
        oneStar++;
      } else if (item.rating == 2) {
        twoStar++;
      } else if (item.rating == 3) {
        threeStar++;
      } else if (item.rating == 4) {
        fourStar++;
      } else if (item.rating == 5) {
        fiveStar++;
      }
    });
    if (fiveStar == 0 &&
        fourStar == 0 &&
        threeStar == 0 &&
        twoStar == 0 &&
        oneStar == 0) {
      return;
    }
    setState(() {
      fiveStars = fiveStar;
      fourStars = fourStar;
      threeStars = threeStar;
      twoStars = twoStar;
      oneStars = oneStar;

      totalRatings = fiveStar + fourStar + threeStar + twoStar + oneStar;

      var mAvgRating = (5 * fiveStar +
              4 * fourStar +
              3 * threeStar +
              2 * twoStar +
              1 * oneStar) /
          (totalRatings);
      avgRating = double.parse(mAvgRating.toStringAsPrecision(2)).toDouble();

      fiveStarPercent = calculateRatings(totalRatings, fiveStar);
      fourPercent = calculateRatings(totalRatings, fourStar);
      threePercent = calculateRatings(totalRatings, threeStar);
      twoPercent = calculateRatings(totalRatings, twoStar);
      onePercent = calculateRatings(totalRatings, oneStar);

      if (onePercent <= 0.0) onePercent = 0.0;
      if (fiveStarPercent <= 0.0) fiveStarPercent = 0.0;
      if (fourPercent <= 0.0) fourPercent = 0.0;
      if (threePercent <= 0.0) threePercent = 0.0;
      if (twoPercent <= 0.0) twoPercent = 0.0;
    });
  }

  double calculateRatings(total, starCount) {
    if (starCount < 1) return 0.0;
    var a = total / starCount;
    var b = a * 10;
    var c = b / 100;
    var d = 1.0 - c;
    return d;
  }

  Future postReviewApi(productId, review, rating) async {
    var request = {
      'product_id': productId,
      'reviewer': getStringAsync(FIRST_NAME) + " " + getStringAsync(LAST_NAME),
      'reviewer_email': getStringAsync(USER_EMAIL),
      'review': review,
      'rating': rating,
    };
    setState(() {
      appStore.isLoading = true;
    });
    postReview(request).then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        mIsUserExistInReview = true;
        mReviewModel.clear();
      });
      fetchData();
    }).catchError((error) {
      setState(() {
        appStore.isLoading = false;
        toast(error);
      });
    });
  }

  Future updateReviewApi(productId, review, rating, reviewId) async {
    var request = {
      'product_id': productId,
      'reviewer': getStringAsync(USERNAME),
      'reviewer_email': getStringAsync(USER_EMAIL),
      'review': review,
      'rating': rating,
    };
    setState(() {
      appStore.isLoading = true;
    });
    updateReview(reviewId, request).then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        mReviewModel.clear(); // T
        fetchData();
      });
    }).catchError((error) {
      setState(() {
        appStore.isLoading = false;
        toast(error);
      });
    });
  }

  Future deleteReviewApi(reviewId) async {
    var appLocalization = AppLocalizations.of(context)!;
    if (!accessAllowed) {
      toast(demoPurposeMsg);
      return;
    }
    setState(() {
      appStore.isLoading = true;
    });
    deleteReview(reviewId).then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        mIsUserExistInReview = false;
        fetchData();
        toast(appLocalization.translate("toast_remove_review"));
      });
    }).catchError((error) {
      setState(() {
        appStore.isLoading = false;
        fetchData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    void onUpdateSubmit(review, rating, reviewId) async {
      if (accessAllowed) {
        updateReviewApi(widget.mProductId, review, rating, reviewId);
      } else {
        toast(demoPurposeMsg);
      }
    }

    Widget mDialog() {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: boxDecorationWithRoundedCorners(
            borderRadius: radius(10),
            backgroundColor: Theme.of(context).cardTheme.color!),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appLocalization.translate('hint_review')!.toUpperCase(),
                      style: boldTextStyle(
                          color: Theme.of(context).textTheme.subtitle1!.color)),
                  IconButton(
                      onPressed: () {
                        finish(context);
                      },
                      icon: Icon(Icons.close,
                          color: Theme.of(context).iconTheme.color, size: 22))
                ],
              ).paddingOnly(left: 16),
              Divider(),
              TextFormField(
                cursorColor: appStore.isDarkMode! ? whiteColor : black,
                controller: reviewCont,
                maxLines: 8,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                style: primaryTextStyle(
                    color: Theme.of(context).textTheme.subtitle1!.color),
                decoration: InputDecoration(
                  hintText: appLocalization.translate('hint_review'),
                  hintStyle: primaryTextStyle(
                      color: Theme.of(context).textTheme.subtitle1!.color),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).textTheme.subtitle1!.color!)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).textTheme.subtitle1!.color!)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).textTheme.subtitle1!.color!)),
                ),
              ).paddingOnly(
                  left: spacing_standard_new.toDouble(),
                  right: spacing_standard_new.toDouble()),
              20.height,
              RatingBar(
                initialRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                onRatingUpdate: (rating) {
                  ratings = rating;
                },
                ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber),
                    empty:
                        Icon(Icons.star_outline_outlined, color: Colors.amber),
                    half: Icon(Icons.star, color: Colors.amber)),
              ).center(),
              Container(
                width: MediaQuery.of(context).size.width,
                child: AppButton(
                  width: context.width(),
                  text: appLocalization.translate('lbl_submit'),
                  textStyle: primaryTextStyle(color: white),
                  color: primaryColor,
                  onTap: () {
                    if (!accessAllowed) {
                      toast(appLocalization.translate("txt_sorry"));
                      return;
                    }
                    setState(() {
                      if (ratings < 1) {
                        toast(appLocalization.translate("toast_rate"));
                      } else if (reviewCont.text.isEmpty) {
                        toast(appLocalization.translate("toast_review"));
                      } else {
                        appStore.isLoading = true;
                        if (accessAllowed) {
                          postReviewApi(
                              widget.mProductId, reviewCont.text, ratings);
                          finish(context);
                        } else {
                          toast(demoPurposeMsg);
                        }
                      }
                    });
                  },
                ),
              ).paddingAll(spacing_standard_new.toDouble()),
            ],
          ),
        ),
      );
    }

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        16.height,
        Text(appLocalization.translate("lbl_ratings")!,
            style: boldTextStyle(size: 18)),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 110,
              margin: EdgeInsets.only(right: 8),
              width: 110,
              decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(60),
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  border: Border.all(width: 0.1)),
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ratings.toString(),
                          style: boldTextStyle(size: 18),
                          textAlign: TextAlign.center),
                      4.width,
                      Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                  ),
                  Text(avgRating.toString() + " Rating",
                      style: secondaryTextStyle()),
                ],
              ),
            ),
            8.width,
            Column(
              children: [
                ratingIndicator(
                    num: 5,
                    valueColor: Colors.green,
                    totalRating: fiveStars,
                    value: fiveStarPercent),
                4.height,
                ratingIndicator(
                    num: 4,
                    valueColor: Colors.lightGreenAccent,
                    totalRating: fourStars,
                    value: fourPercent),
                4.height,
                ratingIndicator(
                    num: 3,
                    valueColor: Colors.yellow,
                    totalRating: threeStars,
                    value: threePercent),
                4.height,
                ratingIndicator(
                    num: 2,
                    valueColor: Colors.yellowAccent,
                    totalRating: twoStars,
                    value: twoPercent),
                4.height,
                ratingIndicator(
                    num: 1,
                    valueColor: Colors.red,
                    totalRating: oneStars,
                    value: onePercent),
              ],
            ),
          ],
        ),
        12.height,
        Divider(thickness: 1),
        8.height,
        Observer(
          builder: (_) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(appLocalization.translate("lbl_customer_review")!,
                  style: boldTextStyle(size: 18)),
              GestureDetector(
                onTap: () async {
                  await checkLogin(context).then(
                    (value) {
                      if (value)
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: radius(10)),
                            elevation: 0.0,
                            backgroundColor: Colors.transparent,
                            child: mDialog(),
                          ),
                        );
                    },
                  );
                },
                child: Container(
                  decoration: boxDecorationWithRoundedCorners(
                      border: Border.all(color: primaryColor!),
                      borderRadius: radius(4),
                      backgroundColor: Theme.of(context).cardTheme.color!),
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Text(appLocalization.translate('lbl_rate_now')!,
                      style: primaryTextStyle(color: primaryColor)),
                ),
              ).visible(mIsUserExistInReview == false)
            ],
          ),
        ),
      ],
    ).paddingOnly(left: 16, right: 16);

    Widget mReviewListView = ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      reverse: true,
      padding: EdgeInsets.all(16),
      itemCount: mReviewModel.length,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mProfileImage.isNotEmpty
                    ? CircleAvatar(
                        backgroundColor: context.cardColor,
                        backgroundImage: NetworkImage(mProfileImage.validate()),
                        radius: 25)
                    : CircleAvatar(
                        backgroundColor: context.cardColor,
                        backgroundImage: Image.asset(User_Profile).image,
                        radius: 25),
                8.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mReviewModel[index].reviewer!, style: boldTextStyle()),
                    4.height,
                    Text(reviewConvertDate(mReviewModel[index].dateCreated),
                        style: secondaryTextStyle()),
                    4.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: 6, right: 6, top: 2, bottom: 2),
                          decoration: BoxDecoration(
                              color: mReviewModel[index].rating == 1
                                  ? primaryColor!.withOpacity(0.45)
                                  : mReviewModel[index].rating == 2
                                      ? yellowColor.withOpacity(0.45)
                                      : mReviewModel[index].rating == 3
                                          ? yellowColor.withOpacity(0.45)
                                          : Color(0xFF66953A).withOpacity(0.45),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(mReviewModel[index].rating.toString(),
                                  style: primaryTextStyle(
                                      color: whiteColor, size: 14)),
                              4.width,
                              Icon(Icons.star_border,
                                  size: 16, color: whiteColor),
                            ],
                          ),
                        ),
                        4.width,
                        Column(
                          children: [
                            Container(
                                width: context.width() * 0.50,
                                child: Text(
                                    parseHtmlString(mReviewModel[index].review),
                                    style: primaryTextStyle())),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ).expand(),
            mUserEmail == mReviewModel[index].reviewerEmail
                ? PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          value: 1,
                          child:
                              Text(appLocalization.translate("lbl_update")!)),
                      PopupMenuItem(
                          value: 2,
                          child:
                              Text(appLocalization.translate("lbl_delete")!)),
                    ],
                    initialValue: 0,
                    onSelected: (value) async {
                      if (value == 1) {
                        reviewCont.text = mReviewModel[index].review!;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: radius(10)),
                            elevation: 0.0,
                            backgroundColor: Theme.of(context).cardTheme.color,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: radius(10),
                                  backgroundColor:
                                      Theme.of(context).cardTheme.color!),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  // To make the card compact
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            appLocalization
                                                .translate('hint_review')!,
                                            style: boldTextStyle(
                                                color: Theme.of(context)
                                                    .accentColor)),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          icon: Icon(Icons.close,
                                              color:
                                                  Theme.of(context).accentColor,
                                              size: 18),
                                        )
                                      ],
                                    ).paddingOnly(
                                        left: spacing_standard_new.toDouble()),
                                    Divider(),
                                    TextFormField(
                                      controller: reviewCont,
                                      maxLines: 5,
                                      minLines: 2,
                                      cursorColor: appStore.isDarkMode!
                                          ? whiteColor
                                          : black,
                                      decoration: InputDecoration(
                                          hintText: appLocalization
                                              .translate("hint_review")),
                                    ).paddingOnly(
                                        left: spacing_standard_new.toDouble(),
                                        right: spacing_standard_new.toDouble()),
                                    20.height,
                                    RatingBar(
                                      initialRating: mReviewModel[index]
                                          .rating!
                                          .toDouble(),
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      ratingWidget: RatingWidget(
                                        full: Icon(Icons.star,
                                            color: Colors.amber),
                                        empty: Icon(Icons.star_outline_outlined,
                                            color: Colors.amber),
                                        half: Icon(Icons.star,
                                            color: Colors.amber),
                                      ),
                                      onRatingUpdate: (rating) {
                                        ratings = rating;
                                      },
                                    ).paddingOnly(
                                      left: spacing_standard_new.toDouble(),
                                      right: spacing_standard_new.toDouble(),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: AppButton(
                                        width: context.width(),
                                        text: appLocalization
                                            .translate('lbl_submit'),
                                        textStyle:
                                            primaryTextStyle(color: white),
                                        color: primaryColor,
                                        onTap: () {
                                          if (!accessAllowed) {
                                            toast(appLocalization
                                                .translate("txt_sorry"));
                                            return;
                                          }
                                          setState(() {
                                            if (!accessAllowed) {
                                              toast(appLocalization
                                                  .translate("txt_sorry"));
                                              return;
                                            }
                                            if (ratings < 1) {
                                              toast(appLocalization
                                                  .translate('toast_rate'));
                                            } else if (reviewCont
                                                .text.isEmpty) {
                                              toast(appLocalization
                                                  .translate('toast_review'));
                                            } else {
                                              onUpdateSubmit(
                                                  reviewCont.text,
                                                  ratings,
                                                  mReviewModel[index].id);
                                              finish(context);
                                            }
                                          });
                                        },
                                      ),
                                    ).paddingAll(
                                        spacing_standard_new.toDouble()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        ConfirmAction? res = await showConfirmDialogs(
                            context,
                            appLocalization.translate("msg_remove"),
                            appLocalization.translate("lbl_yes"),
                            appLocalization.translate("lbl_cancel"));
                        if (res == ConfirmAction.ACCEPT) {
                          reviewCont.clear();
                          setState(() {
                            appStore.isLoading = true;
                          });
                          deleteReviewApi(mReviewModel[index].id);
                        }
                      }
                    },
                  )
                : Container(),
          ],
        );
      },
    );

    return WillPopScope(
      onWillPop: () async {
        isUpdate = avgRating;
        finish(context, isUpdate);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: mTop(context, appLocalization.translate('lbl_reviews'),
              showBack: true) as PreferredSizeWidget?,
          body: mInternetConnection(
            Stack(
              children: <Widget>[
                mReviewModel.isNotEmpty
                    ? SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [body, mReviewListView],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(ic_data_not_found, height: 80, width: 80),
                          20.height,
                          Text(appLocalization.translate('txt_no_result')!,
                                  style: primaryTextStyle(size: 22),
                                  textAlign: TextAlign.center)
                              .paddingOnly(left: 20, right: 20),
                          30.height,
                          Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            width: context.width(),
                            child: AppButton(
                              width: context.width(),
                              text:
                                  appLocalization.translate('lbl_give_review'),
                              textStyle: primaryTextStyle(color: white),
                              color: primaryColor,
                              onTap: () {
                                if (mIsLoggedIn == true) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: radius(10)),
                                      elevation: 0.0,
                                      backgroundColor: Colors.transparent,
                                      child: mDialog(),
                                    ),
                                  );
                                } else {
                                  SignInScreen().launch(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ).visible(!appStore.isLoading!).center(),
                mProgress().visible(appStore.isLoading!).center(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mErrorMsg,
                            style: primaryTextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .color))
                        .visible(!appStore.isLoading!),
                  ],
                ).visible(mErrorMsg.isNotEmpty).center(),
              ],
            ),
          ),
          // bottomNavigationBar: isMobile
          //     ? Container(
          //         height: 60,
          //         child: AdWidget(
          //           ad: BannerAd(
          //             adUnitId: kReleaseMode
          //                 ? getBannerAdUnitId()!
          //                 : BannerAd.testAdUnitId,
          //             size: AdSize.banner,
          //             request: AdRequest(),
          //             listener: BannerAdListener(),
          //           )..load(),
          //         ),
          //       ).visible(enableAds == true)
          //     : SizedBox()),
        ),
      ),
    );
  }

  ratingIndicator(
      {int? num, Color? valueColor, int? totalRating, double? value}) {
    return Row(
      children: [
        Text(num.toString(), style: secondaryTextStyle()),
        2.width,
        Icon(Icons.star, color: Colors.amber, size: 16),
        8.width,
        Container(
          height: 6,
          width: context.width() * 0.38,
          child: LinearProgressIndicator(
              value: value, valueColor: AlwaysStoppedAnimation(valueColor)),
        ).cornerRadiusWithClipRRect(8),
        16.width,
        Text(totalRating.toString(), style: secondaryTextStyle()),
      ],
    );
  }
}
