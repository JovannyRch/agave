const String kDBname = "agave_database";

class DB {
  static const String parcels = 'parcels';
}

List<String> plages = [
  'Plague 1',
];

const parcelsTable = """
  CREATE TABLE ${DB.parcels} (
    idParcela INTEGER PRIMARY KEY AUTOINCREMENT,
    nombreParcela TEXT NOT NULL,
    superficie REAL NOT NULL,
    fechaCreacion TEXT NOT NULL,
    latitud REAL,                   -- Ubicación geográfica
    longitud REAL,
    tipoAgave TEXT,                 -- Tipo de Agave
    estadoCultivo TEXT,             -- Estado del cultivo (activo, en barbecho, etc.)
    observaciones TEXT,             -- Notas adicionales
    fechaUltimoMuestreo TEXT,       -- Fecha de último muestreo
    rutaImagen TEXT                 -- Ruta de la imagen de la parcela
  );
""";

final List<String> kTables = [
  parcelsTable,
];
