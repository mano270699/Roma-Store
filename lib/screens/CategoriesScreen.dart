import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../component/CategoryComponent/CategoryListComponent.dart';
import '../component/CategoryComponent/GalleryViewComponent.dart';
import '../main.dart';
import '../model/CategoryData.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/constants.dart';
import '../utils/images.dart';

import '../app_localizations.dart';
import 'EmptyScreen.dart';

class CategoriesScreen extends StatefulWidget {
  static String tag = '/CategoriesScreen';

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  List<Category>? mCategoryModel;
  ScrollController scrollController = ScrollController();

  String errorMsg = '';

  bool isLastPage = false;
  bool isListView = false;

  int crossAxisCount = 2;
  int page = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fetchCategoryData();
    crossAxisCount = getIntAsync(CATEGORY_CROSS_AXIS_COUNT, defaultValue: 2);
    scrollController.addListener(() {
      scrollHandler();
    });
    setState(() {});
  }

  scrollHandler() {
    setState(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !appStore.isLoading! &&
          isLastPage == false) {
        page++;
        loadMoreData(page);
      }
    });
  }

  Future fetchCategoryData() async {
    setState(() {
      appStore.isLoading = true;
    });
    await getCategories(1, TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        Iterable mCategory = res;
        mCategoryModel =
            mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        errorMsg = error.toString();
        log('WelCome');
      });
    });
  }

  Future loadMoreData(page) async {
    appStore.isLoading = true;
    setState(() {});
    await getCategories(page, TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        Iterable list = res;
        mCategoryModel!
            .addAll(list.map((model) => Category.fromJson(model)).toList());
        if (mCategoryModel!.isEmpty) {
          isLastPage = true;
        }
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: mTop(
        context,
        appLocalization.translate('lbl_categories'),
        actions: [
          Image.asset(ic_dashboard, height: 20, width: 20, color: white)
              .onTap(() {
            isListView = false;
            setState(() {});
          }),
          16.width,
          Image.asset(ic_list, height: 20, width: 20, color: white).onTap(() {
            isListView = true;
            setState(() {});
          }).paddingOnly(right: 16),
        ],
      ) as PreferredSizeWidget?,
      body: mInternetConnection(
        Stack(
          alignment: Alignment.topLeft,
          children: [
            mCategoryModel != null
                ? mCategoryModel!.isNotEmpty
                    ? SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            isListView == false
                                ? GalleryViewComponent(mCategoryModel!)
                                : CategoryListComponent(mCategoryModel!),
                            mProgress()
                                .center()
                                .visible(appStore.isLoading! && page > 1),
                            50.height,
                          ],
                        ),
                      )
                    : EmptyScreen().center().visible(!appStore.isLoading!)
                : SizedBox(),
            Center(
                child: mProgress().visible(appStore.isLoading! && page == 1)),
          ],
        ),
      ),
    );
  }
}
