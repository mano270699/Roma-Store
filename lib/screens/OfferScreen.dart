import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import '../component/ProductComponent.dart';
import '../model/ProductResponse.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'EmptyScreen.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({Key? key}) : super(key: key);

  @override
  _OfferScreenState createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  List<ProductResponse> mOfferProduct = [];

  int? page = 1;
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fetchOfferData();
  }

  Future fetchOfferData() async {
    setState(() {
      appStore.isLoading = true;
    });
    await offerProductList().then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        Iterable list = res['data'];
        mOfferProduct =
            list.map((model) => ProductResponse.fromJson(model)).toList();
        mErrorMsg = 'No Products';
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        mErrorMsg = 'No Products';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    Widget availableOfferAndDeal(List<ProductResponse> product) {
      return StaggeredGridView.countBuilder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: product.length,
        shrinkWrap: true,
        crossAxisCount: 2,
        padding: EdgeInsets.all(12),
        crossAxisSpacing: 16,
        mainAxisSpacing: 8,
        itemBuilder: (context, i) {
          return ProductComponent(
                  mProductModel: product[i], width: context.width() * 0.4)
              .paddingOnly(top: 8);
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.fit(1);
        },
      );
    }

    Widget dealOfTheDay() {
      return Column(
        children: [
          availableOfferAndDeal(mOfferProduct)
              .visible(mOfferProduct.isNotEmpty),
        ],
      );
    }

    return Scaffold(
      appBar: mTop(context, appLocalization!.translate('lbl_offer_zone'),
          showBack: true) as PreferredSizeWidget?,
      body: mInternetConnection(
        Stack(
          children: [
            mOfferProduct.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        dealOfTheDay(),
                        mProgress()
                            .center()
                            .visible(appStore.isLoading! && page! > 1),
                      ],
                    ),
                  )
                : EmptyScreen().center().visible(!appStore.isLoading!),
            mProgress().center().visible(appStore.isLoading! && page == 1),
          ],
        ),
      ),
    );
  }
}
