import 'package:prizo/shared/data_entities/producto.dart';

class ListaCompra
{
  final String id;
  final String usuario;
  final List<Producto> productos;

  ListaCompra({
    required this.id,
    required this.usuario,
    required this.productos,
  });
}

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