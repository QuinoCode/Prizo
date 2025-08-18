import 'package:prizo/shared/data_entities/DAO/producto_DAO.dart';
import 'package:prizo/shared/data_entities/models/pantry_list.dart';
import 'package:sqflite/sqflite.dart';

class PantryListDAO {
  final Database _database;
  late ProductoDAO productoDAO;

  PantryListDAO(this._database){
     productoDAO = ProductoDAO(_database);
  }



  Future<void> insertPantryList(PantryList pantryList) async {
          //Insert the empty List in the database
          await _database.insert(
                  'Pantry_List',
                  pantryList.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace
          );

          //Insert the products in the database just in case they're not present yet
          for (var producto_cantidad in pantryList.products){
                  await productoDAO.insertProducto(producto_cantidad.$1);
          }
          //Insert the products into the list
          for (var producto_cantidad in pantryList.products){
                  await _database.insert(
                          'Pantry_List_Product',
                          {
                                  "lista_id": pantryList.id, 
                                  "producto_id": producto_cantidad.$1.id, 
                                  "cantidad": producto_cantidad.$2,
                          },
                          conflictAlgorithm: ConflictAlgorithm.replace
                  );
          }
  }

  Future<void> deletePantryList(PantryList pantryList) async {
    throw UnimplementedError();
  }


}
