import 'dart:io';
import 'dart:typed_data';

import 'package:agave/const.dart';
import 'package:agave/utils/exportIncidencias.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class ImageLoaderScreen extends StatefulWidget {
  final Future<String?> Function() loadImage;
  String? title;

  ImageLoaderScreen({
    Key? key,
    required this.loadImage,
    this.title,
  }) : super(key: key);

  @override
  _ImageLoaderScreenState createState() => _ImageLoaderScreenState();
}

class _ImageLoaderScreenState extends State<ImageLoaderScreen> {
  late Future<String?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = widget.loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Imagen'),
        backgroundColor: kMainColor,
      ),
      body: FutureBuilder<String?>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Error al cargar la imagen: ${snapshot.error}')),
              );
              Navigator.of(context).pop();
            });
            return SizedBox(); // O puedes mostrar un widget vacío
          } else {
            return _content(snapshot.data ?? "");
          }
        },
      ),
    );
  }

  Widget _content(String base64Image) {
    return Column(children: [
      Image.memory(
        fit: BoxFit.cover,
        Base64Decoder().convert(
          base64Image,
        ),
      ),
      SizedBox(height: 20),
      _addImageActionButtons(base64Image),
    ]);
  }

  Widget _addImageActionButtons(String base64Image) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: RoundedButton(
            onPressed: () {
              _downloadImage(base64Image);
            },
            icon: Icons.download,
            text: 'Descargar',
          ),
        ),
        Expanded(
          child: RoundedButton(
            onPressed: () {
              _shareImage(base64Image);
            },
            icon: Icons.share,
            text: 'Compartir',
          ),
        ),
        //Full screen view button
        Expanded(
          child: RoundedButton(
            onPressed: () {
              final imageProvider = Image.memory(
                fit: BoxFit.cover,
                Base64Decoder().convert(
                  base64Image,
                ),
              ).image;
              showImageViewer(context, imageProvider, onViewerDismissed: () {
                print("dismissed");
              });
            },
            icon: Icons.fullscreen,
            text: 'Expandir',
          ),
        ),
      ],
    );
  }

  void _downloadImage(String base64Image) async {
    Uint8List bytes = base64.decode(base64Image);
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/imagen.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imagen guardada en: $imagePath'),
      ),
    );
  }

  void _shareImage(String base64Image) {
    guardarImagen(base64Image, "Mapa de contorno");
  }
}
