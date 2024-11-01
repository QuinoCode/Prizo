import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaCompraService {

  void addProduct(ListaCompra list, Producto product){
    list.productos.add(product);
  }

}