import 'package:proj4dart/proj4dart.dart';

class UtmResult {
  final double easting;
  final double northing;
  final String zone;

  UtmResult(this.easting, this.northing, this.zone);
}

UtmResult latLonToUtm(double latitude, double longitude) {
  // Determinar la zona UTM basada en la longitud
  int zoneNumber = ((longitude + 180) / 6).floor() + 1;

  // Crear la definición de la proyección UTM
  String utmDefinition =
      "+proj=utm +zone=$zoneNumber ${latitude >= 0 ? '+north' : '+south'} +ellps=WGS84 +datum=WGS84 +units=m +no_defs";

  // Definir la proyección WGS 84 y la proyección UTM correspondiente
  final sourceCRS = Projection.get('EPSG:4326');
  final destinationCRS = Projection.parse(utmDefinition);

  // Convertir las coordenadas
  final point = Point(x: longitude, y: latitude);
  final result = destinationCRS.forward(point);

  // Determinar la banda UTM basada en la latitud
  final letters = 'CDEFGHIJKLMNPQRSTUVWX';
  int latIndex = ((latitude + 80) / 8).floor().clamp(0, letters.length - 1);
  String band = letters[latIndex];

  return UtmResult(result.x, result.y, '${zoneNumber}${band}');
}
