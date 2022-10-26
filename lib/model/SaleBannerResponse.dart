class Salebanner {
  String? image;
  String? thumb;
  String? url;

  Salebanner({this.image, this.thumb, this.url});

  Salebanner.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    thumb = json['thumb'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['thumb'] = this.thumb;
    data['url'] = this.url;
    return data;
  }
}
