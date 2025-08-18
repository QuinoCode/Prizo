import 'package:prizo/shared/data_entities/models/pantry_list.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';

class PantryLogic {

  final Database db;
  final DatabaseOperations dbOps;
  static PantryLogic? _instance;
  // Private constructor
  PantryLogic._({
    required this.db,
    required this.dbOps,
  });

  static Future<PantryLogic> instance() async {
    if (_instance != null) return _instance!;
    _instance = await PantryLogic.init();
    return _instance!;
  }

  static Future<PantryLogic> init() async {
    final dbOps = DatabaseOperations.instance;
    await dbOps.ensureDatabaseInitialized();
    final db = dbOps.prizoDatabase;
    return PantryLogic._(db: db, dbOps: dbOps);
  }
	
  Future<void> dbAddProduct(Producto producto, [int amount = 1]) async {
    bool exists = await dbOps.existsInProductTable(db, producto);
    String nombre = producto.nombre;
    if (exists) {
      // Verifica si el producto ya está en la lista de compra
      bool existsInPantryList = await dbOps.existsInPantryListTable(db, producto);
      if (!existsInPantryList) {
        await dbOps.insertIntoPantryListTable(db, producto);
        await dbIncreaseProductAmountInPantry(producto, amount-1);
        print("$nombre - added to the pantry");
      } else {
        await dbIncreaseProductAmountInPantry(producto, amount);
        print("$nombre - already existed in the pantry");
      }
    } else {
      // Registra el producto en la tabla de productos y luego en la lista de compra
      await dbOps.registerIntoProductTable(db, producto);
      await dbOps.insertIntoPantryListTable(db, producto);
      print("$nombre - added for the first time to the product list");
      print("$nombre - added to the pantry list");
    }
  }

  Future<void> dbRemoveProductFromPantry(Producto producto) async {
    await dbOps.deleteFromPantryListTable(db, producto);
  }

  Future<void> dbIncreaseProductAmountInPantry(Producto producto, amount) async {
    await dbOps.increasePantryList(db, producto, amount);
  }

  Future<void> dbDecreaseProductAmountInPantry(Producto producto) async {
    await dbOps.decreasePantryList(db, producto);
  }

  Future<int> dbFetchAmountProductInPantry(Producto producto) async {
    return await dbOps.fetchAmountPantryList(db, producto);
  }

  Future<void> dbSetAmountOfProductInPantry(Producto product, int newAmount) async {

    await dbOps.setAmountPantryList(db, product, newAmount);
  }

  Future<List<Producto>> dbFetchProductsInPantry() async {

    return await dbOps.fetchProductsFromPantryList(db);
  }
	 
  Future<List<String>> dbFetchProductsNameFromPantry() async {
    // Llamar a DB_fetchProducts para obtener la lista de productos
    List<Producto> products = await dbFetchProductsInPantry();

    // Generar lista de nombres
    List<String> names = [];

    for (Producto producto in products) {
      names.add(producto.nombre);
    }

    List<String> resultado = [];
    for(String nombre in names) {
      if(nombre.length <= 13) {
        resultado.add(nombre + "\n" + " ");
      } else {
        String aux_1 = nombre.substring(0, 13);
        String aux_2 = (nombre.length > 18) ? nombre.substring(13, 18) : nombre.substring(13);
        resultado.add(aux_1 + "\n" + aux_2.trim() + "...");
      }
    }

    return resultado;
  }

  Future<PantryList> generatePantryList() async {
    List<Producto> BD_productos = await dbFetchProductsInPantry();

    List<(Producto, int)> BD_tuplas = [];

    for (Producto producto in BD_productos) {
      int cantidad = await dbFetchAmountProductInPantry(producto);
      BD_tuplas.add((producto, cantidad));
    }

    PantryList listaCompra = PantryList(
      id: '1',
      user: 'usuario_demo',
      products: BD_tuplas,
    );
    return listaCompra;
  }

  Future<void> dbAddTick(Producto product) async {
    bool exists = await dbOps.existsInPantryListTable(db, product);
    if (!exists) {
      print("going here");
      await dbOps.insertIntoPantryListTable(db, product);
    }
    await dbOps.insertIntoPantryListTickTable(db, product);
  }

  Future<void> dbTickRemove(Producto producto) async {

    bool exists = await dbOps.existsInShoppingListTickTable(db, producto);
    if (exists) {
      await dbOps.deleteFromPantryListTickTable(db, producto);
    }
  }

  Future<bool> dbHasTickPantry(Producto producto) async {

    return dbOps.existsInPantryListTickTable(db, producto);
  }

  final int LIMITE = 99;
  final ProductoService productService = ProductoService();

  void addProduct(PantryList list, Producto product) {
    /* lista vacía */
    if (list.products.isEmpty) {
      list.products.add((product, 1));
      return; /* fin ejecución */
    }

    /* Buscar producto en la lista existente */
    int index = searchProduct(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setProductAmountAux(index, list, product, list.products[index].$2 + 1);
      return; /* fin ejecución */
    }

    /* El producto no existía en la lista */
    list.products.add((product, 1));
  }

  void removeProduct(PantryList list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = searchProduct(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      list.products.remove((list.products[index].$1, list.products[index].$2));
    }
  }

  /** El Producto product debe existir en la lista para invocar este método */
  void addInstance(PantryList list, Producto product) {
    int index = searchProduct(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setProductAmountAux(index, list, product, list.products[index].$2 + 1);
    }
  }

  void removeInstance(PantryList list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = searchProduct(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setProductAmountAux(index, list, product, list.products[index].$2 - 1);
    }
  }

  /** Devuelve 0 si no existe el product */
  int getProductAmount(PantryList list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = searchProduct(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      return list.products[index].$2;
    }
    return 0;
  }

  /** El Producto product debe existir en la lista para invocar este método y quantity mayor a 0 */
  void setProductAmount(PantryList list, Producto product, int quantity) {
    /* Buscar producto en la lista existente */
    int index = searchProduct(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setProductAmountAux(index, list, list.products[index].$1, quantity);
    }
  }

  /** index debe ser distinto de -1 */
  void setProductAmountAux(int index, PantryList list, Producto product, int amount) {
    int newAmount = list.products[index].$2;
    if(amount > 0) {
      if(amount > LIMITE) {
        newAmount = LIMITE;
      } else {
        newAmount = amount;
      }
    }
    list.products[index] = (product /* se mete para obtener oferta actualizada */, newAmount);
  }

  /** Si el producto no existe, devuelve 0.0 */
  double getPrice(PantryList list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = searchProduct(list, product);

    /* El producto existe en la lista */
    if (index != -1) {
      return productService.getPrecio(list.products[index].$1) * list.products[index].$2;
    }

    return 0.0;
  }

  /** Si no hay productos en la lista, devuelve 0.0 */
  double getTotalPrice(PantryList list) {
    double totalPrice = 0.0;
    for (var producto in list.products) {
      totalPrice += productService.getPrecio(producto.$1) * producto.$2;
    }
    return totalPrice;
  }

  int searchProduct(PantryList list, Producto product) {
    for (int index = 0; index < list.products.length; index++) {
      if (productService.mismoProducto(list.products[index].$1, product)) {
        return index;
      }
    }
    return -1;
  }
}

