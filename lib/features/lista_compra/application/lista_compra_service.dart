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

}