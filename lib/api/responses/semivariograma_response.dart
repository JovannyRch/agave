import 'dart:convert';

class SemivariogramaResponse {
  List<double>? lags;
  String? image_base64;
  List<double>? semivariance;
  double? nugget;
  double? sill;
  double? range;

  SemivariogramaResponse({
    this.lags,
    this.image_base64,
    this.semivariance,
    this.nugget,
    this.sill,
    this.range,
  });

  SemivariogramaResponse.fromJson(String jsonResponse) {
    final json = Map<String, dynamic>.from(jsonDecode(jsonResponse));
    lags = json['lags'].cast<double>();
    image_base64 = json['image_base64'];
    semivariance = json['semivariance'].cast<double>();
    nugget = double.parse(json['nugget'].toString());
    sill = double.parse(json['sill'].toString());
    range = double.parse(json['range'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lags'] = this.lags;
    data['image_base64'] = this.image_base64;
    data['semivariance'] = this.semivariance;
    data['nugget'] = this.nugget;
    data['sill'] = this.sill;
    return data;
  }
}
