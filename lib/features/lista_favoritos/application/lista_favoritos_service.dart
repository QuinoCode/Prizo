import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';

class ListaFavoritosService {
  void DB_annadirProducto(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    // Verifica si el producto ya existe en la tabla de productos
    bool exists = await dbOps.existsInProductTable(db, producto);
    String nombre = producto.nombre;
    if (exists) {
      // Verifica si el producto ya está en la lista de compra
      bool existsInListaFavoritos = await dbOps.existsInListaFavoritosTable(db, producto);
      if (!existsInListaFavoritos) {
        await dbOps.registerIntoListaFavoritosTable(db, producto);
        print("$nombre - añadido a Lista de Favoritos");
      } else {
        print("$nombre - ya existía en Lista de Favoritos");
      }
    } else {
      // Registra el producto en la tabla de productos y luego en la lista de compra
      await dbOps.registerIntoProductTable(db, producto);
      await dbOps.registerIntoListaFavoritosTable(db, producto);
      print("$nombre - añadido por primera vez a Productos");
      print("$nombre - añadido a Lista de Favoritos");
    }
  }
  void DB_quitarProducto(Producto producto)  async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    await dbOps.deleteFromListaFavoritosTable(db, producto);
  }
  Future<List<Producto>> DB_fetchProducts() async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    return await dbOps.fetchProductsListaFavoritos(db);
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
  Future<ListaFavoritos> generar_ListaFavoritos() async {
    // Llamar a DB_fetchProducts para obtener la lista de productos
    List<Producto> BD_productos = await DB_fetchProducts();

    // Crear y devolver la lista de favoritos
    ListaFavoritos listaFavoritos = ListaFavoritos(
        id: '1', usuario: 'usuario_demo', productos: BD_productos);

    return listaFavoritos;
  }

  // Método para verificar si un producto está en favoritos
  Future<bool> isProductoEnFavoritos(Producto producto) async {
    DatabaseOperations dbOps = DatabaseOperations.instance;

    await dbOps.ensureDatabaseInitialized();

    Database db = dbOps.prizoDatabase;

    // Verificamos si el producto está en la tabla de favoritos
    return await dbOps.existsInListaFavoritosTable(db, producto);
  }

  final ProductoService productoService = new ProductoService();

  void quitarProducto(ListaFavoritos list, Producto product) {
    list.productos.remove(product);
  }

  void annadirProducto(ListaFavoritos list, Producto product) {
    int index = list.productos.indexWhere((p) => productoService.mismoProducto(p, product));

    if (index != -1) {
      /* Se mete para obtener oferta actualizada */
      list.productos[index] = product ;
    } else {
      /* Si no existe, se agrega el nuevo producto */
      list.productos.add(product);
    }
  }

  bool productoEnFavoritos(ListaFavoritos list, Producto product) {
    return list.productos.indexWhere((p) => productoService.mismoProducto(p, product)) != -1;
  }
}