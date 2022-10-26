import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../component/ProductComponent.dart';
import '../model/CategoryData.dart';
import '../model/ProductAttribute.dart';
import '../model/ProductResponse.dart';
import '../model/SearchRequest.dart';
import '../network/rest_apis.dart';
import 'EmptyScreen.dart';
import '../utils/app_widgets.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import '../utils/images.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'ProductDetailScreen.dart';
import 'SubCategoryScreen.dart';

// ignore: must_be_immutable
class ViewAllScreen extends StatefulWidget {
  static String tag = '/ViewAllScreen';
  bool? isFeatured = false;
  bool? isNewest = false;
  bool? isSpecialProduct = false;
  bool? isBestSelling = false;
  bool? isSale = false;
  bool? isCategory = false;
  int? categoryId = 0;
  String? specialProduct = "";
  String? startDate = "";
  String? endDate = "";
  String? headerName = "";

  ViewAllScreen(this.headerName,
      {this.isFeatured,
      this.isSale,
      this.isCategory,
      this.categoryId,
      this.isNewest,
      this.isSpecialProduct,
      this.isBestSelling,
      this.specialProduct,
      this.startDate,
      this.endDate});

  @override
  ViewAllScreenState createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  String errorMsg = '';
  List<ProductResponse> mProductModel = [];
  List<Category> mCategoryModel = [];
  List<ProductAttribute> mAttributes = [];

  var searchRequest = SearchRequest();

  ScrollController scrollController = ScrollController();

  int page = 1;
  int? noPages;
  int crossAxisCount = 2;

