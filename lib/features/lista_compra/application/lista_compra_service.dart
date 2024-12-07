import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/application/producto_service.dart';

class ListaCompraService {
  final int LIMITE = 99;
  final ProductoService productoService = new ProductoService();

  void addProduct(ListaCompra list, Producto product) {
    /* lista vacía */
    if (list.productos.isEmpty) {
      list.productos.add((product, 1));
      return; /* fin ejecución */
    }

    /* Buscar producto en la lista existente */
    int index = searchProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setProductQuantityAux(index, list, product, list.productos[index].$2 + 1);
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
      setProductQuantityAux(index, list, product, list.productos[index].$2 + 1);
    }
  }

  void removeInstance(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = searchProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setProductQuantityAux(index, list, product, list.productos[index].$2 - 1);
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
    if(index != -1) {
      setProductQuantityAux(index, list, list.productos[index].$1, quantity);
    }
  }

  /** index debe ser distinto de -1 */
  void setProductQuantityAux(int index, ListaCompra list, Producto product, int quantity) {
    int newQuantity = list.productos[index].$2;
    if(quantity > 0) {
      if(quantity > LIMITE) {
        newQuantity = LIMITE;
      } else {
        newQuantity = quantity;
      }
    }
    list.productos[index] = (product /* se mete para obtener oferta actualizada */, newQuantity);
  }

  /** Si el producto no existe, devuelve -1.0 */
  double getPrice(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = searchProducto(list, product);

    /* El producto existe en la lista */
    if (index != -1) {
      return productoService.getPrice(list.productos[index].$1) * list.productos[index].$2;
    }

    return -1.0;
  }

  /** Si no hay productos en la lista, devuelve 0.0 */
  double getTotalPrice(ListaCompra list) {
    double totalPrice = 0.0;
    for (var producto in list.productos) {
      totalPrice += productoService.getPrice(producto.$1) * producto.$2;
    }
    return totalPrice;
  }

  int searchProducto(ListaCompra list, Producto product) {
    /* Si el producto existe, devuelve el índice*/
    for (int index = 0; index < list.productos.length; index++) {
      if (productoService.sameProduct(list.productos[index].$1, product)) {
        return index; /* fin ejecución */
      }
    }
    return -1;
  }
}