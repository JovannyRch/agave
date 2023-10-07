import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/configuraciones_screen.dart';
import 'package:agave/screens/estudios/estudios_screen.dart';
import 'package:agave/screens/inicio_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomeScreen(),
    const EstudiosScreen(),
    const ConfiguracionScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<PlagasModel>(context, listen: false).fetchData();
    Provider.of<AgavesModel>(context, listen: false).fetchData();
    Provider.of<EstudiosModel>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Estudios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuraciones',
          )
        ],
      ),
    );
  }
}
