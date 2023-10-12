import 'package:flutter/material.dart';

class CardDetail extends StatelessWidget {
  String title;
  String value;
  String? unit;

  CardDetail({
    required this.title,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        /*   boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ], */
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null)
                Text(
                  unit!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black38,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
