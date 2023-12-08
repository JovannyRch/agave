import 'package:agave/screens/general/image_loader.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Base64CardImage extends StatefulWidget {
  bool isLoading;
  String image;
  String title;

  Base64CardImage({
    this.isLoading = false,
    this.title = "Imagen",
    required this.image,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageLoaderScreen(
                          loadImage: () async {
                            return widget.image;
                          },
                          title: widget.title,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
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
