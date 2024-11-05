import 'package:prizo/shared/data_entities/producto.dart';

Producto? obtenerProductoMasBarato(List<Producto> productos) {
  if (productos.isEmpty) return null;
  Producto productoMasBarato = productos[0];
  for (var producto in productos) {
    if (producto.precio < productoMasBarato.precio) {
      productoMasBarato = producto;
    }
  }
  return productoMasBarato;
}

//Recibe una lista y la divide en dos sublistas, el primer componente de la tupla es una lista de los items que tengan la misma categoría que
//la cabeza de la lista y el segundo elemento de la tupla son el resto
(List<Producto>, List<Producto>) ordenaPrioridadCategoria(List<Producto> productos){
  List<Producto> listaCategoriaCabeza = [];
  String categoriaCabeza = productos[0].categoria;
  for (int i = 0; i < productos.length; i++) {
    if (productos[i].categoria == categoriaCabeza ) {
      listaCategoriaCabeza.add(productos.removeAt(i));
      i--;
    }
  }
  return (listaCategoriaCabeza, productos);
}
List<Producto> combinaListaTuplas(List<(List<Producto>, List<Producto>)> listaTuplas){
  List<Producto> primeraListaTupla = [];
  List<Producto> segundaListaTupla = [];
  List<Producto> listaCombinada = [];
  //Añade las listas primeras de la tupla con las primeras y las segundas con las segundas
  for ((List<Producto>, List<Producto>) tupla in listaTuplas){
    primeraListaTupla += tupla.$1;
    segundaListaTupla += tupla.$2;
  }
  ordenarProductosPorPrecio(primeraListaTupla);
  ordenarProductosPorPrecio(segundaListaTupla);
  listaCombinada = primeraListaTupla + segundaListaTupla;
  return listaCombinada;
}

//ordena una lista de productos en base a su precio de menor a mayor
void ordenarProductosPorPrecio(List<Producto> productos) {
  productos.sort((a, b) => a.precio.compareTo(b.precio));
}

