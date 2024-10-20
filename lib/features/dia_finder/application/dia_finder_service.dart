import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/data_entities/producto.dart';
import 'package:html/parser.dart' as htmlParser;

class DiaFinderService {
  final String marketUri = "https://www.dia.es/api/v1/search-back/search/reduced?q=%s&page=1";
  final String imageHost = "https://www.dia.es";

  Future<List<Producto>> fetchProductsFromApi(String query) async {
    final url = Uri.parse(marketUri.replaceFirst('%s', query));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return _parseProductList(jsonData);
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // Método para analizar el HTML y extraer alérgenos en negrita
  List<String> _extractAlergenosFromHtml(String html) {
    final document = htmlParser.parse(html);
    final List<String> alergenos = [];

    // Busca el div que contiene los ingredientes
    final ingredientsSection = document.querySelector("#html-container");
    if (ingredientsSection != null) {
      // Selecciona todos los elementos <strong> dentro de la sección de ingredientes
      final elements = ingredientsSection.querySelectorAll("strong");

      for (var element in elements) {
        // Asegúrate de que el texto no esté vacío antes de añadirlo
        if (element.text.isNotEmpty) {
          alergenos.add(element.text.trim());
        }
      }
    }

    return alergenos;
  }

  // Función para obtener los ingredientes y alérgenos de la página del producto
  Future<List<String>> fetchProductAlergenos(String productDetailUrl) async {
    try {
      final response = await http.get(Uri.parse(productDetailUrl));

      if (response.statusCode == 200) {
        return _extractAlergenosFromHtml(response.body);
      } else {
        print("Failed to load product details");
        return [];
      }
    } catch (e) {
      print("Error fetching product details: $e");
      return [];
    }
  }

  Future<List<Producto>> _parseProductList(Map<String, dynamic> json) async {
    final List<Producto> productList = [];
    final productsJsonList = json['search_items'] as List<dynamic>;

    for (final productJson in productsJsonList) {
      final String productId = productJson['id'] ?? '';
      final String productDetailUrl = "https://www.dia.es/p/$productId";

      // Obtener alérgenos
      final List<String> alergenos = await fetchProductAlergenos(productDetailUrl);

      final productObj = Producto.fromJson(
        productJson,
        imageHost: imageHost,
        marketName: "DIA",
        alergenos: alergenos,
      );
      productList.add(productObj);
    }

    return productList;
  }
}
