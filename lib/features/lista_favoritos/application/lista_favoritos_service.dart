import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class ListaFavoritosService {

  void addProduct(ListaFavoritos list, Producto product){
    list.productos.add(product);
  }

}