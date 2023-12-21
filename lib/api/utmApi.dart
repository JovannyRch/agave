import 'package:http/http.dart' as http;
import 'dart:convert';

class UtmApiResponse {
  final double easting;
  final double northing;
  final String zone;

  UtmApiResponse({
    required this.easting,
    required this.northing,
    required this.zone,
  });

  factory UtmApiResponse.fromJson(Map<String, dynamic> json) {
    return UtmApiResponse(
      easting: double.parse(json['easting']),
      northing: double.parse(json['northing']),
      zone: json['zone'],
    );
  }
  @override
  String toString() {
    return 'UtmApiResponse{easting: $easting, northing: $northing, zone: $zone}';
  }
}

Future<UtmApiResponse?> latLongToUTM(double lat, double long) async {
  final baseUrl = "https://www.latlong.net/dec2utm.php";
  //Log params

  final fullUrl =
      "$baseUrl?lat=${lat.toStringAsFixed(6)}&long=${long.toStringAsFixed(6)}";

  final response = await http.get(Uri.parse(fullUrl));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body) as List<dynamic>;
    if (jsonResponse.isNotEmpty) {
      final utmData = jsonResponse[0] as Map<String, dynamic>;

      return UtmApiResponse.fromJson(utmData);
    }
  }
  throw Exception('Failed to load UTM data');
}
