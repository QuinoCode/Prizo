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
  List<Producto> sinAlergenos(List<Producto> productos, List<int> alergenos) {
    if (alergenos.isEmpty || productos.isEmpty) {
      return productos;
    }
    List<Producto> filtrado = [];
    for (var producto in productos) {
      int contador = 0;
      for (var indice in alergenos) {
        if (producto.alergenos[indice]) {
          contador += 1;
        }
      }
      if (contador == 0) {
        filtrado.add(producto);
      }
    }
    return filtrado;
  }

  List<Producto> conTienda(List<Producto> productos, List<String> tiendas) {
    if (!tiendas.isEmpty && !productos.isEmpty) {
      List<Producto> filtrado = [];
      for (var producto in productos) {
        if (tiendas.contains(producto.tienda)) {
          filtrado.add(producto);
        }
      }
      return filtrado;
    }
    return productos;
  }

  List<Producto> sinTienda(List<Producto> productos, List<String> tiendas) {
    if (!tiendas.isEmpty && !productos.isEmpty) {
      List<Producto> filtrado = [];
      for (var producto in productos) {
        if (!tiendas.contains(producto.tienda)) {
          filtrado.add(producto);
        }
      }
      return filtrado;
    }
    return productos;
  }
}
