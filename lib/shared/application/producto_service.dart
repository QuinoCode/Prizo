import 'package:prizo/shared/data_entities/models/producto.dart';

class ProductoService {

  double getPrecio(Producto product) {
    if(product.oferta) {
      return product.precioOferta;
    }
    return product.precio;
  }

  bool mismoProducto(Producto productA, Producto productB) {
    /* Solo comparo los atributos que nunca cambian */
    return        productA.id == productB.id &&
        productA.nombre == productB.nombre &&
        productA.alergenos == productB.alergenos &&
        productA.tienda == productB.tienda &&
        productA.marca == productB.marca;
  }

  bool actualizadoProducto(Producto productA, Producto productB) {
    return      productA.foto != productB.foto ||
        productA.precio != productB.precio ||
        productA.precioMedida != productB.precioMedida ||
        productA.oferta != productB.oferta ||
        productA.precioOferta != productB.precioOferta;
  }

  String generarClave(Producto producto) {
    return '${producto.id}_${producto.nombre}_${producto.tienda}_${producto.marca}';
  }

  /**
   * Consistirá en una lista de 3 booleanos con las posiciones establecidas de la siguiente manera
   * - Posición 0: booleano para el GLUTEN
   * - Posición 1: booleano para la LACTOSA
   * - Posición 2: booleano para los FRUTOS SECOS
   * */
  bool tieneAlergeno(Producto producto, int indice) {
    if (indice < 0 || indice >= producto.alergenos.length) {
      throw ArgumentError("Índice fuera de rango");
    }
    return producto.alergenos[indice];
  }
}
