import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/data_entities/producto.dart';

class ConsumFinderService {
  final String marketUri = "https://tienda.consum.es/api/rest/V1.0/catalog/searcher/products?q=%s&limit=20&showRecommendations=false";
  final String imageHost = "https://www.tienda.consum.es";

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

  Future<List<Producto>> _parseProductList(Map<String, dynamic> json) async {
    final List<Producto> productList = [];

    return productList;
  }
}
