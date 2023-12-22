import 'package:agave/backend/models/actividad.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/backend/providers/muestreos_provider.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/const.dart';
import 'package:agave/screens/estudios/estudio_details_screen.dart';
import 'package:agave/screens/muestreos/muestreo_details_screen.dart';
import 'package:agave/utils/formatDate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TipoActividad {
  static String nueva_plaga = "nueva_plaga";
  static String nueva_parcela = "nueva_parcela";
  static String muestreo = "muestreo";
  static String incidencia = "incidencia";
  static String nuevo_estudio = "nuevo_estudio";
  static String nuevo_tipo_agave = "nuevo_tipo_agave";
  static String plaga_eliminada = "plaga_eliminada";
  static String update_estudio = "update_estudio";
  static String new_muestreo = "new_muestreo";
}

class ActividadItem extends StatefulWidget {
  Actividad actividad;

  ActividadItem({
    required this.actividad,
  });

  @override
  State<ActividadItem> createState() => _ActividadItemState();
}

class _ActividadItemState extends State<ActividadItem> {
  EstudiosModel? _estudiosModel;
  MuestreosModel? _muestreosModel;

  @override
  Widget build(BuildContext context) {
    _estudiosModel = Provider.of<EstudiosModel>(context);
    _muestreosModel = Provider.of<MuestreosModel>(context);
    return InkWell(
      onTap: _handleOnTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            _getIcon(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    getTitle(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatDate(widget.actividad.fecha),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (checkHasAction()) const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  String getTitle() {
    if (widget.actividad.tipo == TipoActividad.nuevo_estudio) {
      return "Nuevo Estudio \"${widget.actividad.titulo}\"";
    }

    if (widget.actividad.tipo == TipoActividad.update_estudio) {
      return "Estudio actualizado \"${widget.actividad.titulo}\"";
    }

    if (widget.actividad.tipo == TipoActividad.nueva_plaga) {
      return "Nueva plaga registrada \"${widget.actividad.titulo}\"";
    }

    if (widget.actividad.tipo == TipoActividad.nueva_parcela) {
      return "Nueva parcela \"${widget.actividad.titulo}\"";
    }

    if (widget.actividad.tipo == TipoActividad.new_muestreo) {
      return "Nuevo muestreo \"${widget.actividad.titulo}\"";
    }

    return "";
  }

  Widget _getIcon() {
    if ([TipoActividad.nuevo_estudio, TipoActividad.update_estudio]
        .contains(widget.actividad.tipo)) {
      return const Icon(
        Icons.folder,
        color: kMainColor,
        size: 30.0,
      );
    }

    if (widget.actividad.tipo == TipoActividad.nueva_plaga) {
      return const Icon(
        Icons.bug_report,
        color: kMainColor,
        size: 30.0,
      );
    }

    if (widget.actividad.tipo == TipoActividad.nueva_parcela) {
      return const Icon(
        Icons.add_location,
        color: kMainColor,
        size: 30.0,
      );
    }

    if (widget.actividad.tipo == TipoActividad.new_muestreo) {
      return const Icon(
        Icons.bug_report,
        color: kMainColor,
        size: 30.0,
      );
    }

    return const Icon(
      Icons.bug_report,
      color: Colors.red,
      size: 30.0,
    );
  }

  void _handleOnTap() async {
    if ([TipoActividad.nuevo_estudio, TipoActividad.update_estudio]
        .contains(widget.actividad.tipo)) {
      Estudio? estudio = await EstudiosProvider.db.getById(widget.actividad.id);
      if (estudio != null) {
        goToEstudio(estudio);
      }
    }

    if (widget.actividad.tipo == TipoActividad.new_muestreo) {
      Muestreo? muestreo =
          await MuestreosProvider.db.getOneWithPlaga(widget.actividad.id);
      if (muestreo != null) {
        goToMuestreo(muestreo);
      }
    }
  }

  void goToEstudio(Estudio estudio) {
    _estudiosModel?.setSelected(estudio);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstudioDetailsScreen(),
      ),
    );
  }

  void goToMuestreo(Muestreo muestreo) async {
    Parcela? parcela =
        await ParcelasProvider.db.getById(muestreo.idParcela ?? -1);

    Estudio? estudio =
        await EstudiosProvider.db.getById(muestreo.idEstudio ?? -1);

    if (parcela == null || estudio == null) {
      //Shoe snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo encontrar la parcela o el estudio'),
        ),
      );
      return;
    }
    _muestreosModel!.setSelected(muestreo);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuestreoDetailsScreen(
          parcela: parcela!,
          estudio: estudio,
          muestreo: muestreo,
        ),
      ),
    );
  }

  bool checkHasAction() {
    if ([TipoActividad.nuevo_estudio, TipoActividad.update_estudio]
        .contains(widget.actividad.tipo)) {
      return true;
    }

    if (widget.actividad.tipo == TipoActividad.new_muestreo) {
      return true;
    }
    if (widget.actividad.tipo == TipoActividad.nueva_plaga) {
      return false;
    }

    return false;
  }
}
