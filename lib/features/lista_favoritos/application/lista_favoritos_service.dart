import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';

class ListaFavoritosService {
  final ProductoService productoService = new ProductoService();

  void removeProduct(ListaFavoritos list, Producto product) {
    list.productos.remove(product);
  }

  void addProduct(ListaFavoritos list, Producto product) {
    int index = list.productos.indexWhere((p) => productoService.sameProduct(p, product));

    if (index != -1) {
      /* Se mete para obtener oferta actualizada */
      list.productos[index] = product ;
    } else {
      /* Si no existe, se agrega el nuevo producto */
      list.productos.add(product);
    }
  }

  bool isProductInFavorites(ListaFavoritos list, Producto product) {
    return list.productos.indexWhere((p) => productoService.sameProduct(p, product)) != -1;
  }

}