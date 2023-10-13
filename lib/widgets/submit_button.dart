import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  const SubmitButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            onPressed();
          },
          child: Text(text),
        ),
      ]),
    );
  }
}
