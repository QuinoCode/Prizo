import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaCompraService {
  void removeProduct(ListaCompra list, Producto producto) {
    list.removeProduct(producto);
  }

  void addProduct(ListaCompra list, Producto producto) {
    list.addProduct(producto);
  }
}