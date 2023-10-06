import 'package:agave/screens/estudios_tab.dart';
import 'package:agave/screens/parcelas_tab.dart';
import 'package:flutter/material.dart';

class EstudiosParcelasScreen extends StatefulWidget {
  const EstudiosParcelasScreen({super.key});

  @override
  State<EstudiosParcelasScreen> createState() => _EstudiosParcelasScreenState();
}

class _EstudiosParcelasScreenState extends State<EstudiosParcelasScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Estudios y parcelas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Estudios"),
              Tab(text: "Parcelas"),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            EstudiosTab(),
            ParcelasTab(),
          ],
        ),
      ),
    );
  }
}
