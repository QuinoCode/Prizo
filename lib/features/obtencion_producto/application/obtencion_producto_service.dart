
class ObtencionProductoService {

  //Método que elimina la marca y el supermercado del nombre del producto
  static String limpiarNombreProducto(String nombre, String marca, String tienda) {
    //Si la marca aparece al principio esta no se elimina
    if (nombre.startsWith(marca)) {
      nombre = nombre.replaceAll(RegExp('\\b$tienda\\b'), '').replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    } else {
      nombre = nombre
          .replaceAll(RegExp('\\b$marca\\b', caseSensitive: false), '',)
          .replaceAll(RegExp('\\b$tienda\\b'), '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
    }
    return nombre;
  }

}