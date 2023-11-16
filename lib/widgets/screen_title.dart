import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  String title;
  String? subtitle;

  ScreenTitle({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(height: subtitle != null ? 4 : 0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
