import 'dart:ui' as ui;
import 'package:agave/const.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MultiLocationMapWidget extends StatefulWidget {
  final List<Location> locations;

  MultiLocationMapWidget({required this.locations});

  @override
  _MultiLocationMapWidgetState createState() => _MultiLocationMapWidgetState();
}

class _MultiLocationMapWidgetState extends State<MultiLocationMapWidget> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};

  Future<BitmapDescriptor> _createCustomMarkerBitmap(
      int id, double incidents) async {
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(80, 80)));

    final paint = Paint()..color = kMainColor;
    canvas.drawCircle(Offset(40, 40), 40, paint);

    // Añadimos el texto del ID y de las incidencias
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: '$id\n$incidents',
      style: TextStyle(fontSize: 16, color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset((80 - textPainter.width) / 2, (80 - textPainter.height) / 2));

    final img = await recorder.endRecording().toImage(80, 80);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> _addMarkers() async {
    for (var location in widget.locations) {
      final icon = await _createCustomMarkerBitmap(location.id, location.value);
      final marker = Marker(
        markerId: MarkerId(location.id.toString()),
        position: LatLng(location.x, location.y),
        icon: icon,
      );
      _markers.add(marker);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.locations[0].x, widget.locations[0].y),
        zoom: 17,
      ),
      markers: _markers,
    );
  }
}

class Location {
  final int id;
  final double x;
  final double y;
  final double value; // cantidad de incidencias

  Location({
    required this.id,
    required this.x,
    required this.y,
    required this.value,
  });
}
