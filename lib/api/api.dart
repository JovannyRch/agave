import 'dart:convert';
import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:agave/const.dart';
import 'package:http/http.dart' as http;
import 'package:agave/api/responses/semivariograma_response.dart';

String API_BASE_URL = "https://goldfish-app-oqgqm.ondigitalocean.app";

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
      List<List<double>> points) async {
    print(points);
    final response = await http.post(
      Uri.parse(getApiUrl("/semivariogram")),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"points": points, "testing": IS_TESTING}),
    );

    if (response.statusCode == 200) {
      print(response.body);
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
        "testing": IS_TESTING,
        "model_params": modelParams.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      return KrigingContourResponse.fromJson(response.body);
    }
    throw Exception('Failed to load semivariogram');
  }
}
