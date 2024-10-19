import '/shared/data_entities/product.dart';

Producto? obtenerProductoMasBarato(List<Producto> productos) {
  if (productos.isEmpty) return null;

  Producto productoMasBarato = productos[0];

  for (var producto in productos) {
    if (producto.precio < productoMasBarato.precio) {
      productoMasBarato = producto;
    }
  }

  return productoMasBarato;
}
