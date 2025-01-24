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
    if (exists) {
      // Verifica si el producto ya está en la lista de compra
      bool existsInListaFavoritos = await dbOps.existsInListaFavoritosTable(db, producto);
      if (!existsInListaFavoritos) {
        await dbOps.registerIntoListaFavoritosTable(db, producto);
      } else {
        print("hell yea");
      }
    } else {
      // Registra el producto en la tabla de productos y luego en la lista de compra
      await dbOps.registerIntoProductTable(db, producto);
      await dbOps.registerIntoListaFavoritosTable(db, producto);
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
  Future<ListaFavoritos> generar_ListaFavoritos() async {
    // Llamar a DB_fetchProducts para obtener la lista de productos
    List<Producto> BD_productos = await DB_fetchProducts();

    // Crear y devolver la lista de favoritos
    ListaFavoritos listaFavoritos = ListaFavoritos(
        id: '1', usuario: 'usuario_demo', productos: BD_productos);

    return listaFavoritos;
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