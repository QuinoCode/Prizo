import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prizo/features/obtencion_producto/application/finder_wrapper.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'obtencion_producto_service.dart';

class DiaFinderService implements FinderWrapper {
  @override
  final String marketUri = "https://www.dia.es/api/v1/search-back/search/reduced?q=%s&page=1";
  final String imageHost = "https://www.dia.es";

  String getMarketUri(String query) {
    return marketUri.replaceFirst("%s", query);
  }

  @override
  Future<List<Producto>> getProductList(String query) async {
    final List<Producto> productList = [];

    try {
      final url = getMarketUri(query);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final List productsJsonList = jsonResponse["search_items"];
        final List facets = jsonResponse["facets"];

        /* Variables para almacenar los valores de gluten, lactosa y frutos secos */
        bool glutenFree = false;
        bool lactoseFree = false;
        bool nutsFree = false;

        /* Extraer información de los campos facets (alergenos) */
        for (var facet in facets) {
          if (facet["field"] == "gluten_free") {
            glutenFree = facet["filters"][0]["title"].toLowerCase() == "si";
          } else if (facet["field"] == "lactose_free") {
            lactoseFree = facet["filters"][0]["title"].toLowerCase() == "si";
          } else if (facet["field"] == "nuts_free") {
            nutsFree = facet["filters"][0]["title"].toLowerCase() == "si";
          }
        }

        /* Procesar la lista de productos */
        for (var productJson in productsJsonList) {
          final pricesObj = productJson["prices"];
          final product = Producto(
            id: productJson["object_id"] != null ? productJson["object_id"] + "DIA" : "",
            tienda: "DIA",
            marca: productJson["brand"] ?? "-",
            precio: pricesObj["strikethrough_price"].toDouble(),
            precioMedida: pricesObj["price_per_unit"].toDouble(),
            nombre: ObtencionProductoService.limpiarNombreProducto(productJson["display_name"], productJson["brand"] ?? "-", "DIA"),
            foto: productJson["image"].isNotEmpty
                ? imageHost + productJson["image"]
                : "",
            alergenos: [glutenFree, lactoseFree, nutsFree],
            categoria: productJson["l2_category_description"],
            oferta: pricesObj["is_promo_price"] == true,
            precioOferta: pricesObj["price"].toDouble(),
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
