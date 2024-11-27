import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaCompraService {

  void addProduct(ListaCompra2 list, Producto product) {
    /* lista vacía */
    if (list.productos.isEmpty) {
      list.productos.add((product, 1));
      return; /* fin ejecución */
    }

    /* Buscar producto en la lista existente */
    int i = searchProducto(list, product);

    /* El producto existe en la lista */
    if(i != -1) {
      list.productos[i] = (product /* se mete para obtener oferta actual */, list.productos[i].$2 + 1);
      return; /* fin ejecución */
    }

    /* El producto no existía en la lista */
    list.productos.add((product, 1));
  }

  void removeProduct(ListaCompra2 list, Producto product) {
    /* Buscar producto en la lista existente */
    int i = searchProducto(list, product);

    /* El producto existe en la lista */
    if(i != -1) {
      list.productos.remove((list.productos[i].$1, list.productos[i].$2));
    }
  }

  /** El Producto product debe existir en la lista para invocar este método */
  void addInstance(ListaCompra2 list, Producto product) {
    /* Buscar producto en la lista existente */
    int i = searchProducto(list, product);

    /* El producto existe en la lista */
    if(i != -1) {
      list.productos[i] = (list.productos[i].$1, list.productos[i].$2 + 1);
    }
  }

  void removeInstance(ListaCompra2 list, Producto product) {
    /* Buscar producto en la lista existente */
    int i = searchProducto(list, product);

    /* El producto existe en la lista y tiene más de una instancia */
    if(i != -1 && list.productos[i].$2 > 1) {
      list.productos[i] = (product /* se mete para obtener oferta actual */, list.productos[i].$2 - 1);
    }
  }

  /** Devuelve -1 si no existe el product */
  int getProductQuantity(ListaCompra2 list, Producto product) {
    /* Buscar producto en la lista existente */
    int i = searchProducto(list, product);

    /* El producto existe en la lista */
    if(i != -1) {
      return list.productos[i].$2;
    }
    return -1;
  }//setProductQuantity

  /** Si el producto no existe, devuelve -1.0 */
  double getPrice(ListaCompra2 list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = searchProducto(list, product);

    /* El producto existe en la lista */
    if (index != -1) {
      /* Ver si tiene precioOferta */
      if (list.productos[index].$1.oferta) {
        return list.productos[index].$1.precioOferta * list.productos[index].$2;
      }
      return list.productos[index].$1.precio * list.productos[index].$2;
    }

    return -1.0;
  }

  /** Si no hay productos en la lista, devuelve 0.0 */
  double getTotalPrice(ListaCompra2 list) {
    double totalPrice = 0.0;
    for (var producto in list.productos) {
      /* Ver si tiene precioOferta */
      if (producto.$1.oferta) {
        totalPrice += producto.$1.precioOferta * producto.$2;
      } else {
        totalPrice += producto.$1.precio * producto.$2;
      }
    }
    return totalPrice;
  }

  int searchProducto(ListaCompra2 list, Producto product) {
    /* Si el producto existe, devuelve el índice*/
    for (int i = 0; i < list.productos.length; i++) {
      if (sameProduct(list.productos[i].$1, product)) {
        return i; /* fin ejecución */
      }
    }
    return -1;
  }

  bool sameProduct(Producto productA, Producto productB) {
    /* Solo comparo los atributos que nunca cambian */
    return        productA.id == productB.id &&
              productA.nombre == productB.nombre &&
           productA.alergenos == productB.alergenos &&
              productA.tienda == productB.tienda &&
               productA.marca == productB.marca;
  }
}