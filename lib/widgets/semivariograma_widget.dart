import 'package:agave/const.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SemivariogramChart extends StatelessWidget {
  final List<double> lags; // Tus lags del semivariograma experimental
  final List<double>
      semivariance; // Semivarianza del semivariograma experimental
  final List<double>
      modelSemivariance; // Semivarianza del modelo teórico ajustado

  final double sill; // Sill del modelo teórico ajustado
  final double range; // Rango del modelo teórico ajustado
  final double nuggget; // Nugget del modelo teórico ajustado
  final double maxX;
  final double maxY;

  const SemivariogramChart({
    Key? key,
    required this.lags,
    required this.semivariance,
    required this.modelSemivariance,
    required this.sill,
    required this.range,
    required this.nuggget,
    required this.maxX,
    required this.maxY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 10.0,
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX * 1.06,
          minY: 0,
          maxY: maxY * 1.06,
          lineBarsData: [
            _experimentalSemiVariance(),
            _sillLineData(),
            _rangeLineData(),
            _modelSemiVarianceLineData(),
          ],
          titlesData: const FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
        ),

        duration: Duration(milliseconds: 150), // Optional
        curve: Curves.linear, // Optional
      ),
    );
  }

  LineChartBarData _experimentalSemiVariance() {
    return LineChartBarData(
      spots: [
        ...List.generate(
          lags.length,
          (index) => FlSpot(
            lags[index],
            semivariance[index],
          ),
        ),
      ],
      isCurved: false,
      barWidth: 0.0,
      color: Colors.red,
      isStrokeCapRound: false,
      dotData: const FlDotData(
        show: true,
      ),
    );
  }

  LineChartBarData _modelSemiVarianceLineData() {
    if (modelSemivariance.isEmpty) {
      return LineChartBarData(
        spots: [],
      );
    }

    return LineChartBarData(
      spots: [
        FlSpot(
          0,
          nuggget,
        ),
        ...List.generate(
          lags.length,
          (index) => FlSpot(
            lags[index],
            modelSemivariance[index],
          ),
        ),
      ],
      isCurved: false,
      barWidth: 2.5,
      color: kMainColor,
      isStrokeCapRound: false,
      dotData: const FlDotData(
        show: true,
      ),
    );
  }

  LineChartBarData _sillLineData() {
    return LineChartBarData(
      spots: [
        FlSpot(
          0,
          sill,
        ),
        FlSpot(
          maxY * 1.06,
          sill,
        ),
      ],
      isCurved: false,
      barWidth: 2,
      color: kMainColor.withOpacity(0.5),
      isStrokeCapRound: false,
      dotData: const FlDotData(
        show: false,
      ),
    );
  }

  LineChartBarData _rangeLineData() {
    return LineChartBarData(
      color: kMainColor.withOpacity(0.5),
      spots: [
        FlSpot(
          range,
          0,
        ),
        FlSpot(
          range,
          maxY * 1.06,
        ),
      ],
      isCurved: false,
      barWidth: 2,
      isStrokeCapRound: false,
      dotData: const FlDotData(
        show: false,
      ),
    );
  }

  LineChartBarData _nuggetLineData() {
    return LineChartBarData(
      spots: [
        FlSpot(
          0,
          nuggget,
        ),
      ],
      isCurved: false,
      barWidth: 1,
      color: kMainColor,
      isStrokeCapRound: false,
      dotData: const FlDotData(
        show: true,
      ),
    );
  }
}
