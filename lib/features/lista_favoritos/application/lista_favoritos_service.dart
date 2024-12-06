import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaFavoritosService {

  void removeProduct(ListaFavoritos list, Producto product) {
    list.productos.remove(product);
  }

  void addProduct(ListaFavoritos list, Producto product) {
    int index = list.productos.indexWhere((p) => sameProduct(p, product));

    if (index != -1) {
      /* El producto existe, verificamos si está actualizado */
      if (updatedProduct(list.productos[index], product)) {
        /* Reemplazar el producto existente con el nuevo */
        list.productos[index] = product;
      }
    } else {
      /* Si no existe, se agrega el nuevo producto */
      list.productos.add(product);
    }
  }

  bool sameProduct(Producto productA, Producto productB) {
    /* Solo comparo los atributos que nunca cambian */
    return     productA.id == productB.id &&
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

}