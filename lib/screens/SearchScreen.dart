import '../component/ProductComponent.dart';
import '../model/ProductAttribute.dart';
import '../model/ProductResponse.dart';
import '../model/SearchRequest.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'EmptyScreen.dart';

class SearchScreen extends StatefulWidget {
  static String tag = '/SearchScreen';

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  List<ProductResponse> mProductModel = [];
  List<Terms> mTerms = [];
  List<Attribute> mAttributeModel = [];
  int page = 1;
  var mErrorMsg = '';
  var searchText = "";
  var isSearchDone = false;
  var controller = TextEditingController();
  var focusNode = FocusNode();
  var isAttributesLoaded = false;
  var searchRequest = SearchRequest();
  var scrollController = new ScrollController();
  int? noPages;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        searchText = controller.text;
      });
    });
    init();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  init() async {
    getAttributes();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  void onTextChange(String value) async {
    log(value);
    setState(() {
      searchText = value;
      searchRequest.text = value;
      page = 1;
    });
    searchProducts();
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        noPages! > page &&
        !appStore.isLoading!) {
      page++;
      searchProducts();
    }
  }

  searchProducts() async {
    setState(() {
      appStore.isLoading = true;
    });
    var req = {
      "text": searchText,
      "attribute": searchRequest.attribute ?? [],
      "price": searchRequest.price ?? [],
      "page": page
    };
    log(searchRequest.toJson());
    await searchProduct(req).then((res) {
      if (!mounted) return;
      log(res);
      setState(() {
        appStore.isLoading = false;
      });
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        isSearchDone = true;
        if (page == 1) {
          mProductModel.clear();
        }
        noPages = listResponse.numOfPages;
        mProductModel.addAll(listResponse.data!);
        appStore.isLoading = false;
        if (mProductModel.isEmpty) {
          mErrorMsg = "No Data Found";
        }
      });
    }).catchError((error) {
      log(error);
      setState(() {
        appStore.isLoading = false;
        mErrorMsg = "No Data Found";
        isSearchDone = true;
        if (page == 1) {
          mProductModel.clear();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setValue(CARTCOUNT, appStore.count);

    var appLocalization = AppLocalizations.of(context)!;
    Widget body = StaggeredGridView.countBuilder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      crossAxisCount: 2,
      staggeredTileBuilder: (index) {
        return StaggeredTile.fit(1);
      },
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      padding: EdgeInsets.only(left: 8, right: 8),
      physics: NeverScrollableScrollPhysics(),
      itemCount: mProductModel.length,
      itemBuilder: (_, index) {
        return Container(
            margin: EdgeInsets.all(6.0),
            child: ProductComponent(mProductModel: mProductModel[index]));
      },
    );

    return Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        elevation: 0,
        child: FilterScreen(mAttributeModel, mTerms, (attribute) {
          searchRequest.attribute = attribute;
          page = 1;
          setState(() {});
          searchProducts();
        }),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Stack(
          children: [
            Container(height: 75, color: primaryColor),
            AppBar(
                elevation: 0,
                backgroundColor:
                    appStore.isDarkMode! ? darkColor : primaryColor!,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: white),
                  onPressed: () {
                    finish(context);
                  },
                ),
                title: TextFormField(
                  autofocus: true,
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: onTextChange,
                  cursorColor: Colors.white,
                  style: secondaryTextStyle(color: Colors.white, size: 16),
                  decoration: InputDecoration(
                    hintText: appLocalization.translate('lbl_search'),
                    hintStyle:
                        secondaryTextStyle(color: Colors.white, size: 16),
                    border: OutlineInputBorder(
                        borderRadius: radius(10), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.only(left: 0, right: 0),
                  ),
                ),
                actions: [
                  IconButton(
                      icon: Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          controller.clear();
                        });
                      }).visible(searchText.isNotEmpty),
                  IconButton(
                      onPressed: () {
                        if (!isAttributesLoaded) {
                          toast(appLocalization.translate("txt_please_wait"));
                          return;
                        }
                        scaffoldKey.currentState!.openEndDrawer();
                      },
                      icon:
                          Icon(Icons.filter_alt, size: 24, color: Colors.white))
                ],
                automaticallyImplyLeading: false),
            Container(margin: EdgeInsets.only(top: 60)),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollController,
              child: Column(children: [
                body,
                mProgress()
                    .paddingAll(spacing_standard_new.toDouble())
                    .visible(appStore.isLoading! && page > 1),
              ]),
            ).visible(mProductModel.isNotEmpty),
            mProgress().center().visible(appStore.isLoading! && page == 1),
            EmptyScreen().center().visible(mErrorMsg.isNotEmpty &&
                !appStore.isLoading! &&
                mProductModel.isEmpty),
          ],
        ),
      ),
    );
  }

  void getAttributes() async {
    await getProductAttribute().then((res) {
      if (!mounted) return;
      ProductAttribute mAttributess = ProductAttribute.fromJson(res);
      List<Terms> list = [];
      List<Attribute> list1 = [];
      mAttributess.attribute!.forEach((element) {
        list1.add(element);
        list.add(Terms(name: element.name, isParent: true, isSelected: false));
        element.terms!.forEach((term) {
          list.add(term);
        });
      });
      setState(() {
        isAttributesLoaded = true;
        mTerms.addAll(list);
        mAttributeModel.addAll(list1);
      });
    }).catchError((error) {
      log(error);
      setState(() {
        isAttributesLoaded = false;
      });
    });
  }
}

