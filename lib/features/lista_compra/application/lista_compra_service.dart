import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';

class ListaCompraService {
  void DB_annadirProducto(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    // Verifica si el producto ya existe en la tabla de productos
    bool exists = await dbOps.existsInProductTable(db, producto);
    String nombre = producto.nombre;
    if (exists) {
      // Verifica si el producto ya está en la lista de compra
      bool existsInListaCompra = await dbOps.existsInListaCompraTable(db, producto);
      if (!existsInListaCompra) {
        await dbOps.registerIntoListaCompraTable(db, producto);
        print("$nombre - añadido a Lista de Compra");
      } else {
        DB_increaseCantidad(producto);
        print("$nombre - ya existía en Lista de Compra");
      }
    } else {
      // Registra el producto en la tabla de productos y luego en la lista de compra
      await dbOps.registerIntoProductTable(db, producto);
      await dbOps.registerIntoListaCompraTable(db, producto);
      print("$nombre - añadido por primera vez a Productos");
      print("$nombre - añadido a Lista de Compra");
    }
  }
  void DB_quitarProducto(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    await dbOps.deleteFromListaCompraTable(db, producto);
  }
  void DB_increaseCantidad(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    await dbOps.increaseCantidadListaCompra(db, producto);
  }
  void DB_decreaseCantidad(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    await dbOps.decreaseCantidadListaCompra(db, producto);
  }
  Future<int> DB_fetchCantidad(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    return await dbOps.fetchCantidadListaCompra(db, producto);
  }
  void DB_setCantidad(Producto producto, int nuevaCantidad) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    await dbOps.setCantidadListaCompra(db, producto, nuevaCantidad);
  }
  Future<List<Producto>> DB_fetchProducts() async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    return await dbOps.fetchProductsListaCompra(db);
  }
  Future<List<String>> DB_generarNombres() async {
    // Llamar a DB_fetchProducts para obtener la lista de productos
    List<Producto> BD_productos = await DB_fetchProducts();

    // Generar lista de nombres
    List<String> BD_nombres = [];

    for (Producto producto in BD_productos) {
      BD_nombres.add(producto.nombre);
    }

    return BD_nombres;
  }
  Future<List<String>> DB_generarNombres_JR() async {
    // Llamar a DB_fetchProducts para obtener la lista de productos
    List<Producto> BD_productos = await DB_fetchProducts();

    // Generar lista de nombres
    List<String> BD_nombres = [];

    for (Producto producto in BD_productos) {
      BD_nombres.add(producto.nombre);
    }

    List<String> resultado = [];
    for(String nombre in BD_nombres) {
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
  Future<ListaCompra> generar_ListaCompra() async {
    // Llamar a DB_fetchProducts para obtener la lista de productos
    List<Producto> BD_productos = await DB_fetchProducts();

    // Generar tuplas de producto-cantidad
    List<(Producto, int)> BD_tuplas = [];

    for (Producto producto in BD_productos) {
      // Llamar a DB_fetchCantidad para cada producto
      int cantidad = await DB_fetchCantidad(producto);
      BD_tuplas.add((producto, cantidad));
    }

    // Crear y devolver la lista de compra
    ListaCompra listaCompra = ListaCompra(
      id: '1',
      usuario: 'usuario_demo',
      productos: BD_tuplas,
    );

    return listaCompra;
  }
  Future<void> DB_Tick_annadir(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    // Verifica si el producto ya existe en la tabla de productos tick
    bool exists = await dbOps.existsInProductTickTable(db, producto);
    if (!exists) {
      // Registra el producto en la tabla de productos tick
      await dbOps.registerIntoProductTickTable(db, producto);
    }
  }
  Future<void> DB_Tick_quitar(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();
    Database db = dbOps.prizoDatabase;

    // Verifica si el producto ya existe en la tabla de productos tick
    bool exists = await dbOps.existsInProductTickTable(db, producto);
    if (exists) {
      // Borra el producto en la tabla de productos tick
      await dbOps.deleteFromProductTickTable(db, producto);
    }
  }
  Future<bool> DB_Tick_tiene_tick(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    return dbOps.existsInProductTickTable(db, producto);
  }

  final int LIMITE = 99;
  final ProductoService productoService = new ProductoService();

  void annadirProducto(ListaCompra list, Producto product) {
    /* lista vacía */
    if (list.productos.isEmpty) {
      list.productos.add((product, 1));
      return; /* fin ejecución */
    }

    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setCantidadProductoAux(index, list, product, list.productos[index].$2 + 1);
      return; /* fin ejecución */
    }

    /* El producto no existía en la lista */
    list.productos.add((product, 1));
  }

  void quitarProducto(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      list.productos.remove((list.productos[index].$1, list.productos[index].$2));
    }
  }

  /** El Producto product debe existir en la lista para invocar este método */
  void annadirInstancia(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setCantidadProductoAux(index, list, product, list.productos[index].$2 + 1);
    }
  }

  void quitarInstancia(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setCantidadProductoAux(index, list, product, list.productos[index].$2 - 1);
    }
  }

  /** Devuelve 0 si no existe el product */
  int getCantidadProducto(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      return list.productos[index].$2;
    }
    return 0;
  }

  /** El Producto product debe existir en la lista para invocar este método y quantity mayor a 0 */
  void setCantidadProducto(ListaCompra list, Producto product, int quantity) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setCantidadProductoAux(index, list, list.productos[index].$1, quantity);
    }
  }

  /** index debe ser distinto de -1 */
  void setCantidadProductoAux(int index, ListaCompra list, Producto product, int quantity) {
    int newQuantity = list.productos[index].$2;
    if(quantity > 0) {
      if(quantity > LIMITE) {
        newQuantity = LIMITE;
      } else {
        newQuantity = quantity;
      }
    }
    list.productos[index] = (product /* se mete para obtener oferta actualizada */, newQuantity);
  }

  /** Si el producto no existe, devuelve 0.0 */
  double getPrecio(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if (index != -1) {
      return productoService.getPrecio(list.productos[index].$1) * list.productos[index].$2;
    }

    return 0.0;
  }

  /** Si no hay productos en la lista, devuelve 0.0 */
  double getPrecioTotal(ListaCompra list) {
    double totalPrice = 0.0;
    for (var producto in list.productos) {
      totalPrice += productoService.getPrecio(producto.$1) * producto.$2;
    }
    return totalPrice;
  }

  int buscarProducto(ListaCompra list, Producto product) {
    /* Si el producto existe, devuelve el índice*/
    for (int index = 0; index < list.productos.length; index++) {
      if (productoService.mismoProducto(list.productos[index].$1, product)) {
        return index; /* fin ejecución */
      }
    }
    return -1;
  }
}
