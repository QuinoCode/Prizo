import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaFavoritosService {

  void removeProduct(ListaFavoritos list, Producto product) {
    list.productos.remove(product);
  }

  void addProduct(ListaFavoritos list, Producto product) {
    if (!isProductInFavorites(list, product)) {
      list.productos.add(product);
    }
  }

  bool isProductInFavorites(ListaFavoritos list, Producto product) {
    return list.productos.any((p) =>
    p.id == product.id &&
        p.nombre == product.nombre &&
        p.tienda == product.tienda &&
        p.marca == product.marca);
  }

}