import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/const.dart';
import 'package:agave/screens/Navigation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlagasModel()),
        ChangeNotifierProvider(create: (context) => AgavesModel()),
        ChangeNotifierProvider(create: (context) => EstudiosModel()),
        ChangeNotifierProvider(create: (context) => ParcelaModel()),
        ChangeNotifierProvider(create: (context) => MuestreosModel()),
        ChangeNotifierProvider(create: (context) => IncidenciasModel()),
        ChangeNotifierProvider(create: (context) => ReportesModel()),
        ChangeNotifierProvider(create: (context) => AjustesModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kriging App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: kMainColor),
      home: const Navigation(),
    );
  }
}
