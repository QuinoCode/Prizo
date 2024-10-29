import '../../../shared/data_entities/producto.dart';

class Comparacion_producto
{
  static Producto? obtenerProductoMasBarato(List<Producto> productos) {
    if (productos.isEmpty) return null;

    Producto productoMasBarato = productos[0];

    for (var producto in productos) {
      if (producto.precio < productoMasBarato.precio) {
        productoMasBarato = producto;
      }
    }

    return productoMasBarato;
  }

  //ordena una lista de productos en base a su precio de menor a mayor
  static void ordenarProductosPorPrecio(List<Producto> productos) {
    productos.sort((a, b) => a.precio.compareTo(b.precio));
  }
}
