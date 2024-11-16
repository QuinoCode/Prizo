import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaCompraAuxiliar {
  List<Producto> productos;
  List<int> cantidades;

  ListaCompraAuxiliar({
    required this.productos,
    required this.cantidades,
  });
}

class ListaCompraService {

  void addProduct(ListaCompra list, Producto product){
    list.productos.add(product);
  }

  void removeProduct(ListaCompra list, Producto product) {
    list.productos.remove(product);
  }

  void setProductQuantity(ListaCompra list, Producto product, int quantity) {
    /*Contar las instancias actuales del producto en la lista*/
    int currentQuantity = list.productos.where((p) => p.id == product.id).length;

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

    return ListaCompraAuxiliar(productos: productosUnicos, cantidades: cantidades);
  }

}