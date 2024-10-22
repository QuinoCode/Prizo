import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/data_entities/producto.dart';
import '../../../shared/data_entities/tienda.dart';

class DiaFinderService {
  final String marketUri = "https://www.dia.es/api/v1/search-back/search/reduced?q=%s&page=1";
  final String imageHost = "https://www.dia.es";

  String getMarketUri(String query) {
    return marketUri.replaceFirst("%s", query);
  }

  Future<List<Producto>> getProductList(String query) async {
    final List<Producto> productList = [];

    try {
      final url = getMarketUri(query);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List productsJsonList = jsonResponse["search_items"];
        final List facets = jsonResponse["facets"];

        // Variables para almacenar los valores de gluten, lactosa y frutos secos
        bool glutenFree = false;
        bool lactoseFree = false;
        bool nutsFree = false;

        // Extraer información de los campos facets (alergenos)
        for (var facet in facets) {
          if (facet["field"] == "gluten_free") {
            glutenFree = facet["filters"][0]["title"].toLowerCase() == "si";
          } else if (facet["field"] == "lactose_free") {
            lactoseFree = facet["filters"][0]["title"].toLowerCase() == "si";
          } else if (facet["field"] == "nuts_free") {
            nutsFree = facet["filters"][0]["title"].toLowerCase() == "si";
          }
        }

        // Procesar la lista de productos
        for (var productJson in productsJsonList) {
          final pricesObj = productJson["prices"];
          final product = Producto(
            id: productJson["object_id"] ?? "",
            tienda: Tienda.DIA,
            marca: productJson["brand"] ?? "-",
            precio: pricesObj["price"].toDouble(),
            nombre: productJson["display_name"],
            foto: productJson["image"].isNotEmpty
                ? imageHost + productJson["image"]
                : "",
            alergenos: [glutenFree, lactoseFree, nutsFree],
          );

          productList.add(product);
        }
      } else {
        print("Error fetching products: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }

    return productList;
  }
}


