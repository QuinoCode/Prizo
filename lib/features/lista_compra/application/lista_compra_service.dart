import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/application/producto_service.dart';

class ListaCompraService {

  final int LIMITE = 99;
  final ProductoService productoService = new ProductoService();

  void annadirProducto(ListaCompra list, Producto product) {
    /* lista vacía */
    if (list.productos.isEmpty) {
      list.productos.add((product, 1));
      return; /* fin ejecución */
    }

    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setCantidadProductoAux(index, list, product, list.productos[index].$2 + 1);
      return; /* fin ejecución */
    }

    /* El producto no existía en la lista */
    list.productos.add((product, 1));
  }

  void quitarProducto(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      list.productos.remove((list.productos[index].$1, list.productos[index].$2));
    }
  }

  /** El Producto product debe existir en la lista para invocar este método */
  void annadirInstancia(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setCantidadProductoAux(index, list, product, list.productos[index].$2 + 1);
    }
  }

  void quitarInstancia(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setCantidadProductoAux(index, list, product, list.productos[index].$2 - 1);
    }
  }

  /** Devuelve 0 si no existe el product */
  int getCantidadProducto(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      return list.productos[index].$2;
    }
    return 0;
  }

  /** El Producto product debe existir en la lista para invocar este método y quantity mayor a 0 */
  void setCantidadProducto(ListaCompra list, Producto product, int quantity) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if(index != -1) {
      setCantidadProductoAux(index, list, list.productos[index].$1, quantity);
    }
  }

  /** index debe ser distinto de -1 */
  void setCantidadProductoAux(int index, ListaCompra list, Producto product, int quantity) {
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

  /** Si el producto no existe, devuelve 0.0 */
  double getPrecio(ListaCompra list, Producto product) {
    /* Buscar producto en la lista existente */
    int index = buscarProducto(list, product);

    /* El producto existe en la lista */
    if (index != -1) {
      return productoService.getPrecio(list.productos[index].$1) * list.productos[index].$2;
    }

    return 0.0;
  }

  /** Si no hay productos en la lista, devuelve 0.0 */
  double getPrecioTotal(ListaCompra list) {
    double totalPrice = 0.0;
    for (var producto in list.productos) {
      totalPrice += productoService.getPrecio(producto.$1) * producto.$2;
    }
    return totalPrice;
  }

  int buscarProducto(ListaCompra list, Producto product) {
    /* Si el producto existe, devuelve el índice*/
    for (int index = 0; index < list.productos.length; index++) {
      if (productoService.mismoProducto(list.productos[index].$1, product)) {
        return index; /* fin ejecución */
      }
    }
    return -1;
  }
}