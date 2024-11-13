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

  void addProduct(Producto producto) {
    if (productos.isEmpty) {
      /*Si la lista está vacía, añadir el producto directamente*/
      productos.add(producto);
    } else {
      /*Si la lista no está vacía, comprobar si el producto ya existe*/
      bool productoExiste = false;
      for (var prod in productos) {
        if (prod.equals(producto)) {
          productoExiste = true;
          break;
        }
      }
      /*Si no existe, añadir el producto a la lista*/
      if (!productoExiste) {
        productos.add(producto);
      }
    }
  }
}