import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'

class DatabaseOperations {
	Database? prizoDatabase;
  
	void openOrCreateDB() async {
		 prizoDatabase = await openDatabase(
			join(await getDatabasesPath(), 'prizo_database.db'),
			onCreate: (db, version) {
				return createTablesFromScratch();
			},
			version: 1
		);
	}
	//Builds the database creating the different tables
	void createTablesFromScratch(){
		createProductTable();
		createListaCompraTables();
		createListaFavoritosTables();
	}

	void insertProducto(Producto producto){
		prizoDatabase!.insert(
			'Producto',
			producto.toMap(),
			conflictAlgorithm: ConflictAlgorithm.replace
		);
	}
	void insertListaCompra(ListaCompra listaCompra){
		//Insert the empty List in the database
		prizoDatabase!.insert(
			'Lista_Compra',
			listaCompra.toMap(),
			conflictAlgorithm: ConflictAlgorithm.replace
		);

		//Insert the products in the database
		listaCompra.productos.map((producto_cantidad) {
			insertProducto(producto_cantidad.$1);
		});

		//Insert the products into the list
		listaCompra.productos.map((producto_cantidad){
			prizoDatabase!.insert(
				'Lista_Compra_Producto',
				{
					"lista_id": listaCompra.id, 
					"producto_id": producto_cantidad.$1.id, 
					"cantidad": producto_cantidad.$2,
				},
				conflictAlgorithm: ConflictAlgorithm.replace
			);
		});

	}

	void insertListaFavoritosVacia(ListaFavoritos listaFavoritos){
		prizoDatabase!.insert(
			'Lista_Favoritos',
			listaFavoritos.toMap(),
			conflictAlgorithm: ConflictAlgorithm.replace
		);

		listaFavoritos.productos.map((productos) {
			insertProducto(productos);
		});

		listaFavoritos.productos.map((producto){
			prizoDatabase!.insert(
				'Lista_Favoritos_Producto',
				{
					"lista_id": listaFavoritos.id, 
					"producto_id": producto.id, 
				},
				conflictAlgorithm: ConflictAlgorithm.replace
			);
		});
	}

	void createProductTable(){
		prizoDatabase!.execute(
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
				precioOferta REAL, 
			)
			"""
			//Sqlite no soporta booleanos así que oferta tiene que ser un integer con valor 0 o 1
			//Alergenos es un TEXT porque SQLITE no soporta listas, hay que pasar los booleanos como csv '0,1,1'
		);
	}
	void createListaCompraTables(){
		prizoDatabase!.execute(
			"""
			CREATE TABLE Lista_Compra(
				id INTEGER, 
				usuario TEXT, 
				productos, 
			)
			"""
		);
		prizoDatabase!.execute(
		"""
		CREATE TABLE Lista_Compra_Producto (
		    lista_id INTEGER, 
		    producto_id TEXT, 
		    cantidad INTEGER,
		    PRIMARY KEY (lista_id, producto_id),
		    FOREIGN KEY (lista_id) REFERENCES Lista_Compra(id) ON DELETE CASCADE,
		    FOREIGN KEY (producto_id) REFERENCES Producto(id) ON DELETE CASCADE
		)
		"""
		);
	}
	void createListaFavoritosTables(){
		prizoDatabase!.execute(
			"""
			CREATE TABLE Lista_Favoritos(
				id INTEGER, 
				usuario TEXT, 
				productos, 
			)
			"""
		);
		prizoDatabase!.execute(
		"""
		CREATE TABLE Lista_Favoritos_Producto (
		    lista_id INTEGER, 
		    producto_id TEXT, 
		    PRIMARY KEY (lista_id, producto_id),
		    FOREIGN KEY (lista_id) REFERENCES Lista_Compra(id) ON DELETE CASCADE,
		    FOREIGN KEY (producto_id) REFERENCES Producto(id) ON DELETE CASCADE
		)
		"""
		);
	}

}

