import 'package:prizo/shared/data_entities/models/producto.dart';

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
(List<Producto>, List<Producto>) combinaListasSupers(List<(List<Producto>, List<Producto>)> listaTuplas){
  List<Producto> primeraListaTupla = [];
  List<Producto> segundaListaTupla = [];

  //Añade las listas primeras de la tupla con las primeras y las segundas con las segundas
  for ((List<Producto>, List<Producto>) tupla in listaTuplas){
    primeraListaTupla += tupla.$1;
    segundaListaTupla += tupla.$2;
  }
  
  ordenarProductosPorPrecio(primeraListaTupla);
  ordenarProductosPorPrecio(segundaListaTupla);
  return (primeraListaTupla, segundaListaTupla);
}

List<Producto> combinaTupla(List<(List<Producto>, List<Producto>)> listaTuplas){
  List<Producto> listaCombinada = [];
  (List<Producto>, List<Producto>) listaFinal = combinaListasSupers(listaTuplas);
  listaCombinada = listaFinal.$1 + listaFinal.$2;
  return listaCombinada;
}

(List<Producto>, List<Producto>) combinaListasSupersPrecioMedida(List<(List<Producto>, List<Producto>)> listaTuplas){
  List<Producto> primeraListaTupla = [];
  List<Producto> segundaListaTupla = [];

  //Añade las listas primeras de la tupla con las primeras y las segundas con las segundas
  for ((List<Producto>, List<Producto>) tupla in listaTuplas){
    primeraListaTupla += tupla.$1;
    segundaListaTupla += tupla.$2;
  }
  
  ordenarProductosPorPrecioMedida(primeraListaTupla);
  ordenarProductosPorPrecioMedida(segundaListaTupla);
  return (primeraListaTupla, segundaListaTupla);
}

//ordena una lista de productos en base a su precio de menor a mayor
void ordenarProductosPorPrecio(List<Producto> productos) {
  productos.sort((a, b) {
    double precioA = a.oferta ? a.precioOferta : a.precio;
    double precioB = b.oferta ? b.precioOferta : b.precio;
    return precioA.compareTo(precioB);
  });
}

void ordenarProductosPorPrecioMedida(List<Producto> productos) {
  productos.sort((a, b) {
    return a.precioMedida.compareTo(b.precioMedida);
  });
}

