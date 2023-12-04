import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  final double? mt;

  const SubmitButton({Key? key, required this.text, this.onPressed, this.mt})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        SizedBox(
          height: mt ?? 20.0,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: onPressed as void Function()?,
          child: Text(text),
        ),
      ]),
    );
  }
}
