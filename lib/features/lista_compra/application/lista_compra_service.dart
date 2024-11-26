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

  void addProduct(ListaCompra2 list, Producto producto) {
    /* lista vacía */
    if (list.productos.isEmpty) {
      list.productos.add((producto, 1));
      return; /* fin ejecución */
    }

    /* Si el producto existe se incrementa el número en +1 */
    for (int i = 0; i < list.productos.length; i++) {
      if (list.productos[i].$1.id == producto.id) {
        list.productos[i] = (producto /* se mete con la oferta actual */, list.productos[i].$2 + 1);
        return; /* fin ejecución */
      }
    }

    /* El producto no existía en la lista */
    list.productos.add((producto, 1));
  }

  ListaCompra2 newListaCompra2(ListaCompra list) {
    ListaCompra2 juan = ListaCompra2(id: '1', usuario: 'usuario_demo', productos: []);
    return juan;
  }

  void removeProduct(ListaCompra list, Producto product) {
    list.productos.remove(product);
  }

  int getProductQuantity(ListaCompra list, Producto product) {
    /*Contar las instancias actuales del producto en la lista*/
    return list.productos.where((p) => p.id == product.id).length;
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
  }

  void setProductQuantity(ListaCompra list, Producto product, int quantity) {
    int currentQuantity = getProductQuantity(list, product);

    if (currentQuantity < quantity) {
      /*Agregar las instancias necesarias para llegar a la cantidad deseada*/
      int instancesToAdd = quantity - currentQuantity;
      for (int i = 0; i < instancesToAdd; i++) {
        list.productos.add(product);
      }
    } else if (currentQuantity > quantity) {
      /*Eliminar el exceso de instancias para llegar a la cantidad deseada*/
      int instancesToRemove = currentQuantity - quantity;
      for (int i = 0; i < instancesToRemove; i++) {
        list.productos.remove(product);
      }
    }
  }

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