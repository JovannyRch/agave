import 'dart:convert';

import 'package:agave/api/api.dart';
import 'package:agave/api/responses/semivariograma_response.dart';
import 'package:flutter/material.dart';

class SemivariogramaExperimentalScreen extends StatefulWidget {
  SemivariogramaResponse semivariogramaResponse;
  SemivariogramaExperimentalScreen({required this.semivariogramaResponse});

  @override
  State<SemivariogramaExperimentalScreen> createState() =>
      _SemivariogramaExperimentalScreenState();
}

class _SemivariogramaExperimentalScreenState
    extends State<SemivariogramaExperimentalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semivariograma Experimental'),
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
          widget.semivariogramaResponse.image_base64 ?? "",
        ),
      ),
    );
  }
}


/* 

10,13,14,8,25,36,45,14,4,3,4,3,14,7,3,4,4,13,5,6,10,14,19,16,9,23,12,56,2,1

 */