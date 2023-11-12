import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/models/plaga.dart';

const String kDBname = "agave_2_database";

class DB {
  static const String parcelas = 'parcelas';
  static const String estudios = 'estudios';
  static const String plagas = 'plagas';
  static const String agaves = 'agaves';
  static const String muestreos = "muestreos";
  static const String incidencias = "incidencias";
  static const String logs = "logs";
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
    FOREIGN KEY (idTipoAgave) REFERENCES ${DB.agaves}(id) ON DELETE CASCADE
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
    cantidad INTEGER NOT NULL,
    latitud REAL,                   
    longitud REAL,
    norte REAL,
    este REAL,
    zona TEXT,
    FOREIGN KEY (idMuestreo) REFERENCES ${DB.muestreos}(id) ON DELETE CASCADE
  );
""";

const plaguesTable = """
  CREATE TABLE ${DB.plagas} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
);
""";

const agavesTable = """
  CREATE TABLE ${DB.agaves} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
);
""";

final List<String> kTables = [
  agavesTable,
  plaguesTable,
  studiesTable,
  parcelsTable,
  estudiosParcelasTable,
  muestreosTable,
  incidenciasTable,
];
