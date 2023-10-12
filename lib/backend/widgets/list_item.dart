import 'package:agave/const.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  String title;
  String? subtitle;
  IconData? icon;
  Function? onTap;

  ListItem({required this.title, this.subtitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 70.0,
        margin: const EdgeInsets.only(
          bottom: 5.0,
          top: 2.5,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: kMainColor.withOpacity(0.1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: Icon(
                icon,
                size: 30.0,
                color: kMainColor.withOpacity(0.75),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () => onTap!(),
    );
  }
}
