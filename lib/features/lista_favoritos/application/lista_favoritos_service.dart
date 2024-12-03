import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/comparacion_productos/application/comparacion_producto.dart';

void removeProduct(ListaFavoritos list, Producto product) {
  list.productos.remove(product);
}

void addProductFavoritos(ListaFavoritos list, Producto product) {
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