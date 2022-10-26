import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import '../component/ProductComponent.dart';
import '../model/CategoryData.dart';
import '../model/ProductResponse.dart';
import '../network/rest_apis.dart';
import 'EmptyScreen.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/constants.dart';

import '../main.dart';

// ignore: must_be_immutable
class SubCategoryScreen extends StatefulWidget {
  static String tag = '/SubCategory';
  int? categoryId = 0;
  String? headerName = "";

  SubCategoryScreen(this.headerName, {this.categoryId});

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  var scrollController = new ScrollController();

  List<ProductResponse> mProductModel = [];
  List<Category> mCategoryModel = [];

  bool isLoadingMoreData = false;
  bool isLastPage = false;
  bool mIsLoggedIn = false;

  int page = 1;
  int crossAxisCount = 2;

  var sortType = -1;

  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    init();
    fetchCategoryData();
    fetchSubCategoryData();
  }

  init() async {
    crossAxisCount = getIntAsync(CROSS_AXIS_COUNT, defaultValue: 2);
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN);
    scrollController.addListener(() {
      scrollHandler();
    });
    setState(() {});
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage) {
      page++;
      loadMoreCategoryData(page);
    }
  }

  Future loadMoreCategoryData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    var data = {
      "category": widget.categoryId,
      "page": page,
      "perPage": TOTAL_ITEM_PER_PAGE
    };
    await searchProduct(data).then((res) {
      if (!mounted) return;
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        if (page == 1) {
          mProductModel.clear();
        }
        mProductModel.addAll(listResponse.data!);
        isLoadingMoreData = false;
        isLastPage = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLastPage = true;
        isLoadingMoreData = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future fetchCategoryData() async {
    appStore.setLoading(true);
    var data = {
      "category": widget.categoryId,
      "page": 1,
      "perPage": TOTAL_ITEM_PER_PAGE
    };
    await searchProduct(data).then((res) {
      if (!mounted) return;
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      appStore.setLoading(false);
      setState(() {
        if (page == 1) {
          mProductModel.clear();
        }
        mProductModel.addAll(listResponse.data!);
      });
    }).catchError((error) {
      appStore.setLoading(false);
      if (!mounted) return;
      setState(() {});
    });
  }

  Future fetchSubCategoryData() async {
    appStore.setLoading(true);
    await getSubCategories(widget.categoryId, page).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable mCategory = res;
        mCategoryModel =
            mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Widget mSubCategory(List<Category> category) {
    return Container(
      alignment: Alignment.topLeft,
      height: MediaQuery.of(context).size.width * 0.12,
      child: ListView.builder(
        itemCount: category.length,
        padding: EdgeInsets.only(left: 8, right: 8, top: 12),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              SubCategoryScreen(mCategoryModel[i].name,
                      categoryId: mCategoryModel[i].id)
                  .launch(context);
            },
            child: Container(
              margin: EdgeInsets.only(right: spacing_standard.toDouble()),
              decoration:
                  boxDecorationWithRoundedCorners(borderRadius: radius(10)),
              padding: EdgeInsets.fromLTRB(0, spacing_standard.toDouble(),
                  spacing_standard.toDouble(), spacing_standard.toDouble()),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  commonCacheImageWidget(category[i].image!.src,
                      width: MediaQuery.of(context).size.width * 0.1,
                      fit: BoxFit.contain),
                  4.width,
                  Text(parseHtmlString(category[i].name),
                      style: primaryTextStyle(
                          size: textSizeSMedium,
                          color: getColorFromHex(
                              categoryColors[i % categoryColors.length]))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setValue(CARTCOUNT, appStore.count);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(
          context,
          widget.headerName,
          showBack: true,
          actions: [mCart(context, mIsLoggedIn)],
        ) as PreferredSizeWidget?,
        body: mInternetConnection(
          Stack(
            children: [
              mProductModel.isNotEmpty
                  ? SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: <Widget>[
                          mSubCategory(mCategoryModel)
                              .visible(mCategoryModel.isNotEmpty),
                          StaggeredGridView.countBuilder(
                              scrollDirection: Axis.vertical,
                              itemCount: mProductModel.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.all(8),
                              itemBuilder: (context, index) {
                                return ProductComponent(
                                    mProductModel: mProductModel[index],
                                    width: context.width());
                              },
                              crossAxisCount: crossAxisCount,
                              staggeredTileBuilder: (index) {
                                return StaggeredTile.fit(1);
                              },
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16),
                          mProgress().visible(isLoadingMoreData).center()
                        ],
                      ),
                    )
                  : EmptyScreen().visible(!appStore.isLoading!).center(),
              mProgress().paddingAll(8).center().visible(appStore.isLoading!)
            ],
          ),
        ),
      ),
    );
  }
}
