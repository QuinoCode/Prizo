import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/DAO/producto_DAO.dart';
import 'package:sqflite/sqflite.dart';

class ListaCompraDAO {
  final Database _database;
  late ProductoDAO productoDAO;

  ListaCompraDAO(this._database){
     productoDAO = ProductoDAO(_database);
  }



  Future<void> insertListaCompra(ListaCompra listaCompra) async {
          //Insert the empty List in the database
          await _database.insert(
                  'Lista_Compra',
                  listaCompra.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace
          );

          //Insert the products in the database just in case they're not present yet
          for (var producto_cantidad in listaCompra.productos){
                  await productoDAO.insertProducto(producto_cantidad.$1);
          }
          //Insert the products into the list
          for (var producto_cantidad in listaCompra.productos){
                  await _database.insert(
                          'Lista_Compra_Producto',
                          {
                                  "lista_id": listaCompra.id, 
                                  "producto_id": producto_cantidad.$1.id, 
                                  "cantidad": producto_cantidad.$2,
                          },
                          conflictAlgorithm: ConflictAlgorithm.replace
                  );
          }
  }

  Future<void> deleteListaCompra(ListaCompra listaCompra) async {
    throw UnimplementedError();
  }


}
