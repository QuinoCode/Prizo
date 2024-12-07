import 'package:prizo/shared/data_entities/producto.dart';

class ProductoService {
  double getPrice(Producto product) {
    if(product.oferta) {
      return product.precioOferta;
    }
    return product.precio;
  }

  bool sameProduct(Producto productA, Producto productB) {
    /* Solo comparo los atributos que nunca cambian */
    return        productA.id == productB.id &&
        productA.nombre == productB.nombre &&
        productA.alergenos == productB.alergenos &&
        productA.tienda == productB.tienda &&
        productA.marca == productB.marca;
  }

  bool updatedProduct(Producto productA, Producto productB) {
    return      productA.foto != productB.foto ||
        productA.precio != productB.precio ||
        productA.precioMedida != productB.precioMedida ||
        productA.oferta != productB.oferta ||
        productA.precioOferta != productB.precioOferta;
  }

  String generateKey(Producto producto) {
    return '${producto.id}_${producto.nombre}_${producto.tienda}_${producto.marca}';
  }
}