import 'package:agave/backend/user_data.dart';
import 'package:agave/const.dart';
import 'package:agave/screens/agaves/agaves_screen.dart';
import 'package:agave/screens/plagas/plagas_screen.dart';
import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String tipoCoordenadas = "UTM";
  bool isLoading = true;
  bool isTestingMode = false;
  Size? size;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    tipoCoordenadas = await UserData.obtenerTipoCoordenadas() ?? "UTM";
    isTestingMode = await UserData.isTesting() ?? false;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: kMainColor,
            ))
          : ListView(
              children: [
                _buildDataConfigSection(context),
                /*   const SizedBox(height: 20),
                _buildHelpSupportSection(),
                const SizedBox(height: 20),
                _buildAppInfoSection(),
                const SizedBox(height: 20), */
              ],
            ),
    );
  }

  Widget _plagas(BuildContext context) {
    return ListTile(
      title: const Text('Plagas'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlagasScreen(),
        ),
      ),
    );
  }

  Widget _tiposPlanta(BuildContext context) {
    return ListTile(
      title: const Text('Tipos de planta'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AgavesScreen(),
        ),
      ),
    );
  }

  Widget _limpiarActividad(BuildContext context) {
    return ListTile(
      title: const Text('Limpiar actividad reciente'),
      trailing: const Icon(Icons.cleaning_services_outlined),
      onTap: () {
        _clearUserData(context);
      },
    );
  }

  Widget _tipoCoordenadasDropDown(BuildContext context) {
    //Return a drowpdonw button with the list of the types of coordinates
    return ListTile(
      title: const Text('Tipo de coordenadas'),
      trailing: DropdownButton<String>(
        value: tipoCoordenadas,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.black,
        ),
        onChanged: (String? newValue) {
          setState(() {
            tipoCoordenadas = newValue!;
            UserData.guardarTipoCoordenadas(tipoCoordenadas);
          });
        },
        items: <String>['UTM', 'Latitud/Longitud']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataConfigSection(BuildContext context) {
    return Column(
      children: [
        _plagas(context),
        _tiposPlanta(context),
        _tipoCoordenadasDropDown(context),
        /*  _testingDataModeSwitch(context),*/
        _limpiarActividad(context),

        //rate app
        /*    ListTile(
          title: const Text('Calificar aplicación'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para calificar la aplicación
            _rateApp();
          },
        ), */

        //About the app
        ListTile(
          title: const Text('Acerca de la aplicación'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para mostrar información de la aplicación
            //Show dialog with the information of the app
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Acerca de la aplicación'),
                  content: SizedBox(
                    height: size!.height * 0.6,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /* About the app */
                        Text(
                          APP_NAME,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Aplicación para el monitoreo de plagas y nutrientes en plantas de café, así como la generación de semivariogramas y mapas de contorno para el análisis de datos.',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Versión 1.0.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Desarrollado por:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Ing. José Luis Hernández Rodríguez',
                          textAlign: TextAlign.center,
                        ),
                        /* Add email pinomiranda234@gmail.com */
                        SizedBox(height: 10),
                        Text(
                          'Dr. José Francisco Ramírez Dávila',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                );
              },
            );
          },
        ),

        /*  ListTile(
          title: const Text('Exportar datos'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para exportar datos
          },
        ),
        ListTile(
          title: const Text('Importar datos'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para importar datos
          },
        ),
        ListTile(
          title: const Text('Respaldar datos en la nube'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para respaldar datos
          },
        ),
         ListTile(
          title: const Text('Sincronizar datos entre dispositivos'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para sincronizar datos
          },
        ), */
      ],
    );
  }

  Widget _testingDataModeSwitch(BuildContext context) {
    return ListTile(
      title: const Text('Modo de datos de prueba'),
      trailing: Switch(
        value: isTestingMode,
        onChanged: (value) {
          setState(() {
            UserData.setTesting(value);
            isTestingMode = value;
          });
        },
      ),
    );
  }

  void _rateApp() {}

  void _clearUserData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text(
            'Esta acción eliminará todos los datos de la actividad reciente. Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                UserData.clear();
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpSupportSection() {
    return Column(
      children: [
        ListTile(
          title: const Text('Tutoriales y guías'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para acceder a tutoriales
          },
        ),
        /*   ListTile(
          title: const Text('Contactar soporte técnico'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para contactar soporte
          },
        ), */
        ListTile(
          title: const Text('Preguntas frecuentes (FAQ)'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para acceder a FAQ
          },
        ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return Column(
      children: [
        const ListTile(
          title: Text('Versión de la aplicación'),
          // Aquí puedes mostrar la versión actual de tu aplicación.
          // Por ejemplo, utilizando el paquete 'package_info' puedes obtener esta información.
          subtitle: Text('1.0.0'),
        ),
        ListTile(
          title: const Text('Licencia y términos de servicio'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para mostrar licencia y términos
          },
        ),
        ListTile(
          title: const Text('Política de privacidad'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para mostrar política de privacidad
          },
        ),
      ],
    );
  }
}
