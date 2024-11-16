import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaFavoritosService {

  void removeProduct(ListaFavoritos list, Producto product) {
    list.productos.remove(product);
  }

}