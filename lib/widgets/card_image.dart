import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Base64CardImage extends StatefulWidget {
  bool isLoading;
  String image;
  double width;

  Base64CardImage({
    this.isLoading = false,
    required this.image,
    required this.width,
  });

  @override
  State<Base64CardImage> createState() => _CardImageState();
}

class _CardImageState extends State<Base64CardImage> {
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return SizedBox(
      width: _size.width * 0.9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10.0),
          widget.isLoading
              ? const CircularProgressIndicator()
              : GestureDetector(
                  onTap: () {
                    showImageViewer(
                      context,
                      Image.memory(
                        fit: BoxFit.cover,
                        Base64Decoder().convert(
                          widget.image,
                        ),
                      ).image,
                      onViewerDismissed: () {
                        print("dismissed");
                      },
                    );
                  },
                  child: SizedBox(
                    width: widget.width,
                    height: widget.width,
                    child: Image.memory(
                      fit: BoxFit.cover,
                      Base64Decoder().convert(
                        widget.image,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