int selectedIndex = 0;

// ignore: must_be_immutable
class FilterScreen extends StatefulWidget {
  List<Attribute> mAttributeModel = [];
  List<Terms> mTerms = [];
  final void Function(List<Map<String, Object>>?) onDataChange;

  FilterScreen(this.mAttributeModel, this.mTerms, this.onDataChange);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return Scaffold(
      bottomNavigationBar: Container(
        height: 60,
        padding: EdgeInsets.all(8),
        width: context.width(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              decoration: boxDecorationRoundedWithShadow(8,
                  backgroundColor: context.cardColor),
              child: Text(
                appLocalization.translate("lbl_cancel")!,
                style: secondaryTextStyle(size: 16, color: primaryColor),
              ),
            ).onTap(() {
              finish(context);
            }).expand(),
            10.width,
            Container(
              alignment: Alignment.center,
              decoration: boxDecorationRoundedWithShadow(8,
                  backgroundColor: primaryColor!),
              child: Text(
                appLocalization.translate("lbl_apply")!,
                style: secondaryTextStyle(size: 16, color: white),
              ),
            ).onTap(() {
              var map = Map<String?, List<int?>>();
              widget.mAttributeModel.forEach((storeProductAttribute) {
                storeProductAttribute.terms!.forEach((element) {
                  if (element.isSelected!) {
                    if (map.containsKey(element.taxonomy)) {
                      map[element.taxonomy]?.add(element.termId);
                    } else {
                      List<int?> list = [];
                      list.add(element.termId);
                      map[element.taxonomy] = list;
                    }
                  }
                });
              });
              List<Map<String, Object>> list = [];
              map.keys.forEach((key) {
                Map<String, Object> attribute = Map<String, Object>();
                attribute[key!] = map[key]!;
                list.add(attribute);
              });
              widget.onDataChange(list);
              finish(context);
            }).expand(),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: widget.mAttributeModel.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var selectedCount = 0;
              widget.mAttributeModel[index].total = selectedCount;
              return Container(
                width: context.width(),
                decoration:
                    boxDecorationWithShadow(backgroundColor: context.cardColor),
                margin: EdgeInsets.only(bottom: 8, top: 8),
                padding: EdgeInsets.only(left: 16, top: 8, right: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.mAttributeModel[index].name!,
                        style: boldTextStyle(size: 16)),
                    8.height,
                    getCurrentList(index),
                    8.height,
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getCurrentList(int index) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(widget.mAttributeModel[index].terms!.length, (i) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
                borderRadius: radius(10),
                border: Border.all(
                    color: widget.mAttributeModel[index].terms![i].isSelected!
                        ? primaryColor!
                        : Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .color!
                            .withOpacity(0.1)),
              ),
              child: Text(
                widget.mAttributeModel[index].terms![i].name!,
                style: secondaryTextStyle(
                  size: 14,
                  color: widget.mAttributeModel[index].terms![i].isSelected!
                      ? primaryColor
                      : Theme.of(context).textTheme.subtitle1!.color,
                ),
              ),
            ),
          ],
        ).onTap(() {
          widget.mAttributeModel[index].terms![i].isSelected =
              !widget.mAttributeModel[index].terms![i].isSelected!;
          setState(() {});
        });
      }),
    );
  }
}
