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
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black38,
              ),
            ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
