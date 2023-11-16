import 'package:flutter/material.dart';

class CardDetail extends StatelessWidget {
  String title;
  String value;
  String? unit;
  IconData? icon;
  Color? color;

  CardDetail({
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      height: 100.0,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(10),

        /*    boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ], */
      ),
      child: icon != null ? _columnWithIcon(context, _content()) : _content(),
    );
  }

  Widget _content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit != null) const SizedBox(width: 3),
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
    );
  }

  Widget _columnWithIcon(BuildContext context, Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 30,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(
          width: 10.0,
        ),
        content,
      ],
    );
  }
}
