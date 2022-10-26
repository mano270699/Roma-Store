import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../model/CategoryData.dart';
import '../screens/ViewAllScreen.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/images.dart';

import '../main.dart';

class HomeCategoryListComponent extends StatelessWidget {
  const HomeCategoryListComponent({Key? key, required this.mCategoryModel})
      : super(key: key);

  final List<Category> mCategoryModel;

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${appLocalization.translate("lbl_categories")!.toUpperCase()}',
                style: GoogleFonts.alegreyaSc(
                    color: appStore.isDarkMode!
                        ? white.withOpacity(0.7)
                        : primaryColor!,
                    fontSize: 22))
            .paddingOnly(left: 12, right: 12, bottom: 8),
        8.height,
        Container(
          height: 200,
          margin: EdgeInsets.only(left: 4),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mCategoryModel.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                childAspectRatio: 1,
                crossAxisSpacing: 14,
                mainAxisSpacing: 4),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  ViewAllScreen(mCategoryModel[index].name,
                          isCategory: true,
                          categoryId: mCategoryModel[index].id)
                      .launch(context);
                },
                child: Container(
                  height: 100,
                  child: Column(
                    children: [
                      Container(
                        width: context.width() * .22,
                        height: 70,
                        padding: EdgeInsets.all(3),
                        decoration: boxDecorationWithRoundedCorners(
                          boxShape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: appStore.isDarkMode!
                                ? [redColor, grey]
                                : [primaryColor!, blueColor.withOpacity(0.3)],
                          ),
                        ),
                        child: mCategoryModel[index].image != null
                            ? CircleAvatar(
                                backgroundColor: context.cardColor,
                                backgroundImage: NetworkImage(
                                    mCategoryModel[index]
                                        .image!
                                        .src
                                        .validate()))
                            : CircleAvatar(
                                backgroundColor: context.cardColor,
                                backgroundImage:
                                    AssetImage(ic_placeholder_logo)),
                      ),
                      4.height,
                      Container(
                        width: context.width() * 0.20,
                        child: Text(
                          parseHtmlString(mCategoryModel[index].name),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: secondaryTextStyle(
                              color: appStore.isDarkMode!
                                  ? whiteColor.withOpacity(0.7)
                                  : getColorFromHex(
                                      categoryColors[
                                          index % categoryColors.length],
                                      defaultColor: primaryColor!)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
