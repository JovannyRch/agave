import 'package:agave/const.dart';
import 'package:agave/widgets/scatter_chart.dart';
import 'package:flutter/material.dart';

class ScatterScreen extends StatefulWidget {
  List<List<double>> data;
  ScatterScreen({required this.data});

  @override
  State<ScatterScreen> createState() => _ScatterScreenState();
}

class _ScatterScreenState extends State<ScatterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Scatter Chart"),
          backgroundColor: kMainColor,
        ),
        body: MyScatterChart(
          data: widget.data,
        ));
  }
}
