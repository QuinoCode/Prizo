import 'package:flutter/material.dart';
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

  Future<void> ensureDatabaseInitialized() async {
    if (_prizoDatabase == null) {
      await openOrCreateDB();
    }
  }

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

  Future<void> deleteDB() async {
    try {
      // Get the database path
      String dbPath = join(await getDatabasesPath(), 'prizo_database.db');

      // Delete the database
      await deleteDatabase(dbPath);

      print("Database deleted successfully.");
    } catch (e) {
      print("Error deleting database: $e");
    }
  }

  //Builds the database creating the different tables
  Future<void> createTablesFromScratch(Database db) async {
    await createProductTable(db);
    await createProductTickTable(db);
    await createListaCompraTables(db);
    await createListaFavoritosTables(db);
    await createListaRecientesTables(db);
    await insertListaCompra(db);
    await insertListaFavoritos(db);
  }

  Future<void> createFiltroTable(Database db) async {
    await db.execute(
        """
			CREATE TABLE Filtro(
				id INTEGER PRIMARY KEY,
				sinLactosa INTEGER,
				sinGluten INTEGER,
				sinFrutosSecos INTEGER
			)
			"""
      //Sqlite no soporta booleanos así que oferta tiene que ser un integer con valor 0 o 1
      //Alergenos es un TEXT porque SQLITE no soporta listas, hay que pasar los booleanos como csv '0,1,1'
    );
  }
  Future<void> createProductTable(Database db) async {
    await db.execute(
        """
			CREATE TABLE Producto(
				id TEXT PRIMARY KEY,
				nombre TEXT, 
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
  Future<void> createProductTickTable(Database db) async {
    await db.execute(
        """
			CREATE TABLE ProductoTick(
				id TEXT PRIMARY KEY,
				nombre TEXT, 
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
  Future<void> createListaCompraActual(Database db) async {
    await db.execute(
        """
			CREATE TABLE Lista_Compra_Actual(
				id TEXT PRIMARY KEY
			)
			"""
      //Sqlite no soporta booleanos así que oferta tiene que ser un integer con valor 0 o 1
      //Alergenos es un TEXT porque SQLITE no soporta listas, hay que pasar los booleanos como csv '0,1,1'
    );
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
  Future<void> createListaFavoritosActual(Database db) async {
    await db.execute(
        """
			CREATE TABLE Lista_Favoritos_Actual(
				id TEXT PRIMARY KEY
			)
			"""
      //Sqlite no soporta booleanos así que oferta tiene que ser un integer con valor 0 o 1
      //Alergenos es un TEXT porque SQLITE no soporta listas, hay que pasar los booleanos como csv '0,1,1'
    );
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

  Future<void> insertListaCompra(Database db,) async{
    try{
      await db.rawInsert('INSERT INTO Lista_compra(id, usuario) VALUES("lista1","Juan")');
    } catch (e) {
      print(e);
    }
  }
  Future<void> insertListaFavoritos(Database db,) async{
    try{
      await db.rawInsert('INSERT INTO Lista_Favoritos(id, usuario) VALUES("lista2","Juan")');
    } catch (e) {
      print(e);
    }
  }

  Future<List<Producto>> fetchProductsListaCompra(Database db) async{
    List<Producto> result = [];
    var listaQuery = await db.rawQuery('SELECT id FROM Lista_Compra LIMIT 1');
    if (listaQuery.isNotEmpty) {
      var listaId = listaQuery.first['id'];
      var listaProducts = await db.rawQuery('SELECT producto_id from Lista_Compra_Producto WHERE lista_id = ?',[listaId]);
      for (int i = 0; i < listaProducts.length; i++){
        var product = await db.rawQuery('SELECT * FROM Producto WHERE id = ?', [listaProducts[i]['producto_id']]);
        var toAdd = product.first;
        result.add(
            new Producto(
                id: toAdd['id'].toString(),
                nombre: toAdd['nombre'] as String,
                alergenos:(toAdd['alergenos'] != null)
                    ? (toAdd['alergenos'] as String)
                    .split(',')
                    .map((e) => e.toLowerCase() == 'true')
                    .toList()
                    : [],
                categoria: toAdd['categoria'] as String,
                marca: toAdd['marca'] as String,
                oferta: (toAdd['oferta'] as int) == 1,
                precio: toAdd['precio'] as double,
                precioMedida: toAdd['precioMedida'] as double,
                precioOferta: toAdd['precioOferta'] as double,
                tienda: toAdd['tienda'] as String,
                foto: toAdd['foto'] as String
            )
        );
      }
    }
    return result;
  }
  Future<List<Producto>> fetchProductsListaFavoritos(Database db) async{
    List<Producto> result = [];
    var listaQuery = await db.rawQuery('SELECT id FROM Lista_Favoritos LIMIT 1');
    if (listaQuery.isNotEmpty) {
      var listaId = listaQuery.first['id'];
      var listaProducts = await db.rawQuery('SELECT producto_id from Lista_Favoritos_Producto WHERE lista_id = ?',[listaId]);
      for (int i = 0; i < listaProducts.length; i++){
        var product = await db.rawQuery('SELECT * FROM Producto WHERE id = ?', [listaProducts[i]['producto_id']]);
        var toAdd = product.first;
        result.add(
            new Producto(
                id: toAdd['id'].toString(),
                nombre: toAdd['nombre'] as String,
                alergenos:(toAdd['alergenos'] != null)
                    ? (toAdd['alergenos'] as String)
                    .split(',')
                    .map((e) => e.toLowerCase() == 'true')
                    .toList()
                    : [],
                categoria: toAdd['categoria'] as String,
                marca: toAdd['marca'] as String,
                oferta: (toAdd['oferta'] as int) == 1,
                precio: toAdd['precio'] as double,
                precioMedida: toAdd['precioMedida'] as double,
                precioOferta: toAdd['precioOferta'] as double,
                tienda: toAdd['tienda'] as String,
                foto: toAdd['foto'] as String
            )
        );
      }
    }
    return result;
  }
  Future<List<Map<String, Object?>>> fetchItemsListaRecientes(Database db) async{
    var result = await db.rawQuery('SELECT busqueda FROM Lista_Recientes ORDER BY id DESC');
    return result;
  }

  Future<bool> existsInProductTable(Database db, Producto producto) async{
    // Perform the query to check if there are any rows in the table
    var result = await db.rawQuery('SELECT * FROM Producto WHERE nombre = ?', [producto.nombre]);

    if (result.isNotEmpty) {
      return true;  // Item exists
    }
    return false;
  }
  Future<bool> existsInProductTickTable(Database db, Producto producto) async{
    // Perform the query to check if there are any rows in the table
    var result = await db.rawQuery('SELECT * FROM ProductoTick WHERE nombre = ?', [producto.nombre]);

    if (result.isNotEmpty) {
      return true;  // Item exists
    }
    return false;
  }
  Future<bool> existsInListaCompraTable(Database db, Producto producto) async{
    // Perform the query to check if there are any rows in the table
    try {
      var result = await db.rawQuery('SELECT * FROM Lista_Compra_Producto WHERE producto_id = ?', [producto.id]);
      if (result.isNotEmpty) {
        return true;  // Item exists
      }
    } on Exception catch (e) {
      print (e);
    }
    return false;
  }
  Future<bool> existsInListaFavoritosTable(Database db, Producto producto) async{
    // Perform the query to check if there are any rows in the table
    try {
      var result = await db.rawQuery('SELECT * FROM Lista_Favoritos_Producto WHERE producto_id = ?', [producto.id]);
      if (result.isNotEmpty) {
        return true;  // Item exists
      }
    } on Exception catch (e) {
      print (e);
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
  Future<void> registerIntoProductTickTable(Database db, Producto producto) async{
    try{
      await db.insert("ProductoTick", producto.toMap());
    } catch (e) {
      print(e);
    }
  }
  Future<void> registerIntoListaCompraTable(Database db, Producto producto) async{
    try{
      // Query to get the id from Lista_Compra
      var result = await db.rawQuery('SELECT id FROM Lista_Compra LIMIT 1'); // Added LIMIT to fetch only one result

      // Check if the result is not empty
      if (result.isNotEmpty) {
        // Extract the id value
        var listaId = result.first['id']; // Get the 'id' from the first result

        // Insert into Lista_Compra_Producto table using parameterized query
        await db.rawInsert(
            'INSERT INTO Lista_Compra_Producto(lista_id, producto_id, cantidad) VALUES(?, ?, ?)',
            [listaId, producto.id, 1]  // Properly passing parameters
        );
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> registerIntoListaFavoritosTable(Database db, Producto producto) async{
    try{
      // Query to get the id from Lista_Compra
      var result = await db.rawQuery('SELECT id FROM Lista_Favoritos LIMIT 1'); // Added LIMIT to fetch only one result

      // Check if the result is not empty
      if (result.isNotEmpty) {
        // Extract the id value
        var listaId = result.first['id']; // Get the 'id' from the first result

        // Insert into Lista_Favoritos_Producto table using parameterized query
        await db.rawInsert(
            'INSERT INTO Lista_Favoritos_Producto(lista_id, producto_id) VALUES(?, ?)',
            [listaId, producto.id]  // Properly passing parameters
        );
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> registerReciente(Database db, String bus) async {
    try {
      // First, check how many items are in the table
      var countResult = await db.rawQuery('SELECT id FROM Lista_Recientes');
      int currentCount = countResult.length;

      var existingResult = await db.rawQuery(
        'SELECT id FROM Lista_Recientes WHERE LOWER(busqueda) = ?',
        [bus.toLowerCase()]);

      if (existingResult.isNotEmpty) {
        await updateReciente(db, bus);
        return;
      }

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
          'busqueda': bus,
        },
      );
    } catch (e) {
      print('Error registering name: $e');
    }
  }

  Future<void> updateReciente(Database db, String bus) async {
  try {
    await db.rawUpdate(
      'UPDATE Lista_Recientes SET id = ? WHERE busqueda = ?',
      [DateTime.now().toString(), bus],
    );
  } catch (e) {
    print('Error updating recent item: $e');
  }
}

  Future<void> deleteFromProductTickTable(Database db, Producto producto) async{
    try{
      // Usar parámetros en lugar de concatenación directa
      await db.rawDelete(
        'DELETE FROM ProductoTick WHERE id = ?',
        [producto.id], // Pasas el parámetro aquí como una lista
      );
    } catch (e) {
      print(e);
    }
  }
  Future<void> deleteFromListaCompraTable(Database db, Producto producto) async{
    try{
      // Usar parámetros en lugar de concatenación directa
      await db.rawDelete(
        'DELETE FROM Lista_Compra_Producto WHERE producto_id = ?',
        [producto.id], // Pasas el parámetro aquí como una lista
      );
    } catch (e) {
      print(e);
    }
  }
  Future<void> deleteFromListaFavoritosTable(Database db, Producto producto) async{
    try{
      // Usar parámetros en lugar de concatenación directa
      await db.rawDelete(
        'DELETE FROM Lista_Favoritos_Producto WHERE producto_id = ?',
        [producto.id], // Pasas el parámetro aquí como una lista
      );
    } catch (e) {
      print(e);
    }
  }

  Future<int> fetchCantidadListaCompra(Database db, Producto producto) async {
    try {
      var exists = await existsInListaCompraTable(db, producto);
      if (!exists) {
        await registerIntoListaCompraTable(db, producto);
      } else {
        var result = await db.rawQuery(
          '''
          SELECT cantidad 
          FROM Lista_Compra_Producto 
          WHERE producto_id = ?
          ''',
          [producto.id]
        );
        return result.first['cantidad'] as int;
      }
    } catch (e) {
      print('Error increasing cantidad: $e');
    }
    return 0;
  }
  Future<void> increaseCantidadListaCompra(Database db, Producto producto) async {
    try {
      var exists = await existsInListaCompraTable(db, producto);
      if (!exists) {
        await registerIntoListaCompraTable(db, producto);
      } else {
        //si es necesario, añadir un AND con lista activa
        await db.rawUpdate(
            '''
          UPDATE Lista_Compra_Producto 
          SET cantidad = cantidad + 1 
          WHERE producto_id = ?
          ''',
            [producto.id]
        );
      }
    } catch (e) {
      print('Error increasing cantidad: $e');
    }
  }
  Future<void> decreaseCantidadListaCompra(Database db, Producto producto) async {
    try {
      int count = await fetchCantidadListaCompra(db, producto);
      if (count > 0) {
        await db.rawUpdate(
            '''
          UPDATE Lista_Compra_Producto 
          SET cantidad = cantidad - 1 
          WHERE producto_id = ?
          ''',
            [producto.id]
        );
      } else if (count == 0) {
        deleteFromListaCompraTable(db, producto);
      }
    } catch (e) {
      print('Error decreasing cantidad: $e');
    }
  }
  Future<void> setCantidadListaCompra(Database db, Producto producto, int nuevaCantidad) async {
    try {
      if (nuevaCantidad > 0) {
        // Si la cantidad es mayor a 0, actualiza la cantidad del producto
        await db.rawUpdate(
          '''
        UPDATE Lista_Compra_Producto 
        SET cantidad = ? 
        WHERE producto_id = ?
        ''',
          [nuevaCantidad, producto.id],
        );
      } else {
        // Si la cantidad es 0 o menos, elimina el producto de la lista de compra
        await deleteFromListaCompraTable(db, producto);
      }
    } catch (e) {
      print('Error al actualizar la cantidad: $e');
    }
  }
}