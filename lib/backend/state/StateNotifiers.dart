import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/providers/agave_provider.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/backend/providers/plagas_provider.dart';
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
    notifyListeners();
  }

  delete(int id) async {
    await AgaveProvider.db.delete(id, DB.agaves);
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

  List<Estudio> get estudios => _estudios;

  fetchData() async {
    _estudios = await EstudiosProvider.db.getAll();
    notifyListeners();
  }

  addEstudio(Estudio estudio) async {
    await EstudiosProvider.db.insert(estudio);
    fetchData();
  }

  delete(int id) async {
    await EstudiosProvider.db.delete(id, DB.estudios);
    fetchData();
  }
}
