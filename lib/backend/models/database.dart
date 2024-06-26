import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/models/plaga.dart';

const String kDBname = "agave_release_db";

class DB {
  static const String parcelas = 'parcelas';
  static const String estudios = 'estudios';
  static const String plagas = 'plagas';
  static const String plantas = 'plantas';
  static const String muestreos = "muestreos";
  static const String incidencias = "incidencias";
  static const String ajustes = "ajustes";
  static const String logs = "logs";
}
/* 
List<Plaga> kPlagues = [
  Plaga(id: 1, nombre: "Broca del café"),
  Plaga(id: 2, nombre: "Roya del café"),
  Plaga(id: 3, nombre: "Minador de las hojas del café"),
  Plaga(id: 4, nombre: "Nematodos"),
  Plaga(id: 5, nombre: "Cercospora"),
  Plaga(id: 6, nombre: "Ácaro rojo del café"),
];

List<Agave> kAgaves = [
  Agave(id: 1, nombre: "Coffea arabica (Arábica)"),
  Agave(id: 2, nombre: "Coffea canephora (Robusta)"),
  Agave(id: 3, nombre: "Coffea liberica (Liberica)"),
  Agave(id: 4, nombre: "Coffea excelsa (Excelsa)"),
  Agave(id: 5, nombre: "Coffea racemosa (Racemosa)"),
]; */

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

List<Agave> kAgaves = [
  Agave(id: 1, nombre: "Agave tequilana (Azul)"),
  Agave(id: 2, nombre: "Agave angustifolia (Espadín)"),
  Agave(id: 3, nombre: "Agave salmiana"),
  Agave(id: 4, nombre: "Agave americana"),
  Agave(id: 5, nombre: "Agave potatorum (Tobala)"),
];

const studiesTable = """
  CREATE TABLE ${DB.estudios} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT
);
""";

const parcelsTable = """
  CREATE TABLE ${DB.parcelas} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idTipoAgave INTEGER NOT NULL,
    nombre TEXT NOT NULL,
    superficie REAL NOT NULL,
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitud REAL,                   -- Ubicación geográfica
    longitud REAL,
    estadoCultivo TEXT,             -- Estado del cultivo (activo, en barbecho, etc.)
    observaciones TEXT,             -- Notas adicionales
    fechaUltimoMuestreo TIMESTAMP,       
    rutaImagen TEXT,                 -- Ruta de la imagen de la parcela
    FOREIGN KEY (idTipoAgave) REFERENCES ${DB.plantas}(id) ON DELETE CASCADE
  );
""";

const estudiosParcelasTable = """
  CREATE TABLE estudios_parcelas (
    idEstudio INTEGER NOT NULL,
    idParcela INTEGER NOT NULL,
    PRIMARY KEY (idEstudio, idParcela),
    FOREIGN KEY (idEstudio) REFERENCES ${DB.estudios}(id) ON DELETE CASCADE,
    FOREIGN KEY (idParcela) REFERENCES ${DB.parcelas}(id) ON DELETE CASCADE
  );
""";

const muestreosTable = """
  CREATE TABLE ${DB.muestreos} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idParcela INTEGER NOT NULL,
    idEstudio INTEGER NOT NULL,
    idPlaga INTEGER NOT NULL,
    temperatura REAL,
    humedad REAL,
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idParcela) REFERENCES ${DB.parcelas}(id) ON DELETE CASCADE,
    FOREIGN KEY (idEstudio) REFERENCES ${DB.estudios}(id) ON DELETE CASCADE,
    FOREIGN KEY (idPlaga) REFERENCES ${DB.plagas}(id) ON DELETE CASCADE
  );
""";

const incidenciasTable = """
  CREATE TABLE ${DB.incidencias} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idMuestreo INTEGER NOT NULL,
    value real NOT NULL,
    y REAL,
    x REAL,
    FOREIGN KEY (idMuestreo) REFERENCES ${DB.muestreos}(id) ON DELETE CASCADE
  );
""";

const plaguesTable = """
  CREATE TABLE ${DB.plagas} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
);
""";

const plantasTable = """
  CREATE TABLE ${DB.plantas} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
);
""";

const ajustesTable = """
  CREATE TABLE ${DB.ajustes} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    muestreoId INTEGER NOT NULL,
    nombre TEXT NOT NULL,
    nLags INTEGER NOT NULL,
    sill REAL NOT NULL,
    range REAL NOT NULL,
    nugget REAL NOT NULL,
    model TEXT NOT NULL,
    semivariogramImage TEXT NOT NULL,
    contourImage TEXT,
    FOREIGN KEY (muestreoId) REFERENCES muestreos(id) ON DELETE CASCADE
);
""";

final List<String> kTables = [
  plantasTable,
  plaguesTable,
  studiesTable,
  parcelsTable,
  estudiosParcelasTable,
  muestreosTable,
  incidenciasTable,
  ajustesTable,
];
