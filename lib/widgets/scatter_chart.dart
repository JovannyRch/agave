import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyScatterChart extends StatelessWidget {
  final List<List<double>> data;

  MyScatterChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: data
            .map((e) => ScatterSpot(e[0], e[1], radius: e[2] * 0.5))
            .toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
      ),
    );
  }
}
