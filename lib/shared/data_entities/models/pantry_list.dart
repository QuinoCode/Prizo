import 'package:prizo/shared/data_entities/models/producto.dart';

class PantryList
{
  final String id;
  final String user;
  final List<(Producto, int)> products;

  PantryList({
    required this.id,
    required this.user,
    required this.products,
  });

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "usuario": user,
    };
  }
}
