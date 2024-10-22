import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/data_entities/producto.dart';
import '../../../shared/data_entities/tienda.dart';

class ConsumFinderService {
  final String marketUri = "https://tienda.consum.es/api/rest/V1.0/catalog/searcher/products?q=%s&limit=20&showRecommendations=false";
  final String imageHost = "https://www.tienda.consum.es";

  Uri getMarketUri(String query) {
    return Uri.parse(marketUri.replaceFirst('%s', query));
  }

  Future<List<Producto>> fetchProductsFromApi(String query) async {
    try {
      final url = getMarketUri(query);
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

  Future<List<Producto>> _parseProductList(Map<String, dynamic> json) async {
    final List<Producto> productList = [];
    final List productsJsonList = json["products"];

    //crear lista de productos
    for (var productJson in productsJsonList) {
      final pricesObj = productJson["prices"];
      final product = Producto(
          id: productJson["object_id"] ?? "",
          tienda: Tienda.CONSUM,
          marca: productJson["brand"] ?? "-",
          precio: pricesObj["price"].toDouble(),
          nombre: productJson["display_name"],
          foto: productJson["image"].isNotEmpty ? imageHost +
              productJson["image"] : "",
          alergenos: [false, false, false]);

      productList.add(product);
    }
    return productList;
  }
}