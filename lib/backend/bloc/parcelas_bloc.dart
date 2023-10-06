import 'dart:async';

import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';

class ParcelasBloc {
  static final ParcelasBloc _singleton = ParcelasBloc._internal();

  factory ParcelasBloc() => _singleton;

  ParcelasBloc._internal() {
    getDatos();
  }

  final _dataController = StreamController<List<Parcela>>.broadcast();

  Stream<List<Parcela>> get parcelas => _dataController.stream;

  dispose() {
    _dataController.close();
  }

  getDatos() async {
    _dataController.sink.add(await ParcelasProvider.db.getAll());
  }

  deleteData(int id) async {
    await ParcelasProvider.db.delete("$id", DB.parcelas);
    getDatos();
  }

  deletaALl() async {
    await ParcelasProvider.db.deleteAll(DB.parcelas);
    getDatos();
  }

  create(Parcela data) async {
    await ParcelasProvider.db.insert(data);
    getDatos();
  }
}
