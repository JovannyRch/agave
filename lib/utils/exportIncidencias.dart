import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:share/share.dart';

Future<String> getFilePath(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  return "${directory.path}/$fileName";
}

Future<String> readCsvFile(String fileName) async {
  String filePath = await getFilePath(fileName);
  File file = File(filePath);
  return file.readAsString();
}

Future<String> readCsvFileFromPath(FilePickerResult result) async {
  String? filePath = result.files.single.path;
  if (filePath != null) {
    File file = File(filePath);
    return file.readAsString();
  } else {
    throw Exception('No se seleccionó ningún archivo');
  }
}

String convertirIncidenciasACsv(List<Incidencia> incidencias) {
  List<String> filas = [];
  filas.add("x,y,incidencia"); // Encabezado del CSV

  for (var incidencia in incidencias) {
    var fila = [
      incidencia.x.toString(),
      incidencia.y.toString(),
      incidencia.value.toString(),
    ].join(',');
    filas.add(fila);
  }

  return filas.join('\n');
}

Future<void> compartirArchivo(String rutaArchivo) async {
  await Share.shareFiles([rutaArchivo], text: '');
}

Future<void> compartirImagen(String rutaImagen) async {
  await Share.shareFiles([rutaImagen], text: '');
}

Future<bool> guardarImagen(String base64Image, String nombreArchivo) async {
  try {
    // Obtener el directorio local de la aplicación
    final directorio = await getApplicationDocumentsDirectory();
    String ruta = '${directorio.path}/$nombreArchivo.png';

    // Escribir en el archivo
    File archivo = File(ruta);
    await archivo.writeAsBytes(base64Decode(base64Image));
    await compartirImagen(ruta);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> guardarCsv(String csvData, String nombreArchivo) async {
  try {
    // Obtener el directorio local de la aplicación
    final directorio = await getApplicationDocumentsDirectory();
    String ruta = '${directorio.path}/$nombreArchivo.csv';

    // Escribir en el archivo
    File archivo = File(ruta);
    await archivo.writeAsString(csvData);
    await compartirArchivo(ruta);

    return true;
  } catch (e) {
    return false;
  }
}

Future<FilePickerResult?> pickCsvFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null) {
    return result;
  } else {
    return null;
  }
}

Future<List<List<dynamic>>> loadCsvData(String csvContent) async {
  List<List<dynamic>> csvTable =
      const CsvToListConverter(eol: '\n').convert(csvContent);

  return csvTable.sublist(1);
}
