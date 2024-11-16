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

}