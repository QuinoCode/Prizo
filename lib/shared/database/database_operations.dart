import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../shared/data_entities/models/producto.dart';

//In order to use the database first we have to initialize it
// await DatabaseOperations.instance.openOrCreateDB(); 
//and then we can access it
// Database db = DatabaseOperations.instance.prizoDatabase; 

class DatabaseOperations {
 //This is just a singleton pattern that just allows ONE single instance of database operations to exist, it has to be a static variable
	static DatabaseOperations? _databaseOperations;

 //This is the constructor of the class, it is specified with an '_' to signify it is a private constructor that is only to be used internally within the class
	DatabaseOperations._internal();

 //This is a getter that checks whether the instance of _databaseOperations has been created and if its null (?? coalescence operator) it will assign (=) the value
 // that comes from using the constructor from within the class
	static DatabaseOperations get instance => _databaseOperations ??= DatabaseOperations._internal();

	Database? _prizoDatabase;

	Database get prizoDatabase => _prizoDatabase!;
  
	Future<void> openOrCreateDB() async {
		 _prizoDatabase = await openDatabase(
			join(await getDatabasesPath(), 'prizo_database.db'),
			onCreate: (db, version) async {
				await createTablesFromScratch(db);
			},
			version: 1
		);
	await _prizoDatabase!.execute('PRAGMA foreign_keys = ON;');
	}
	//Builds the database creating the different tables
	Future<void> createTablesFromScratch(Database db) async {
		await createProductTable(db);
		await createListaCompraTables(db);
		await createListaFavoritosTables(db);
	}

	Future<void> createProductTable(Database db) async {
		 await db.execute(
			"""
			CREATE TABLE Producto(
				id TEXT PRIMARY KEY,
				nombre INTEGER, 
				foto TEXT, 
				alergenos TEXT, 
				precio REAL, 
				precioMedida REAL, 
				tienda TEXT, 
				marca TEXT, 
				categoria TEXT, 
				oferta INTEGER, 
				precioOferta REAL 
			)
			"""
			//Sqlite no soporta booleanos así que oferta tiene que ser un integer con valor 0 o 1
			//Alergenos es un TEXT porque SQLITE no soporta listas, hay que pasar los booleanos como csv '0,1,1'
		);
	}

  Future<bool> existsInProductTable(Database db, Producto producto) async{
    // Perform the query to check if there are any rows in the table
    var result = await db.rawQuery('SELECT * FROM Producto WHERE nombre = ${producto.nombre}');
  
    if (result.isNotEmpty) {
      return true;  // Item exists
    }
    return false;
  }

  Future<void> registerIntoProductTable(Database db, Producto producto) async{
    try{
      await db.insert("Producto", producto.toMap());
    } catch (e) {
      print(e);
    }
  }

	Future<void> createListaCompraTables(Database db) async {
		await db.execute(
			"""
			CREATE TABLE Lista_Compra(
				id TEXT PRIMARY KEY, 
				usuario TEXT
			)
			"""
		);
		await db.execute(
		"""
		CREATE TABLE Lista_Compra_Producto (
		    lista_id TEXT, 
		    producto_id TEXT, 
		    cantidad INTEGER,
		    PRIMARY KEY (lista_id, producto_id),
		    FOREIGN KEY (lista_id) REFERENCES Lista_Compra(id) ON DELETE CASCADE,
		    FOREIGN KEY (producto_id) REFERENCES Producto(id) ON DELETE CASCADE
		)
		"""
		);
	}

  Future<bool> existsInListaCompraTable(Database db, Producto producto) async{
    // Perform the query to check if there are any rows in the table
    var result = await db.rawQuery('SELECT * FROM Lista_Compra_Producto WHERE nombre = ${producto.nombre}');
  
    if (result.isNotEmpty) {
      return true;  // Item exists
    }
    return false;
  }

  Future<void> registerIntoListaCompraTable(Database db, Producto producto) async{
    try{
      var result = await db.rawQuery('GET id FROM Lista_Compra');
      await db.rawInsert('INSERT INTO ListaCompraProducto(lista_id, producto_id, cantidad) VALUES(${result}, ${producto.id}, 1)');
    } catch (e) {
      print(e);
    }
  }

	Future<void> createListaFavoritosTables(Database db) async {
		await db.execute(
			"""
			CREATE TABLE Lista_Favoritos(
				id TEXT PRIMARY KEY, 
				usuario TEXT
			)
			"""
		);
		await db.execute(
		"""
		CREATE TABLE Lista_Favoritos_Producto (
		    lista_id TEXT, 
		    producto_id TEXT, 
		    PRIMARY KEY (lista_id, producto_id),
		    FOREIGN KEY (lista_id) REFERENCES Lista_Favoritos(id) ON DELETE CASCADE,
		    FOREIGN KEY (producto_id) REFERENCES Producto(id) ON DELETE CASCADE
		)
		"""
		);
	}

  Future<void> createListaRecientesTables(Database db) async {
    await db.execute(
        """
        CREATE TABLE Lista_Recientes(
            id TEXT PRIMARY KEY, 
            busqueda TEXT
        )
        """
    );
  }

  Future<void> registerReciente(Database db, String name) async {
  try {
    // First, check how many items are in the table
    var countResult = await db.query('Lista_Recientes', columns: ['id']);
    int currentCount = countResult.length;

    // If the table already has 5 items, delete the first one and shift the rest up
    if (currentCount >= 5) {
      await db.delete(
        'Lista_Recientes', 
        where: 'id = ?', 
        whereArgs: [countResult.first['id']],
      );
    }

    await db.insert(
      'Lista_Recientes',
      {
        'id': DateTime.now().toString(), // Generate a unique id (can be replaced with other logic)
        'name': name,
      },
    );
  } catch (e) {
    print('Error registering name: $e');
  }
}

  Future<List<Map<String, Object?>>> fetchItemsListaRecientes(Database db) async{
    var result = await db.rawQuery('GET busqueda FROM Lista_Recientes');
    return result;
  }
}

