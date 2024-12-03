import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/comparacion_productos/application/comparacion_producto.dart';

void addProductCompra(ListaCompra list, Producto product) {
  /* lista vacía */
  if (list.productos.isEmpty) {
    list.productos.add((product, 1));
    return; /* fin ejecución */
  }

  /* Buscar producto en la lista existente */
  int index = searchProducto(list, product);

  /* El producto existe en la lista */
  if(index != -1) {
    list.productos[index] = (product /* se mete para obtener oferta actual */, list.productos[index].$2 + 1);
    return; /* fin ejecución */
  }

  /* El producto no existía en la lista */
  list.productos.add((product, 1));
}

void removeProduct(ListaCompra list, Producto product) {
  /* Buscar producto en la lista existente */
  int index = searchProducto(list, product);

  /* El producto existe en la lista */
  if(index != -1) {
    list.productos.remove((list.productos[index].$1, list.productos[index].$2));
  }
}

/** El Producto product debe existir en la lista para invocar este método */
void addInstance(ListaCompra list, Producto product) {
  /* Buscar producto en la lista existente */
  int index = searchProducto(list, product);

  /* El producto existe en la lista */
  if(index != -1) {
    list.productos[index] = (list.productos[index].$1, list.productos[index].$2 + 1);
  }
}

void removeInstance(ListaCompra list, Producto product) {
  /* Buscar producto en la lista existente */
  int index = searchProducto(list, product);

  /* El producto existe en la lista y tiene más de una instancia */
  if(index != -1 && list.productos[index].$2 > 1) {
    list.productos[index] = (product /* se mete para obtener oferta actual */, list.productos[index].$2 - 1);
  }
}

/** Devuelve -1 si no existe el product */
int getProductQuantity(ListaCompra list, Producto product) {
  /* Buscar producto en la lista existente */
  int index = searchProducto(list, product);

  /* El producto existe en la lista */
  if(index != -1) {
    return list.productos[index].$2;
  }
  return -1;
}

/** El Producto product debe existir en la lista para invocar este método y quantity mayor a 0 */
void setProductQuantity(ListaCompra list, Producto product, int quantity) {
  /* Buscar producto en la lista existente */
  int index = searchProducto(list, product);

  /* El producto existe en la lista */
  if(index != -1 && quantity > 0) {
    list.productos[index] = (list.productos[index].$1, quantity);
  }
}

/** Si el producto no existe, devuelve -1.0 */
double getPrice(ListaCompra list, Producto product) {
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
double getTotalPrice(ListaCompra list) {
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

int searchProducto(ListaCompra list, Producto product) {
  /* Si el producto existe, devuelve el índice*/
  for (int index = 0; index < list.productos.length; index++) {
    if (sameProduct(list.productos[index].$1, product)) {
      return index; /* fin ejecución */
    }
  }
  return -1;
}