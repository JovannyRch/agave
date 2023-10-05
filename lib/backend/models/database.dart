const String kDBname = "agave_database";

class DB {
  static const String parcels = 'parcels';
  static const String studies = 'studies';
  static const String plages = 'plages';
}

List<String> plagasList = [
  "Picudo del agave",
  "Gusano barrenador del cogollo",
  "Gusano trozador del agave",
  "Ácaro rojo del agave",
  "Pulguilla del agave",
  "Mosca del agave",
  "Falsa arañita roja del agave",
  "Chinche del agave",
  "Gusano blanco del agave",
  "Nematodo barrenador del agave",
  "Mosquita blanca del agave",
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
  CREATE TABLE ${DB.plages} (
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
    FOREIGN KEY (idPlaga) REFERENCES ${DB.plages}(id) ON DELETE CASCADE
);
""";

final List<String> kTables = [
  parcelsTable,
  plaguesTable,
  studiesTable,
  plagasList
      .asMap()
      .entries
      .map((entry) =>
          "INSERT INTO ${DB.plages} (id, nombre) VALUES (${entry.key}, '${entry.value}');")
      .join("\n"),
];
