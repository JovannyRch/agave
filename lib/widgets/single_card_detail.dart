import 'package:agave/widgets/card_detail.dart';
import 'package:flutter/material.dart';

class SingleCardDetail extends StatelessWidget {
  String title;
  String value;
  String? unit;

  SingleCardDetail({
    required this.title,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CardDetail(
        title: title,
        value: value,
        unit: unit,
      ),
    );
  }
}
