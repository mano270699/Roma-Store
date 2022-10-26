import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../model/ProductResponse.dart';
import '../../utils/constants.dart';
import '../../utils/images.dart';

import '../../main.dart';
import '../ProductComponent.dart';

class DashboardComponent extends StatefulWidget {
  const DashboardComponent(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.product,
      required this.onTap})
      : super(key: key);

  final String title, subTitle;
  final List<ProductResponse> product;
  final Function onTap;

  @override
  _DashboardComponentState createState() => _DashboardComponentState();
}

class _DashboardComponentState extends State<DashboardComponent> {
  Widget productList(List<ProductResponse> product) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: StaggeredGridView.countBuilder(
        scrollDirection: Axis.vertical,
        itemCount: product.length >= TOTAL_DASHBOARD_ITEM
            ? TOTAL_DASHBOARD_ITEM
            : product.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return ProductComponent(
                  mProductModel: product[i], width: context.width())
              .paddingAll(4);
        },
        crossAxisCount: 2,
        staggeredTileBuilder: (index) {
          return StaggeredTile.fit(1);
        },
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8),
          width: context.width(),
          decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(0), backgroundColor: context.cardColor),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(ic_heading, fit: BoxFit.cover),
              Column(
                children: [
                  Text(widget.title.toUpperCase(),
                      style: GoogleFonts.alegreyaSc(
                          color: appStore.isDarkMode!
                              ? white.withOpacity(0.7)
                              : primaryColor!,
                          fontSize: 22)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.subTitle,
                              style: GoogleFonts.alegreyaSc(
                                  color: textSecondaryColour, fontSize: 16))
                          .onTap(() {
                        widget.onTap.call();
                      }),
                      Icon(
                        Icons.chevron_right,
                        color: textSecondaryColour,
                        size: 20,
                      )
                    ],
                  ).visible(widget.product.length >= TOTAL_DASHBOARD_ITEM),
                ],
              )
            ],
          ).paddingOnly(top: 16, bottom: 16).visible(widget.product.isNotEmpty),
        ),
        productList(widget.product).visible(widget.product.isNotEmpty),
      ],
    );
  }
}
