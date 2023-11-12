import 'dart:convert';

import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:flutter/material.dart';

class KrigingContour extends StatefulWidget {
  KrigingContourResponse krigingContourResponse;
  KrigingContour({required this.krigingContourResponse});

  @override
  State<KrigingContour> createState() => _KrigingContourState();
}

class _KrigingContourState extends State<KrigingContour> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de contorno'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _body,
    );
  }

  Widget get _body => Container(
        child: Column(
          children: [
            _renderSemmivariogramImage(),
          ],
        ),
      );

  Widget _buildChart() {
    return Container(
      child: Column(),
    );
  }

  Widget _renderSemmivariogramImage() {
    return Container(
      child: Image.memory(
        fit: BoxFit.cover,
        Base64Decoder().convert(
          widget.krigingContourResponse.image_base64 ?? "",
        ),
      ),
    );
  }
}
