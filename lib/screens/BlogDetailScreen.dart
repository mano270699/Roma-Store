import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../main.dart';
import '../model/BlogResponse.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/common.dart';

class BlogDetailScreen extends StatefulWidget {
  static String tag = '/BlogDetailScreen';
  final int? mId;

  BlogDetailScreen({Key? key, this.mId}) : super(key: key);

  @override
  BlogDetailScreenState createState() => BlogDetailScreenState();
}

class BlogDetailScreenState extends State<BlogDetailScreen> {
  BlogResponse post = BlogResponse();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fetchBlogDetail();
  }

  Future fetchBlogDetail() async {
    appStore.setLoading(true);
    log(widget.mId);
    await getBlogDetail(widget.mId).then((res) {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {
        post = BlogResponse.fromJson(res);
      });
    }).catchError((error) {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {
        log("error" + error.toString());
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: mTop(context, '', showBack: true) as PreferredSizeWidget?,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: mInternetConnection(
        Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(post.postTitle.validate(),
                          style: boldTextStyle(size: 18))
                      .paddingOnly(left: 16, right: 16),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          appLocalization.translate('lbl_publish_from')! +
                              post.postAuthorName.validate(),
                          style: secondaryTextStyle()),
                      Text(createDateFormat(post.postDate.validate()),
                          style: secondaryTextStyle()),
                    ],
                  ).paddingOnly(left: 16, right: 16),
                  16.height,
                  commonCacheImageWidget(post.image.validate(),
                      width: context.width(),
                      height: context.height() * 0.40,
                      fit: BoxFit.cover),
                  20.height,
                  Text(parseHtmlString(post.postContent.validate()),
                          style: secondaryTextStyle(),
                          textAlign: TextAlign.justify)
                      .paddingOnly(left: 16, right: 16),
                ],
              ).paddingOnly(bottom: 16),
            ).visible(!appStore.isLoading!),
            mProgress().center().visible(appStore.isLoading!),
          ],
        ),
      ),
    );
  }
}
