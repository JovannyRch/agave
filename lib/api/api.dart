import 'dart:convert';
import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:http/http.dart' as http;
import 'package:agave/api/responses/semivariograma_response.dart';

String API_BASE_URL = "https://goldfish-app-oqgqm.ondigitalocean.app";

class Api {
  static String getApiUrl(String endpoint) {
    return API_BASE_URL + endpoint;
  }

  static Future<SemivariogramaResponse?> getExperimentalSemivariogram(
      List<List<double>> points) async {
    final response = await http.post(
      Uri.parse(getApiUrl("/semivariogram")),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"points": points, "testing": true}),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return SemivariogramaResponse.fromJson(response.body);
    }
    throw Exception('Failed to load semivariogram');
  }

  static Future<KrigingContourResponse?> getKrigingContour(
      List<double> lats, List<double> lons, List<int> values) async {
    final response = await http.post(
      Uri.parse(getApiUrl("/kriging_contour")),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "lats": lats,
        "lons": lons,
        "values": values,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return KrigingContourResponse.fromJson(response.body);
    }
    throw Exception('Failed to load semivariogram');
  }
}
