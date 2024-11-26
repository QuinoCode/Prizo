import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaCompraAuxiliar {
  List<Producto> productos;
  List<int> cantidades;

  ListaCompraAuxiliar({
    this.productos = const [], /* Usamos const para listas vacías predeterminadas */
    this.cantidades = const [],
  });
}

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
  }

  void addProductAux(ListaCompraAuxiliar list, Producto product) {
    /* Buscar si el producto ya está en la lista */
    int index = list.productos.indexWhere((p) => p.id == product.id);

    if (index != -1) {
      /* Si el producto ya existe, incrementar la cantidad */
      list.cantidades[index]+=1;
    } else {
      /* Si el producto no existe, agregarlo con cantidad inicial de 1 */
      list.productos.add(product);
      list.cantidades.add(1);
    }
  }//setProductQuantity

  ListaCompraAuxiliar crearListaCompraAuxiliar(ListaCompra listaCompra) {
    /*Mapa para contar la cantidad de cada producto*/
    Map<String, int> contadorProductos = {};
    List<Producto> productosUnicos = [];

    for (var producto in listaCompra.productos) {
      if (contadorProductos.containsKey(producto.id)) {
        contadorProductos[producto.id] = contadorProductos[producto.id]! + 1;
      } else {
        contadorProductos[producto.id] = 1;
        productosUnicos.add(producto); /*Agregar producto único*/
      }
    }
    /*Crear las listas de productos y cantidades*/
    List<int> cantidades = productosUnicos.map((producto) => contadorProductos[producto.id]!).toList();

    ListaCompraAuxiliar lista = new ListaCompraAuxiliar();
    for (var producto in listaCompra.productos) {
      addProductAux(lista, producto);
    }

    return ListaCompraAuxiliar(productos: productosUnicos, cantidades: cantidades);
  }

}