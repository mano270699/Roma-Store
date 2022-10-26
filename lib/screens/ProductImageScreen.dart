import '../model/ProductDetailResponse.dart';
import '../utils/app_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../main.dart';

// ignore: must_be_immutable
class ProductImageScreen extends StatefulWidget {
  final mProductImage;
  List<ImageModel>? mImgList;

  ProductImageScreen({
    Key? key,
    this.mProductImage,
    this.mImgList,
  }) : super(key: key);

  @override
  _ProductImageScreenState createState() => _ProductImageScreenState();
}

class _ProductImageScreenState extends State<ProductImageScreen> {
  List<Widget> productImg = [];

  Future productDetail() async {
    widget.mImgList!.forEach((element) {
      productImg.add(commonCacheImageWidget(element.src.toString(),
          fit: BoxFit.cover, height: 400, width: double.infinity));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: mTop(context, "", showBack: true) as PreferredSizeWidget?,
        body: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(widget.mImgList![index].src!),
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes:
                  PhotoViewHeroAttributes(tag: widget.mImgList![index].id!),
            );
          },
          itemCount: widget.mImgList!.length,
          loadingBuilder: (context, event) => Center(
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 4,
              margin: EdgeInsets.all(4),
              shape: RoundedRectangleBorder(borderRadius: radius(50)),
              child: Container(
                width: 45,
                height: 45,
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: primaryColor,
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!),
              ),
            ).center(),
          ),
        ),
      ),
    );
  }
}
