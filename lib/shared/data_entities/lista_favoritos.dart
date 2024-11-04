import 'package:prizo/shared/data_entities/producto.dart';

class ListaFavoritos
{
  final String id;
  final String usuario;
  final List<Producto> productos;

  ListaFavoritos({
    required this.id,
    required this.usuario,
    required this.productos,
  });
}