import 'package:agave/backend/models/plaga.dart';

const String kDBname = "agave_database";

class DB {
  static const String parcels = 'parcels';
  static const String studies = 'studies';
  static const String plagues = 'plagues';
}

List<Plaga> kPlagues = [
  Plaga(id: 1, nombre: "Picudo del agave"),
  Plaga(id: 2, nombre: "Gusano barrenador del cogollo"),
  Plaga(id: 3, nombre: "Gusano trozador del agave"),
  Plaga(id: 4, nombre: "Ácaro rojo del agave"),
  Plaga(id: 5, nombre: "Pulguilla del agave"),
  Plaga(id: 6, nombre: "Mosca del agave"),
  Plaga(id: 7, nombre: "Falsa arañita roja del agave"),
  Plaga(id: 8, nombre: "Chinche del agave"),
  Plaga(id: 9, nombre: "Gusano blanco del agave"),
  Plaga(id: 10, nombre: "Nematodo barrenador del agave"),
  Plaga(id: 11, nombre: "Mosquita blanca del agave"),
];

const parcelsTable = """
  CREATE TABLE ${DB.parcels} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombreParcela TEXT NOT NULL,
    superficie REAL NOT NULL,
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitud REAL,                   -- Ubicación geográfica
    longitud REAL,
    tipoAgave TEXT,                 -- Tipo de Agave
    estadoCultivo TEXT,             -- Estado del cultivo (activo, en barbecho, etc.)
    observaciones TEXT,             -- Notas adicionales
    fechaUltimoMuestreo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- Fecha de último muestreo
    rutaImagen TEXT                 -- Ruta de la imagen de la parcela
  );
""";

const plaguesTable = """
  CREATE TABLE ${DB.plagues} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
);
""";

const studiesTable = """
  CREATE TABLE ${DB.studies} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idParcela INTEGER,
    idPlaga INTEGER,
    humedad REAL,
    temperatura REAL,
    fechaEstudio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT,
    FOREIGN KEY (idParcela) REFERENCES ${DB.parcels}(id) ON DELETE CASCADE,
    FOREIGN KEY (idPlaga) REFERENCES ${DB.plagues}(id) ON DELETE CASCADE
);
""";

final List<String> kTables = [
  parcelsTable,
  plaguesTable,
  studiesTable,
];
