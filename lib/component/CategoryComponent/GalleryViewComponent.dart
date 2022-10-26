import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../model/CategoryData.dart';
import '../../screens/ViewAllScreen.dart';
import '../../utils/app_widgets.dart';
import '../../utils/common.dart';
import '../../utils/images.dart';

// ignore: must_be_immutable
class GalleryViewComponent extends StatefulWidget {
  static String tag = '/GalleryViewComponent';
  List<Category> mCategoryModel;

  GalleryViewComponent(this.mCategoryModel);

  @override
  GalleryViewComponentState createState() => GalleryViewComponentState();
}

class GalleryViewComponentState extends State<GalleryViewComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: widget.mCategoryModel.length,
      shrinkWrap: true,
      crossAxisCount: 2,
      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            ViewAllScreen(
              widget.mCategoryModel[index].name,
              isCategory: true,
              categoryId: widget.mCategoryModel[index].id,
            ).launch(context);
          },
          child: Container(
            decoration: boxDecorationWithShadow(
                borderRadius: radius(8.0),
                backgroundColor: context.scaffoldBackgroundColor),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(8.0)),
                  height: 170,
                  width: context.width(),
                  child: widget.mCategoryModel[index].image != null
                      ? commonCacheImageWidget(
                              widget.mCategoryModel[index].image!.src
                                  .validate(),
                              fit: BoxFit.cover)
                          .cornerRadiusWithClipRRect(8)
                      : Image.asset(ic_placeholder_logo, fit: BoxFit.cover)
                          .cornerRadiusWithClipRRect(8),
                ),
                Container(
                  height: 170,
                  decoration: boxDecorationWithShadow(
                      borderRadius: radius(8.0),
                      backgroundColor: black.withOpacity(0.4)),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                      parseHtmlString(
                          widget.mCategoryModel[index].name.validate()),
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: boldTextStyle(
                          size: 20, color: white.withOpacity(0.9))),
                )
              ],
            ),
          ),
        ).paddingAll(8);
      },
      staggeredTileBuilder: (int index) {
        return StaggeredTile.fit(1);
      },
    );
  }
}
