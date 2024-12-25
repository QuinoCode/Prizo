import 'package:prizo/shared/data_entities/models/producto.dart';

class ListaCompra
{
  final String id;
  final String usuario;
  final List<(Producto, int)> productos;

  ListaCompra({
    required this.id,
    required this.usuario,
    required this.productos,
  });

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "usuario": usuario,
    };
  }
}
