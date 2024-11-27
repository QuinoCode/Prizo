import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaFavoritosService {

  void removeProduct(ListaFavoritos list, Producto product) {
    list.productos.remove(product);
  }

  void addProduct(ListaFavoritos list, Producto product) {
    bool exists = list.productos.any((p) => sameProduct(p, product));
    if (!exists) {
      list.productos.add(product);
    }
  }

  bool sameProduct(Producto productA, Producto productB) {
    /* Solo comparo los atributos que nuca cambian */
    return        productA.id == productB.id &&
        productA.nombre == productB.nombre &&
        productA.alergenos == productB.alergenos &&
        productA.tienda == productB.tienda &&
        productA.marca == productB.marca;
  }

}