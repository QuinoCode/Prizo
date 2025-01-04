import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';

class ListaFavoritosService {
  final ProductoService productoService = new ProductoService();

  void quitarProducto(ListaFavoritos list, Producto product) {
    list.productos.remove(product);
  }

  void annadirProducto(ListaFavoritos list, Producto product) {
    int index = list.productos.indexWhere((p) => productoService.mismoProducto(p, product));

    if (index != -1) {
      /* Se mete para obtener oferta actualizada */
      list.productos[index] = product ;
    } else {
      /* Si no existe, se agrega el nuevo producto */
      list.productos.add(product);
    }
  }

  bool productoEnFavoritos(ListaFavoritos list, Producto product) {
    return list.productos.indexWhere((p) => productoService.mismoProducto(p, product)) != -1;
  }

  String obtenerSubcadena(String input) {
    String result;

    // Verificamos si la longitud es suficiente para acceder al carácter 17
    if (input.length >= 17 && input[16] == ' ') {
      result = input.substring(0, 16);
    } else {
      result = input.substring(0, 8);
    }

    // Comprobamos si el resultado es diferente al original
    if (result.length < input.length) {
      result += input.substring(result.length, 17) + "...";  // Agregamos "..." si el resultado es más corto que el original
    }

    return result;
  }
}