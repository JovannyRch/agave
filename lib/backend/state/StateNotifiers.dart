import 'package:agave/backend/models/ajustes.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/models/actividad.dart';
import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/incidencia_plaga.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/models/reporteConteo.dart';
import 'package:agave/backend/providers/agave_provider.dart';
import 'package:agave/backend/providers/ajustes_provider.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/backend/providers/incidencias_provider.dart';
import 'package:agave/backend/providers/muestreos_provider.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/backend/providers/plagas_provider.dart';
import 'package:agave/backend/providers/reportes_provider.dart';
import 'package:agave/backend/user_data.dart';
import 'package:agave/widgets/actividad_item.dart';
import 'package:flutter/material.dart';

class PlagasModel with ChangeNotifier {
  List<Plaga> _plagas = [];

  List<Plaga> get plagas => _plagas;

  fetchData() async {
    _plagas = await PlagasProvider.db.getAll();
    notifyListeners();
  }

  delete(int id) async {
    await PlagasProvider.db.delete(id, DB.plagas);

    List<Actividad> actividadRecientes =
        await UserData.obtenerActividadReciente();

    for (Actividad actividad in actividadRecientes) {
      if (actividad.id == id && (actividad.tipo == TipoActividad.nueva_plaga)) {
        actividadRecientes.remove(actividad);
        break;
      }
    }
    await UserData.guardarActividadReciente(actividadRecientes);

    _plagas.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  add(Plaga plaga) async {
    Plaga newItem = await PlagasProvider.db.insert(plaga);
    _plagas.add(newItem);
    notifyListeners();
  }

  update(Plaga plaga) async {
    await PlagasProvider.db.update(plaga);
    _plagas = _plagas.map((item) {
      if (item.id == plaga.id) {
        item = plaga;
      }
      return item;
    }).toList();
    notifyListeners();
  }
}

class AgavesModel with ChangeNotifier {
  List<Agave> _agaves = [];

  List<Agave> get agaves => _agaves;

  fetchData() async {
    _agaves = await AgaveProvider.db.getAll();
    notifyListeners();
  }

  add(Agave agave) async {
    Agave newItem = await AgaveProvider.db.insert(agave);
    _agaves.add(newItem);
    UserData.addActividad(
      Actividad(
        id: newItem.id ?? -1,
        titulo: newItem.nombre ?? "",
        fecha: DateTime.now().toIso8601String(),
        tipo: TipoActividad.nuevo_tipo_agave,
      ),
    );
    notifyListeners();
  }

  delete(int id) async {
    await AgaveProvider.db.delete(id, DB.plantas);

    List<Actividad> actividadRecientes =
        await UserData.obtenerActividadReciente();

    for (Actividad actividad in actividadRecientes) {
      if (actividad.id == id &&
          (actividad.tipo == TipoActividad.nuevo_tipo_agave)) {
        actividadRecientes.remove(actividad);
        break;
      }
    }
    await UserData.guardarActividadReciente(actividadRecientes);

    _agaves.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  update(Agave agave) async {
    await AgaveProvider.db.update(agave);
    _agaves = _agaves.map((item) {
      if (item.id == agave.id) {
        item = agave;
      }
      return item;
    }).toList();
    notifyListeners();
  }
}

class EstudiosModel with ChangeNotifier {
  List<Estudio> _estudios = [];
  List<Parcela> _parcelas = [];
  Estudio? _estudio;

  List<Estudio> get estudios => _estudios;
  Estudio? get estudio => _estudio;
  List<Parcela> get parcelas => _parcelas;

  fetchData() async {
    _estudios = await EstudiosProvider.db.getAll();
    notifyListeners();
  }

  Future<Estudio?> add(Estudio estudio) async {
    Estudio newItem = await EstudiosProvider.db.insert(estudio);
    _estudios.add(newItem);

    UserData.addActividad(
      Actividad(
        id: newItem.id ?? -1,
        titulo: estudio.nombre ?? "",
        fecha: DateTime.now().toIso8601String(),
        tipo: TipoActividad.nuevo_estudio,
      ),
    );

    notifyListeners();
    return newItem;
  }

  desvincularParcela(int idParcela) async {
    await ParcelasProvider.db.desvincular(_estudio!.id ?? 0, idParcela);
    _parcelas.removeWhere((item) => item.id == idParcela);
    notifyListeners();
  }

  delete(int id) async {
    await EstudiosProvider.db.delete(id, DB.estudios);
    _estudios.removeWhere((item) => item.id == id);
    List<Actividad> actividadRecientes =
        await UserData.obtenerActividadReciente();
    for (Actividad actividad in actividadRecientes) {
      if (actividad.id == id &&
          (actividad.tipo == TipoActividad.nuevo_estudio ||
              actividad.tipo == TipoActividad.update_estudio)) {
        actividadRecientes.remove(actividad);
        break;
      }
    }
    await UserData.guardarActividadReciente(actividadRecientes);
    notifyListeners();
  }

  update(Estudio estudio) async {
    await EstudiosProvider.db.update(estudio);
    _estudios = _estudios.map((item) {
      if (item.id == estudio.id) {
        item = estudio;
      }
      return item;
    }).toList();
    /* UserData.addActividad(
      Actividad(
        id: estudio.id ?? -1,
        titulo: estudio.nombre ?? "",
        fecha: DateTime.now().toIso8601String(),
        tipo: TipoActividad.update_estudio,
      ),
    ); */
    notifyListeners();
  }

  setSelected(Estudio? estudio) {
    _estudio = estudio;
    fetchParcelas(estudio?.id ?? 0);
  }

