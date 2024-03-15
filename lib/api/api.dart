import 'dart:convert';
import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:agave/backend/user_data.dart';
import 'package:http/http.dart' as http;
import 'package:agave/api/responses/semivariograma_response.dart';

String API_BASE_URL = "https://kriging-backend.onrender.com";

class ModelParams {
  double sill;
  double range;
  double nugget;

  ModelParams({
    required this.sill,
    required this.range,
    required this.nugget,
  });

  Map<String, dynamic> toJson() {
    return {
      "sill": sill,
      "range": range,
      "nugget": nugget,
    };
  }
}

class Api {
  static String getApiUrl(String endpoint) {
    return API_BASE_URL + endpoint;
  }

  static Future<SemivariogramaResponse?> getExperimentalSemivariogram(
      List<List<double>> points, int n_lags) async {
    final response = await http.post(
      Uri.parse(getApiUrl("/semivariogram")),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "points": points,
        "n_lags": n_lags,
        "testing": await UserData.isTesting()
      }),
    );

    if (response.statusCode == 200) {
      return SemivariogramaResponse.fromJson(response.body);
    }
    throw Exception('Failed to load semivariogram');
  }

  static Future<SemivariogramaResponse?> getCustomSemivariogram(
    List<List<double>> points,
    int n_lags,
    double sill,
    double range,
    double nugget,
    String model,
  ) async {
    final response = await http.post(
      Uri.parse(getApiUrl("/custom_semivariogram")),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "points": points,
        "n_lags": n_lags,
        "sill": sill,
        "range": range,
        "nugget": nugget,
        "variogram_model": model,
        "testing": await UserData.isTesting()
      }),
    );

    if (response.statusCode == 200) {
      return SemivariogramaResponse.fromJson(response.body);
    }
    throw Exception('Failed to load semivariogram');
  }

  static Future<KrigingContourResponse?> getKrigingContour(
    List<List<double>> points,
    String variogram_model,
    ModelParams modelParams,
  ) async {
    final response = await http.post(
      Uri.parse(getApiUrl("/generate_contour")),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "points": points,
        "variogram_model": variogram_model,
        "testing": await UserData.isTesting(),
        "model_params": modelParams.toJson(),
        "coordinates": await UserData.isUtm() ? "utm" : "latlng",
      }),
    );

    if (response.statusCode == 200) {
      return KrigingContourResponse.fromJson(response.body);
    }
    throw Exception('Failed to load semivariogram');
  }

  static Future<String?> getScatterPlot(
    List<List<double>> points,
  ) async {
    final response = await http.post(
      Uri.parse(getApiUrl("/scatter")),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "points": points,
      }),
    );

    if (response.statusCode == 200) {
      final json = Map<String, dynamic>.from(jsonDecode(response.body));
      return json['image_base64'];
    }
    throw Exception('Failed to load semivariogram');
  }
}