  bool mIsLoggedIn = false;
  bool isLastPage = false,
      isListViewSelected = false,
      isLoading = false,
      isLoadingMoreData = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    var crossAxisCount1 = getIntAsync(CROSS_AXIS_COUNT, defaultValue: 2);
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN);
    setState(() {
      crossAxisCount = crossAxisCount1;
    });

    if (widget.isCategory == true) {
      fetchCategoryData();
      fetchSubCategoryData();
    } else {
      searchRequest.onSale = widget.isSale != null
          ? widget.isSale!
              ? "_sale_price"
              : ""
          : "";
      searchRequest.featured = widget.isFeatured != null
          ? widget.isFeatured!
              ? "product_visibility"
              : ""
          : "";
      searchRequest.bestSelling = widget.isBestSelling != null
          ? widget.isBestSelling!
              ? "total_sales"
              : ""
          : "";
      searchRequest.newest = widget.isNewest != null
          ? widget.isNewest!
              ? "newest"
              : ""
          : "";
      searchRequest.specialProduct = widget.isSpecialProduct != null
          ? widget.isSpecialProduct!
              ? widget.specialProduct
              : ""
          : "";
      page = 1;
      getAllProducts();
    }
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  scrollHandler() {
    if (widget.isCategory == true) {
      setState(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            noPages! > page &&
            !isLoading) {
          page++;
          loadMoreCategoryProduct(page);
        }
      });
    } else {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          noPages! > page &&
          !isLoading) {
        page++;
        getAllProducts();
      }
    }
  }

  Future loadMoreCategoryProduct(page) async {
    setState(() {
      isLoadingMoreData = true;
      isLoading = true;
    });
    var data = {
      "category": widget.categoryId,
      "page": page,
      "perPage": TOTAL_ITEM_PER_PAGE
    };
    await searchProduct(data).then((res) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;
        ProductListResponse listResponse = ProductListResponse.fromJson(res);
        setState(() {
          if (page == 1) {
            mProductModel.clear();
          }
          noPages = listResponse.numOfPages;
          mProductModel.addAll(listResponse.data!);
          isLoadingMoreData = false;
          if (mProductModel.isEmpty) {
            isLastPage = true;
          }
        });
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;
      });
    });
  }

  Future loadMoreCategoryData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    isLoading = true;
    await getAllCategories(widget.categoryId, page, TOTAL_ITEM_PER_PAGE)
        .then((res) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;
        Iterable list = res;
        mProductModel.addAll(
            list.map((model) => ProductResponse.fromJson(model)).toList());
        if (mProductModel.isEmpty) {
          isLastPage = true;
        }
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;
      });
    });
  }

  Future fetchCategoryData() async {
    setState(() {
      isLoading = true;
    });

    var data = {
      "category": widget.categoryId,
      "page": 1,
      "perPage": TOTAL_ITEM_PER_PAGE
    };

    print("Request $data");

    await searchProduct(data).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        ProductListResponse listResponse = ProductListResponse.fromJson(res);
        setState(() {
          if (page == 1) {
            mProductModel.clear();
          }
          noPages = listResponse.numOfPages;
          mProductModel.addAll(listResponse.data!);
          isLoading = false;
        });
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      print("Error:" + error.toString());
    });
  }

  Future fetchSubCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getSubCategories(widget.categoryId, page).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable mCategory = res;
        mCategoryModel =
            mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget mSubCategory(List<Category> category) {
    return HorizontalList(
      itemCount: category.length,
      padding: EdgeInsets.only(right: 16, top: 16, bottom: 16, left: 8),
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
            SubCategoryScreen(mCategoryModel[i].name,
                    categoryId: mCategoryModel[i].id)
                .launch(context);
          },
          child: Container(
            margin: EdgeInsets.only(left: 10),
            decoration: boxDecorationRoundedWithShadow(8),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Positioned(
                    top: 0,
                    child: commonCacheImageWidget(category[i].image!.src,
                        height: 190, fit: BoxFit.cover)),
                Image.asset(ic_categories, fit: BoxFit.cover, height: 230),
                Text(parseHtmlString(category[i].name),
                        style: primaryTextStyle(color: blackColor))
                    .paddingBottom(10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    setValue(CARTCOUNT, appStore.count);

    Widget _itemListWidget(ProductResponse product, BuildContext context) {
      String img = product.images!.isNotEmpty
          ? product.images!.first.src.validate()
          : '';

      return Container(
        margin: EdgeInsets.only(top: 4, bottom: 4),
        decoration: boxDecorationWithShadow(
            borderRadius: radius(8.0),
            backgroundColor: context.scaffoldBackgroundColor),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 90,
            width: 90,
            decoration: boxDecorationWithRoundedCorners(
                borderRadius: radius(8),
                backgroundColor: Theme.of(context).colorScheme.background),
            child: Stack(
              children: [
                commonCacheImageWidget(img,
                        height: 120, width: 90, fit: BoxFit.cover)
                    .cornerRadiusWithClipRRect(8),
                mSale(product, appLocalization.translate('lbl_sale')!),
              ],
            ),
          ),
          10.width,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            8.height,
            Text(product.name, style: primaryTextStyle(), maxLines: 2),
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PriceWidget(
                        price: product.salePrice.validate().isNotEmpty
                            ? product.salePrice.toString()
                            : product.price.validate(),
                        size: 14,
                        color: primaryColor),
                    4.width,
                    PriceWidget(
                            price: product.regularPrice.validate().toString(),
                            size: 12,
                            isLineThroughEnabled: true,
                            color: Theme.of(context).textTheme.subtitle1!.color)
                        .visible(product.salePrice.validate().isNotEmpty)
                  ],
                ),
              ],
            ).paddingOnly(bottom: 8),
          ]).expand(),
        ]).paddingAll(8),
      );
    }

    Widget _gridProducts = StaggeredGridView.countBuilder(
        scrollDirection: Axis.vertical,
        itemCount: mProductModel.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(right: 12, left: 12),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        itemBuilder: (context, index) {
          return ProductComponent(
              mProductModel: mProductModel[index], width: context.width());
        },
        crossAxisCount: 2,
        staggeredTileBuilder: (index) {
          return StaggeredTile.fit(1);
        });

    Widget _listProduct = ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: mProductModel.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(right: 8, left: 8, bottom: 8),
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              ProductDetailScreen(mProId: mProductModel[index].id)
                  .launch(context);
            },
            child: _itemListWidget(mProductModel[index], context));
      },
    );

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(
          context,
          parseHtmlString(widget.headerName),
          showBack: true,
          actions: [mCart(context, mIsLoggedIn)],
        ) as PreferredSizeWidget?,
        body: mInternetConnection(
          Stack(
            children: <Widget>[
              mProductModel.isNotEmpty
                  ? SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: context.width(),
                            decoration: boxDecorationWithRoundedCorners(
                                borderRadius: radius(0),
                                backgroundColor:
                                    primaryColor!.withOpacity(0.03)),
                            child: Column(
                              children: [
                                10.height.visible(widget.isCategory != null &&
                                    widget.isCategory! &&
                                    mCategoryModel.isNotEmpty),
                                Text(
                                        appLocalization
                                            .translate("txt_categories")!
                                            .toUpperCase(),
                                        style: GoogleFonts.alegreyaSc(
                                            color: primaryColor, fontSize: 20))
                                    .visible(widget.isCategory != null &&
                                        widget.isCategory! &&
                                        mCategoryModel.isNotEmpty),
                                Text(
                                        appLocalization
                                            .translate("txt_sub_categories")!
                                            .toUpperCase(),
                                        style: GoogleFonts.alegreyaSc(
                                            color: textSecondaryColour,
                                            fontSize: 12))
                                    .visible(widget.isCategory != null &&
                                        widget.isCategory! &&
                                        mCategoryModel.isNotEmpty),
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
                                ).visible(widget.isCategory != null &&
                                    widget.isCategory! &&
                                    mCategoryModel.isNotEmpty),
                                mSubCategory(mCategoryModel).visible(
                                    widget.isCategory != null &&
                                        widget.isCategory! &&
                                        mCategoryModel.isNotEmpty),
                              ],
                            ),
                          ),
                          8.height,
                          Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(
                                      left: 8, bottom: 8, top: 8),
                                  width: context.width(),
                                  decoration: boxDecorationWithRoundedCorners(
                                      borderRadius: radius(0),
                                      backgroundColor: context.cardColor),
                                  child: Text(
                                      appLocalization
                                          .translate("lbl_in_focus")!
                                          .toUpperCase(),
                                      style: GoogleFonts.alegreyaSc(
                                          color: primaryColor, fontSize: 22)))
                              .visible(widget.isCategory != null &&
                                  widget.isCategory! &&
                                  mCategoryModel.isNotEmpty),
                          crossAxisCount == 1 ? _listProduct : _gridProducts,
                          mProgress().visible(isLoading && page > 1).center()
                        ],
                      ))
                  : EmptyScreen()
                      .visible(!isLoading && mProductModel.isEmpty)
                      .center(),
              Center(
                  child: mProgress()
                      .paddingAll(24)
                      .visible(isLoading && page == 1))
            ],
          ),
        ),
      ),
    );
  }

  getAllProducts() async {
    setState(() {
      isLoading = true;
      searchRequest.page = page;
    });
    await searchProduct(searchRequest.toJson()).then((res) {
      if (!mounted) return;
      log(res);
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        if (page == 1) {
          mProductModel.clear();
        }
        noPages = listResponse.numOfPages;
        mProductModel.addAll(listResponse.data!);
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
        errorMsg = "No Data Found";
        if (page == 1) {
          mProductModel.clear();
        }
      });
    });
  }
}
