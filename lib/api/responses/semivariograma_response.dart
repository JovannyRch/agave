import 'dart:convert';

class SemivariogramaResponse {
  List<double>? lags;
  String? image_base64;
  List<double>? semivariance;

  SemivariogramaResponse({this.lags, this.image_base64, this.semivariance});

  SemivariogramaResponse.fromJson(String jsonResponse) {
    final json = Map<String, dynamic>.from(jsonDecode(jsonResponse));
    lags = json['lags'].cast<double>();
    image_base64 = json['image_base64'];
    semivariance = json['semivariance'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lags'] = this.lags;
    data['image_base64'] = this.image_base64;
    data['semivariance'] = this.semivariance;
    return data;
  }
}
