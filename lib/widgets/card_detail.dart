import 'package:flutter/material.dart';

class CardDetail extends StatelessWidget {
  String title;
  String value;
  String? unit;
  IconData? icon;
  Color? color;
  bool isCenter = false;

  CardDetail({
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.color,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
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
      crossAxisAlignment:
          isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black38,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
              isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Text(
              cutText(value, unit != null ? 12 : 16),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
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

  String cutText(String text, int limit) {
    if (text.length > limit) {
      return text.substring(0, limit - 1) + "...";
    }
    return text;
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
