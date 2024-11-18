import '../../../shared/data_entities/producto.dart';
import '../../obtencion_producto/application/consum_finder_service.dart';
import '../../obtencion_producto/application/dia_finder_service.dart';
import '../../comparacion_productos/application/comparacion_producto.dart';
import '../../obtencion_producto/application/carrefour_finder_service.dart';

class PantallaProductoService {
  final ConsumFinderService consumService = ConsumFinderService();
  final DiaFinderService diaService = DiaFinderService();
  final CarrefourFinderService carrefourService = CarrefourFinderService();

  Future<List<Producto>> obtenerProductosSimilares(String query) async {
    try {
      final consumProductsFuture = consumService.fetchProductsFromApi(query);
      final diaProductsFuture = diaService.getProductList(query);
      final carrefourProductsFuture = carrefourService.getProductList(query);
      final results = await Future.wait([consumProductsFuture, diaProductsFuture, carrefourProductsFuture]);
      List<Producto> listaCombinada = results[0] + results[1] + results[2];
      ordenarProductosPorPrecio(listaCombinada);
      return listaCombinada;
    } catch (e) {
      print("Error al buscar productos: $e");
      return [];
    }
  }

  static String limpiarNombreProducto(String nombre) {
    // Lista de palabras comunes a eliminar
    List<String> stopwords = [
      "de", "con", "y", "en", "el", "la", "al", "los", "las", "ud", "g", "bolsa", "natural", "molino", "kg", "pack", "sabor"
    ];

    // Normaliza el texto
    String textoLimpio = nombre
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zñáéíóúü\s]'), '');

    // Divide el texto en palabras y filtra las stopwords
    List<String> palabrasFiltradas = textoLimpio.split(' ').where((palabra) {
      return !stopwords.contains(palabra) && palabra.length > 1; // Filtra palabras de parada y de 1 carácter
    }).toList();

    if (palabrasFiltradas.length > 2) {
      palabrasFiltradas = palabrasFiltradas.sublist(0, 2);
    }

    return palabrasFiltradas.join(' ');
  }

}