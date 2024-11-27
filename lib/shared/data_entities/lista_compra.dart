import 'package:prizo/shared/data_entities/producto.dart';

class ListaCompra2
{
  final String id;
  final String usuario;
  final List<(Producto, int)> productos;

  ListaCompra2({
    required this.id,
    required this.usuario,
    required this.productos,
  });
}