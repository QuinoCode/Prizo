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
        print("$nombre - añadido de nuevo");
      } else {
        print("$nombre - ya existía");
      }
    } else {
      // Registra el producto en la tabla de productos y luego en la lista de compra
      await dbOps.registerIntoProductTable(db, producto);
      await dbOps.registerIntoListaFavoritosTable(db, producto);
      print("$nombre - añadido por primera vez");
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
      // Verificar si la longitud del nombre es suficiente para los índices usados
      if (producto.nombre.length >= 17 && producto.nombre[16] == ' ') {
        // Tomar los primeros 16 caracteres y validar el rango
        String auxiliar = producto.nombre.substring(0, 16);
        if (producto.nombre.length > 16) {
          auxiliar += producto.nombre.substring(16, producto.nombre.length.clamp(16, 17)) + "...";
        }
        BD_nombres.add(auxiliar);
      } else {
        // Validar rango para nombres cortos
        String auxiliar = producto.nombre.substring(0, producto.nombre.length.clamp(0, 8));
        if (producto.nombre.length > 8) {
          auxiliar += producto.nombre.substring(8, producto.nombre.length.clamp(8, 17)) + "...";
        }
        BD_nombres.add(auxiliar);
      }
    }

    return BD_nombres;
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