  Future<bool> addParcela(Parcela parcela) async {
    Parcela? newItem = await EstudiosProvider.db
        .joinParcela(_estudio!.id ?? 0, parcela.id ?? 0);

    if (newItem == null) {
      return false;
    }
    _parcelas.add(newItem);
    notifyListeners();
    return true;
  }

  fetchParcelas(int id) async {
    _parcelas = await EstudiosProvider.db.getParcelas(_estudio!.id ?? 0);
    notifyListeners();
  }
}

class ParcelaModel with ChangeNotifier {
  List<Parcela> _parcelas = [];
  final bool _isLoading = false;

  List<Parcela> get parcelas => _parcelas;
  bool get isLoading => _isLoading;

  fetchData() async {
    _parcelas = await ParcelasProvider.db.getAllWithAgave();
    notifyListeners();
  }

  add(Parcela parcela) async {
    Parcela newItem = await ParcelasProvider.db.insert(parcela);
    Parcela newItemWithAgave =
        await ParcelasProvider.db.getOneWithAgave(newItem.id ?? 0);
    _parcelas.add(newItemWithAgave);

    UserData.addActividad(
      Actividad(
        id: newItem.id ?? -1,
        titulo: newItem.nombre ?? "",
        fecha: DateTime.now().toIso8601String(),
        tipo: TipoActividad.nueva_parcela,
      ),
    );

    notifyListeners();
  }

  delete(int id) async {
    await ParcelasProvider.db.delete(id, DB.parcelas);
    _parcelas.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

class MuestreosModel with ChangeNotifier {
  List<Muestreo> _muestreos = [];
  Muestreo? _selectedMuestreo;

  List<Muestreo> get muestreos => _muestreos;
  Muestreo? get selectedMuestreo => _selectedMuestreo;

  fetchData(int idEstudio, int idParcela) async {
    _muestreos =
        await MuestreosProvider.db.getAllWithPlagas(idEstudio, idParcela);
    notifyListeners();
  }

  add(Muestreo muestreo) async {
    Muestreo newItem = await MuestreosProvider.db.insert(muestreo);
    Muestreo? newItemWithPlaga =
        await MuestreosProvider.db.getOneWithPlaga(newItem.id ?? 0);
    if (newItemWithPlaga == null) return;
    _muestreos.add(newItemWithPlaga);
    UserData.addActividad(
      Actividad(
        id: newItem.id ?? -1,
        titulo: newItemWithPlaga.nombrePlaga ?? "",
        fecha: DateTime.now().toIso8601String(),
        tipo: TipoActividad.new_muestreo,
      ),
    );

    notifyListeners();
  }

  delete(int id) async {
    await MuestreosProvider.db.delete(id, DB.muestreos);
    _muestreos.removeWhere((item) => item.id == id);

    List<Actividad> actividadRecientes =
        await UserData.obtenerActividadReciente();

    for (Actividad actividad in actividadRecientes) {
      if (actividad.id == id &&
          (actividad.tipo == TipoActividad.new_muestreo)) {
        actividadRecientes.remove(actividad);
        break;
      }
    }

    await UserData.guardarActividadReciente(actividadRecientes);

    final ultimaPlaga = await UserData.obtenerUltimaPlaga();
    if (ultimaPlaga?.idMuestreo == id) {
      await UserData.eliminarUltimaPlaga();
    }

    notifyListeners();
  }

  setSelected(Muestreo muestreo) {
    _selectedMuestreo = muestreo;
    notifyListeners();
  }
}

class IncidenciasModel with ChangeNotifier {
  List<Incidencia> _incidencias = [];

  List<Incidencia> get incidencias => _incidencias;

  fetchData(int idMuestreo) async {
    _incidencias = await IncidenciasProvider.db.getAll(idMuestreo);
    notifyListeners();
  }

  Future add(Incidencia item) async {
    Incidencia newItem = await IncidenciasProvider.db.insert(item);
    _incidencias.add(newItem);

    notifyListeners();
  }

  Future delete(int id) async {
    await IncidenciasProvider.db.delete(id, DB.incidencias);
    _incidencias.removeWhere((item) => item.id == id);

    notifyListeners();
  }

  Future update(Incidencia item) async {
    await IncidenciasProvider.db.update(item);
    _incidencias = _incidencias.map((incidencia) {
      if (incidencia.id == item.id) {
        incidencia = item;
      }
      return incidencia;
    }).toList();
    notifyListeners();
  }

  deleteAllIncidencias(List<Incidencia> incidencias) async {
    for (Incidencia incidencia in incidencias) {
      await IncidenciasProvider.db.delete(incidencia.id ?? 0, DB.incidencias);
    }
    _incidencias = [];
    notifyListeners();
  }
}

class ReportesModel with ChangeNotifier {
  List<IncidenciaPlaga> _incidenciasPlaga = [];
  ReporteConteo? _reporteConteo;

  List<IncidenciaPlaga> get incidenciasPlaga => _incidenciasPlaga;

  ReporteConteo? get reporteConteo => _reporteConteo;

  fetchData() async {
    _incidenciasPlaga = await ReportesProvider.db.incidenciasPorPlaga();
    _reporteConteo = await ReportesProvider.db.reporteConteo();
    notifyListeners();
  }
}

class AjustesModel with ChangeNotifier {
  List<Ajuste> _ajustes = [];

  List<Ajuste> get ajustes => _ajustes;

  fetchData(int idMuestreo) async {
    _ajustes = await AjustesProvider.db.getAll(idMuestreo);
    notifyListeners();
  }

  Future add(Ajuste item) async {
    Ajuste newItem = await AjustesProvider.db.insert(item);
    _ajustes.add(newItem);

    notifyListeners();
  }

  Future delete(int id) async {
    await AjustesProvider.db.delete(id, DB.ajustes);
    _ajustes.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
