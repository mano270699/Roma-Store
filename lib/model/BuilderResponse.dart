class BuilderResponse {
  Dashboard? dashboard;
  Appsetup? appsetup;

  BuilderResponse({this.dashboard, this.appsetup});

  BuilderResponse.fromJson(Map<String, dynamic> json) {
    dashboard = json['dashboard'] != null
        ? new Dashboard.fromJson(json['dashboard'])
        : null;
    appsetup = json['appsetup'] != null
        ? new Appsetup.fromJson(json['appsetup'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dashboard != null) {
      data['dashboard'] = this.dashboard!.toJson();
    }
    if (this.appsetup != null) {
      data['appsetup'] = this.appsetup!.toJson();
    }
    return data;
  }
}

class Dashboard {
  List<String>? sortDashboard;
  SliderView? sliderView;
  SliderView? category;
  NewArrivals? newArrivals;
  NewArrivals? featureProduct;
  NewArrivals? hotProduct;
  NewArrivals? todayDeal;
  NewArrivals? topProduct;
  NewArrivals? offerProduct;
  NewArrivals? recommendedProduct;
  NewArrivals? seller;
  NewArrivals? youMayLikeProduct;
  SliderView? saleBanner;

  Dashboard(
      {this.sortDashboard,
        this.sliderView,
        this.category,
        this.newArrivals,
        this.featureProduct,
        this.hotProduct,
        this.todayDeal,
        this.topProduct,
        this.offerProduct,
        this.recommendedProduct,
        this.seller,
        this.youMayLikeProduct,
        this.saleBanner});

  Dashboard.fromJson(Map<String, dynamic> json) {
    sortDashboard = json['sortDashboard'].cast<String>();
    sliderView = json['sliderView'] != null
        ? new SliderView.fromJson(json['sliderView'])
        : null;
    category = json['category'] != null
        ? new SliderView.fromJson(json['category'])
        : null;
    newArrivals = json['newArrivals'] != null
        ? new NewArrivals.fromJson(json['newArrivals'])
        : null;
    featureProduct = json['featureProduct'] != null
        ? new NewArrivals.fromJson(json['featureProduct'])
        : null;
    hotProduct = json['hotProduct'] != null
        ? new NewArrivals.fromJson(json['hotProduct'])
        : null;
    todayDeal = json['todayDeal'] != null
        ? new NewArrivals.fromJson(json['todayDeal'])
        : null;
    topProduct = json['topProduct'] != null
        ? new NewArrivals.fromJson(json['topProduct'])
        : null;
    offerProduct = json['offerProduct'] != null
        ? new NewArrivals.fromJson(json['offerProduct'])
        : null;
    recommendedProduct = json['recommendedProduct'] != null
        ? new NewArrivals.fromJson(json['recommendedProduct'])
        : null;
    seller = json['seller'] != null
        ? new NewArrivals.fromJson(json['seller'])
        : null;
    youMayLikeProduct = json['youMayLikeProduct'] != null
        ? new NewArrivals.fromJson(json['youMayLikeProduct'])
        : null;
    saleBanner = json['saleBanner'] != null
        ? new SliderView.fromJson(json['saleBanner'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sortDashboard'] = this.sortDashboard;
    if (this.sliderView != null) {
      data['sliderView'] = this.sliderView!.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.newArrivals != null) {
      data['newArrivals'] = this.newArrivals!.toJson();
    }
    if (this.featureProduct != null) {
      data['featureProduct'] = this.featureProduct!.toJson();
    }
    if (this.hotProduct != null) {
      data['hotProduct'] = this.hotProduct!.toJson();
    }
    if (this.todayDeal != null) {
      data['todayDeal'] = this.todayDeal!.toJson();
    }
    if (this.topProduct != null) {
      data['topProduct'] = this.topProduct!.toJson();
    }
    if (this.offerProduct != null) {
      data['offerProduct'] = this.offerProduct!.toJson();
    }
    if (this.recommendedProduct != null) {
      data['recommendedProduct'] = this.recommendedProduct!.toJson();
    }
    if (this.seller != null) {
      data['seller'] = this.seller!.toJson();
    }
    if (this.youMayLikeProduct != null) {
      data['youMayLikeProduct'] = this.youMayLikeProduct!.toJson();
    }
    if (this.saleBanner != null) {
      data['saleBanner'] = this.saleBanner!.toJson();
    }
    return data;
  }
}

class SliderView {
  bool? enable;

  SliderView({this.enable});

  SliderView.fromJson(Map<String, dynamic> json) {
    enable = json['enable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['enable'] = this.enable;
    return data;
  }
}

class NewArrivals {
  bool? enable;
  String? title;
  String? viewAll;

  NewArrivals({this.enable, this.title, this.viewAll});

  NewArrivals.fromJson(Map<String, dynamic> json) {
    enable = json['enable'];
    title = json['title'];
    viewAll = json['viewAll'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['enable'] = this.enable;
    data['title'] = this.title;
    data['viewAll'] = this.viewAll;
    return data;
  }
}

class Appsetup {
  String? appName;
  String? primaryColor;
  String? secondaryColor;
  String? backgroundColor;
  String? textPrimaryColor;
  String? textSecondaryColor;
  String? consumerKey;
  String? consumerSecret;
  String? appUrl;

  Appsetup(
      {this.appName,
        this.primaryColor,
        this.secondaryColor,
        this.backgroundColor,
        this.textPrimaryColor,
        this.textSecondaryColor,
        this.consumerKey,
        this.consumerSecret,
        this.appUrl});

  Appsetup.fromJson(Map<String, dynamic> json) {
    appName = json['appName'];
    primaryColor = json['primaryColor'];
    secondaryColor = json['secondaryColor'];
    backgroundColor = json['backgroundColor'];
    textPrimaryColor = json['textPrimaryColor'];
    textSecondaryColor = json['textSecondaryColor'];
    consumerKey = json['consumerKey'];
    consumerSecret = json['consumerSecret'];
    appUrl = json['appUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appName'] = this.appName;
    data['primaryColor'] = this.primaryColor;
    data['secondaryColor'] = this.secondaryColor;
    data['backgroundColor'] = this.backgroundColor;
    data['textPrimaryColor'] = this.textPrimaryColor;
    data['textSecondaryColor'] = this.textSecondaryColor;
    data['consumerKey'] = this.consumerKey;
    data['consumerSecret'] = this.consumerSecret;
    data['appUrl'] = this.appUrl;
    return data;
  }
}
