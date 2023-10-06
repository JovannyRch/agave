import 'package:agave/screens/agaves/agaves_screen.dart';
import 'package:agave/screens/plagas/plagas_screen.dart';
import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: <Widget>[
          _buildDataConfigSection(context),
          _buildHelpSupportSection(),
          _buildAppInfoSection(),
        ],
      ),
    );
  }

  Widget _buildDataConfigSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Plagas'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlagasScreen(),
            ),
          ),
        ),
        ListTile(
          title: const Text('Tipos de agave'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgavesScreen(),
            ),
          ),
        ),
        ListTile(
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
        /*  ListTile(
          title: const Text('Sincronizar datos entre dispositivos'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Acción para sincronizar datos
          },
        ), */
      ],
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
