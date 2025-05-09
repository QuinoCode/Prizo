import 'package:diacritic/diacritic.dart';

class ObtencionProductoService {

  static String eliminarAcentos(String texto) {
    return removeDiacritics(texto);
  }

  //Método que elimina la marca y el supermercado del nombre del producto
  static String limpiarNombreProducto(String nombre, String marca, String tienda) {
    String nombreOriginal = nombre;

    String nombreNormalizado = eliminarAcentos(nombre);
    String marcaNormalizada = eliminarAcentos(marca);

    //Si la marca aparece al principio esta no se elimina
    if (nombre.toLowerCase().startsWith(marca.toLowerCase())) {
      nombre = nombre.replaceAll(RegExp('\\b$tienda\\b', caseSensitive: false), '').replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    } else {
      nombre = nombreNormalizado
          .replaceAll(RegExp('\\b$marcaNormalizada\\b', caseSensitive: false), '',)
          .replaceAll(RegExp('\\b$tienda\\b'), '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
    }
    String nombreRestaurado = restaurarAcentos(nombre, nombreOriginal);

    return nombreRestaurado;
  }

  static String restaurarAcentos(String nombreLimpiado, String nombreOriginal) {
    List<String> palabrasLimpiadas = nombreLimpiado.split(' ');
    List<String> palabrasOriginales = nombreOriginal.split(' ');

    List<String> palabrasRestauradas = [];

    // Comparamos cada palabra limpia con la original
    for (int i = 0; i < palabrasLimpiadas.length; i++) {
      String palabraLimpiada = palabrasLimpiadas[i];
      String palabraOriginal = palabrasOriginales[i];

      // Si la palabra limpia coincide con la original, restauramos el acento
      if (removeDiacritics(palabraLimpiada).toLowerCase() == removeDiacritics(palabraOriginal).toLowerCase()) {
        palabrasRestauradas.add(palabraOriginal);
      } else {
        palabrasRestauradas.add(palabraLimpiada);
      }
    }

    return palabrasRestauradas.join(' ');
  }

}