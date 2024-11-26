import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaCompraService {

  ListaCompra2 newListaCompra2(ListaCompra list) {
    ListaCompra2 juan = ListaCompra2(id: '1', usuario: 'usuario_demo', productos: []);
    return juan;
  }

  int searchProducto(ListaCompra2 list, Producto product) {
    /* Si el producto existe, devuelve el índice*/
    for (int i = 0; i < list.productos.length; i++) {
      if (list.productos[i].$1.id == product.id) {
        return i; /* fin ejecución */
      }
    }
    return -1;
  }

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
      list.productos[i] = (product /* se mete con la oferta actual */, list.productos[i].$2 + 1);
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
}