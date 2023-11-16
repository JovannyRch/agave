import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  final IconData? icon;

  const RoundedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed as void Function()?,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Round button
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: icon != null
                ? Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
