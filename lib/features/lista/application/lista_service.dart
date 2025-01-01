import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';

class ListaService {
  final ProductoService productoService = new ProductoService();
  String obtenerNombre(Producto producto) {
    return producto.nombre;
  }

  List<Producto> obtenerComprados(ListaCompra lista) {
    List<Producto> comprados = [];
    for (var tupla in lista.productos ) {
      comprados.add(tupla.$1);
    }
    return comprados;
  }

  List<Producto> obtenerFavoritos(ListaFavoritos lista) {
    return lista.productos;
  }

  void borrarComprado(ListaCompra filtrada, ListaCompra original, Producto product) {
    int indexOriginal = buscarProducto(original, product);
    int indexFiltrada = buscarProducto(filtrada, product);
    if(indexOriginal != -1) {
      original.productos.remove((original.productos[indexOriginal].$1, original.productos[indexOriginal].$2));
    }
    if(indexFiltrada != -1) {
      filtrada.productos.remove((filtrada.productos[indexFiltrada].$1, filtrada.productos[indexFiltrada].$2));
    }
  }

  int buscarProducto(ListaCompra list, Producto product) {
    /* Si el producto existe, devuelve el índice*/
    for (int index = 0; index < list.productos.length; index++) {
      if (productoService.mismoProducto(list.productos[index].$1, product)) {
        return index; /* fin ejecución */
      }
    }
    return -1;
  }
}