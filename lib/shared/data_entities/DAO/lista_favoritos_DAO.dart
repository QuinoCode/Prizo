import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/DAO/producto_DAO.dart';
import 'package:sqflite/sqflite.dart';

class ListaFavoritosDAO {
  final Database _database;
  late ProductoDAO productoDAO;

  ListaFavoritosDAO(this._database){
     productoDAO = ProductoDAO(_database);
  }

  Future<void> insertListaFavoritos(ListaFavoritos listaFavoritos) async {
          await _database.insert(
                  'Lista_Favoritos',
                  listaFavoritos.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace
          );
  
          for (var producto in listaFavoritos.productos){
             await productoDAO.insertProducto(producto);
          }
  
          for (var producto in listaFavoritos.productos){
            await _database.insert(
                    'Lista_Favoritos_Producto',
                    {
                            "lista_id": listaFavoritos.id, 
                            "producto_id": producto.id, 
                    },
                    conflictAlgorithm: ConflictAlgorithm.replace
            );
          }
  }

  Future<void> deleteListaFavoritos(ListaFavoritos listaFavoritos) async {
    throw UnimplementedError();
  }

}
