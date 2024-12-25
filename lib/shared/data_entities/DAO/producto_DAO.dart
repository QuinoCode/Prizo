import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:sqflite/sqflite.dart';

class ProductoDAO {
  final Database _database;

  ProductoDAO(this._database);


  Future<void> insertProducto(Producto producto) async {
          await _database.insert(
                  'Producto',
                  producto.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace
          );
  }

  Future<void> deleteProducto(Producto producto) async {
    throw UnimplementedError();
  }

}
