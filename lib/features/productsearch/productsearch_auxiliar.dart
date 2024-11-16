import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class productsearchAuxiliar {

  void addCompra(ListaCompra list, Producto product){
    list.productos.add(product);
  }

  void addFav(ListaFavoritos list, Producto product) {
    bool exists = list.productos.any((p) =>
        p.id == product.id &&
        p.nombre == product.nombre &&
        p.tienda == product.tienda &&
        p.marca == product.marca);
    if (!exists) {
      list.productos.add(product);
    }
  }
}