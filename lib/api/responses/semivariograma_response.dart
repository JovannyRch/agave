import 'dart:convert';

class SemivariogramaResponse {
  List<double>? lags;
  String? image_base64;
  List<double>? semivariance;
  double? nugget;
  double? sill;
  double? range;
  String? model;

  SemivariogramaResponse({
    this.lags,
    this.image_base64,
    this.semivariance,
    this.nugget,
    this.sill,
    this.range,
    this.model,
  });

  SemivariogramaResponse.fromJson(String jsonResponse) {
    jsonResponse = jsonResponse.replaceAll("NaN", "0");
    try {
      final json = Map<String, dynamic>.from(jsonDecode(jsonResponse));

      lags = json['lags'].cast<double>();
      sill = double.parse(json['sill'].toString());
      image_base64 = json['image_base64'];
      nugget = double.parse(json['nugget'].toString());
      range = double.parse(json['range'].toString());
      semivariance = json['semivariance'].cast<double>();
      model = json['model'];
    } catch (e) {
      print("Error parsing semivariograma response: $e");
    }
  }

  List<double> castSemivarianceFromJson(Map<String, dynamic> json) {
    return json['semivariance'].map<dynamic>((e) {
      if (e is String && e.contains("NaN")) {
        return 0;
      }
      try {
        return double.parse(e.toString());
      } catch (e) {
        return 0;
      }
    }).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lags'] = this.lags;
    data['image_base64'] = this.image_base64;
    data['semivariance'] = this.semivariance;
    data['nugget'] = this.nugget;
    data['sill'] = this.sill;
    data['range'] = this.range;
    return data;
  }

  @override
  String toString() {
    return 'SemivariogramaResponse{lags: $lags, semivariance: $semivariance, nugget: $nugget, sill: $sill, range: $range, model: $model}';
  }
}
