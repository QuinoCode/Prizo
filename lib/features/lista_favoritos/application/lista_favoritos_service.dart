import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';

class ListaFavoritosService {
  void DB_annadirProducto(Producto product) {
    Database db = DatabaseOperations.instance.prizoDatabase;
    DatabaseOperations.instance.existsInProductTable(db, product).then((exists) {
      if (!exists) {
        DatabaseOperations.instance.registerIntoProductTable(db, product).then((_) {});
      }
    });
  }
  void DB_annadirProducto_ListaFavoritos(Producto product) {
    Database db = DatabaseOperations.instance.prizoDatabase;
    DatabaseOperations.instance.existsInProductTable(db, product).then((exists) {
      if (exists) {
        DatabaseOperations.instance.existsInListaFavoritosTable(db, product).then((exists2) {
          if (!exists2) {
            DatabaseOperations.instance.registerIntoListaFavoritosTable(db, product).then((_) {});
          }
        });
      } else {
        DatabaseOperations.instance.registerIntoProductTable(db, product).then((_) {
          DatabaseOperations.instance.registerIntoListaFavoritosTable(db, product).then((_) {});
        });
      }
    });
  }
  void DB_quitarProducto(Producto product) {
    Database db = DatabaseOperations.instance.prizoDatabase;
    DatabaseOperations.instance.deleteFromListaFavoritosTable(db, product);
  }
  Future<List<Producto>> DB_fetchProducts() {
    Database db = DatabaseOperations.instance.prizoDatabase;
    return DatabaseOperations.instance.fetchProductsListaFavoritos(db);
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