import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/DAO/producto_DAO.dart';
import 'package:sqflite/sqflite.dart';
import '/shared/data_entities/models/producto.dart';

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

  Future<List<Producto>> getProductosEnOfertaDeFavoritos(String listaId) async {
    final List<Map<String, dynamic>> result = await _database.rawQuery(
        """
    SELECT Producto.*
    FROM Producto
    INNER JOIN Lista_Favoritos_Producto
    ON Producto.id = Lista_Favoritos_Producto.producto_id
    WHERE Lista_Favoritos_Producto.lista_id = ? AND Producto.oferta = 1
    """,
        [listaId]
    );

    return result.map((row) => Producto.fromMap(row)).toList();
  }

  Future<String?> getIdListaFavoritosPorUsuario(String usuario) async {
    final result = await _database.query(
      'Lista_Favoritos',
      where: 'usuario = ?',
      whereArgs: [usuario],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['id'] as String;
    }
    return null; // Si no se encuentra, devuelve null
  }

}
